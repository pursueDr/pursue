find /var/log/nginx  -type f -mtime +7 -name '*.log' -exec rm -rf {} \;
find /var/log/nginx  -type f -mtime +7 -name '*.log' |xargs  rm -rf
