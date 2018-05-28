#!/bin/sh
set -e

if [ -z $LDAP_URL ]; then
  echo LDAP_URL not config
  exit 1
fi

function replace_vars() {
eval "cat <<EOF
`cat $2`
EOF" >> $1
}

function is_empty_dir(){ 
  return `ls -A $1|wc -w`
}

function new_repo() {
  if is_empty_dir $1; then
    svnadmin create --fs-type fsfs $1
  else
    echo repo $1 created, skip
  fi
}

mkdir -p /repo
for item in `ls /repo`; do
  REPO=/repo/$item
  if [ -d $REPO ];then
    # is directory
    echo find $REPO
    new_repo $REPO
  fi
done

replace_vars /etc/apache2/conf.d/svn.conf /etc/apache2/svn.conf

python /script/ldap.py
crond -l 0 -d 0 -L /dev/stdout

# Apache gets grumpy about PID files pre-existing
rm -f /run/apache2/httpd.pid
exec httpd -DFOREGROUND
