# !/bin/sh
# start.sh

main() {
  # Delete the nginx volume so that we always load fresh config
  docker rm -v vzaar-nginx &> /dev/null

  # Start 'er up!
  docker-compose up -d
}

main
