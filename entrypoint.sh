#!/bin/sh
set -e


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
    # 是目录
    echo find $REPO
    new_repo $REPO
  fi
done


# Apache gets grumpy about PID files pre-existing
rm -f /run/apache2/httpd.pid
exec httpd -DFOREGROUND
