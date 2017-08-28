# !/bin/sh
# monitor.sh

main() {
  watch "docker ps --all --filter name=demo && echo && docker volume ls --filter name=demo"
}

main
