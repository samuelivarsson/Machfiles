# srv: pick a Gung server or customer app from the ansible inventory with fzf and act on it.
# Search mode: type to filter, ctrl-j/k to move, enter = ssh, ctrl-t/l/s = tail/less/status.
# Esc switches to command mode, where plain t/l/s/j/k work; / goes back to search, q/esc quits.

GUNG_ANSIBLE_DIR="${GUNG_ANSIBLE_DIR:-$HOME/gung_home/gung-ansible-backend}"

# One line per host and per app: ip <TAB> app (empty for hosts) <TAB> display text.
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
      for (i = 1; i <= n; i++) printf "%s\t\t%-28s %s\n", ip[order[i]], order[i], ip[order[i]]
      for (i = 1; i <= m; i++) { split(apps[i], a, SUBSEP); printf "%s\t%s\t%-28s %-16s %s\n", ip[a[2]], a[1], a[1], a[2], ip[a[2]] }
    }
  ' "$inv/hosts.ini" "$inv/group_vars/all.yml"
}

srv() {
  local search_footer='enter ssh · ctrl-t tail · ctrl-l less · ctrl-s status · esc kommandoläge'
  local cmd_footer='t tail · l less · s status · enter ssh · j/k flytta · / sök · q avsluta'
  local keys='j,k,t,l,s,q,/'
  local out
  out=$(_srv_list | fzf --delimiter=$'\t' --with-nth=3 --tiebreak=begin,length \
    --prompt='sök> ' --height=60% --reverse --footer="$search_footer" \
    --bind "start:unbind($keys)" \
    --bind "esc:transform:[[ \$FZF_PROMPT == 'sök> ' ]] && echo 'change-prompt(kommando> )+rebind($keys)+change-footer($cmd_footer)' || echo abort" \
    --bind "/:change-prompt(sök> )+unbind($keys)+change-footer($search_footer)" \
    --bind 'ctrl-j:down,ctrl-k:up,j:down,k:up,q:abort' \
    --bind 'enter:print(ssh)+accept' \
    --bind 'ctrl-t:print(tail)+accept,t:print(tail)+accept' \
    --bind 'ctrl-l:print(less)+accept,l:print(less)+accept' \
    --bind 'ctrl-s:print(status)+accept,s:print(status)+accept') || return

  local action=${out%%$'\n'*} line=${out#*$'\n'}
  local ip=${line%%$'\t'*} rest=${line#*$'\t'}
  local app=${rest%%$'\t'*} log
  log="~/apps/$app/logs/app.log"

  if [[ -z $app && $action != ssh ]]; then
    print -u2 "srv: $action kräver en app, inte en server"
    return 1
  fi

  local cmd
  case $action in
    ssh)    [[ -n $app ]] && cmd="ssh -t gung@$ip 'cd ~/apps/$app && exec \$SHELL -l'" || cmd="ssh gung@$ip" ;;
    tail)   cmd="ssh -t gung@$ip 'tail -n 200 -F $log'" ;;
    less)   cmd="ssh -t gung@$ip 'less -R +G $log'" ;;
    status) cmd="ssh -t gung@$ip 'systemctl --user status $app --no-pager -n 30'" ;;
  esac
  print -s -- "$cmd"
  eval "$cmd"
}
