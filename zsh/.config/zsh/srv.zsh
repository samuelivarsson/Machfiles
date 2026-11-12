# srv: pick a Gung server or customer app from the ansible inventory with fzf and act on it.
# Search mode: type to filter, ctrl-j/k to move, ctrl-o = ssh, ctrl-t/l/s = tail/less/status.
# Enter or esc switches to command mode: enter = ssh, plain t/l/s/j/k work, / goes back to search,
# q/esc quits. (fzf cannot bind ctrl-enter, and Option is not Meta in cmux, so direct ssh is ctrl-o.)
# The shell (enter) goes through Teleport so the session is recorded; tail/less/status are read-only
# and use plain ssh so following logs needs no Teleport login. `srv --ssh` skips Teleport entirely.

GUNG_ANSIBLE_DIR="${GUNG_ANSIBLE_DIR:-$HOME/gung_home/gung-ansible-backend}"
GUNG_TELEPORT_PROXY="${GUNG_TELEPORT_PROXY:-gungteleport.remote24.se:443}"

# One line per host and per app: ip <TAB> host <TAB> app (empty for hosts) <TAB> display text.
_srv_list() {
  local inv="$GUNG_ANSIBLE_DIR/inventory"
  awk '
    FNR == NR {
      if ($0 ~ /^[[:space:]]*[#;\[]/ || NF == 0) next
      for (i = 2; i <= NF; i++) if ($i ~ /^ansible_host=/) { split($i, kv, "="); ip[$1] = kv[2]; order[++n] = $1 }
      next
    }
    /^  - name: / { app = $3 }
    /^    host: / { if (app != "" && ($2 in ip) && !seen[app]++) apps[++m] = app SUBSEP $2; app = "" }
    END {
      for (i = 1; i <= n; i++) printf "%s\t%s\t\t%-28s %s\n", ip[order[i]], order[i], order[i], ip[order[i]]
      for (i = 1; i <= m; i++) { split(apps[i], a, SUBSEP); printf "%s\t%s\t%s\t%-28s %-16s %s\n", ip[a[2]], a[2], a[1], a[1], a[2], ip[a[2]] }
    }
  ' "$inv/hosts.ini" "$inv/group_vars/all.yml"
}

# Logs in to Teleport only when there is no valid session, reusing the user from the saved profile.
_srv_tsh_login() {
  tsh status >/dev/null 2>&1 && return
  local user
  user=$(awk '/^user:/ { print $2 }' "$HOME/.tsh/${GUNG_TELEPORT_PROXY%%:*}.yaml" 2>/dev/null)
  tsh login --proxy="$GUNG_TELEPORT_PROXY" ${user:+--user=$user}
}

srv() {
  local plain_ssh=0
  [[ $1 == --ssh ]] && plain_ssh=1
  local search_footer='enter/esc kommandoläge · ctrl-o ssh · ctrl-t tail · ctrl-l less · ctrl-s status'
  local cmd_footer='enter ssh · t tail · l less · s status · j/k flytta · / sök · q avsluta'
  local keys='j,k,t,l,s,q,/'
  local to_cmd="change-prompt(kommando> )+rebind($keys)+change-footer($cmd_footer)"
  local in_search="[[ \$FZF_PROMPT == 'sök> ' ]]"
  local out
  out=$(_srv_list | fzf --delimiter=$'\t' --with-nth=4 --tiebreak=begin,length \
    --prompt='sök> ' --height=60% --reverse --footer="$search_footer" \
    --bind "start:unbind($keys)" \
    --bind "esc:transform:$in_search && echo '$to_cmd' || echo abort" \
    --bind "enter:transform:$in_search && echo '$to_cmd' || echo 'print(ssh)+accept'" \
    --bind "/:change-prompt(sök> )+unbind($keys)+change-footer($search_footer)" \
    --bind 'ctrl-j:down,ctrl-k:up,j:down,k:up,q:abort' \
    --bind 'ctrl-o:print(ssh)+accept,alt-enter:print(ssh)+accept' \
    --bind 'ctrl-t:print(tail)+accept,t:print(tail)+accept' \
    --bind 'ctrl-l:print(less)+accept,l:print(less)+accept' \
    --bind 'ctrl-s:print(status)+accept,s:print(status)+accept') || return

  local action=${out%%$'\n'*} line=${out#*$'\n'}
  local -a fields=("${(@ps:\t:)line}")
  local ip=$fields[1] host=$fields[2] app=$fields[3]
  local log="~/apps/$app/logs/app.log"

  if [[ -z $app && $action != ssh ]]; then
    print -u2 "srv: $action kräver en app, inte en server"
    return 1
  fi

  local cmd remote
  case $action in
    ssh)
      [[ -n $app ]] && remote=" 'cd ~/apps/$app && exec \$SHELL -l'"
      # Hosts outside the Remote24 network (e.g. externalinstrumenta) are not in Teleport.
      if (( plain_ssh )); then
        cmd="ssh -t gung@$ip$remote"
      elif [[ $ip != 10.30.6.* ]]; then
        print -u2 "srv: $host finns inte i Teleport, kör vanlig ssh"
        cmd="ssh -t gung@$ip$remote"
      else
        cmd="tsh ssh -t gung@$host$remote"
      fi
      ;;
    tail)   cmd="ssh -t gung@$ip 'tail -n 200 -F $log'" ;;
    less)   cmd="ssh -t gung@$ip 'less -R +G $log'" ;;
    status) cmd="ssh -t gung@$ip 'systemctl --user status $app --no-pager -n 30'" ;;
  esac
  print -s -- "$cmd"
  if [[ $cmd == tsh* ]]; then _srv_tsh_login || return; fi
  eval "$cmd"
}
