# !/bin/sh
# setup.sh

alias_exists() {
  count=$(ifconfig lo0 | grep $DOCKERHOST_ALIAS_IP | wc -l)
  [ $count == 1 ]
}

print_ok() {
  # green
  printf "\e[32m==>\e[0m $1" ; echo
}

print_error() {
  # red
  printf "\e[31m==>\e[0m $1" ; echo
}

print_warn() {
  # yellow
  printf "\e[33m==>\e[0m $1" ; echo
}

if [ -f /usr/local/etc/dnsmasq.conf ] && diff templates/dnsmasq.conf /usr/local/etc/dnsmasq.conf -q ; then
  print_ok 'Template already installed at /usr/local/etc/dnsmasq.conf'
else
  print_warn 'Installing template at /usr/local/etc/dnsmasq.conf'
  cp templates/dnsmasq.conf /usr/local/etc/dnsmasq.conf
fi

if [ -f /etc/resolver/localdev ] && diff templates/localdev /etc/resolver/localdev -q ; then
  print_ok 'Template already installed at /etc/resolver/localdev'
else
  print_warn 'Installing template at /etc/resolver/localdev'
  sudo cp templates/localdev /etc/resolver/localdev
fi

print_ok 'Allowing .envrc'
direnv allow &> /dev/null ;
source .envrc

if alias_exists ; then
  print_ok 'Network interface already configured'
else
  print_warn 'Configure network interface...'
  sudo ifconfig lo0 alias $DOCKERHOST_ALIAS_IP
fi

if ! pgrep dnsmasq > /dev/null ; then
  sudo brew services restart dnsmasq
fi
