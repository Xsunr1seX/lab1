#!/bin/bash

log_dir=$1
limit=$2
count=$3
backup_dir="/BACKUP"


perc=$(df -h "$log_dir" | awk 'NR==2 {print $5}' | tr -d '%')

echo "$log_dir занята на $perc % при лимите в $limit %"

if !mountpoint -q "$log_dir"; then
echo "не существует раздела $log_dir"
exit 1
fi

if !mountpoint -q "$backup_dir"; then
echo "не существует раздела $backup_dir"
exit 1
fi


if [ "$perc" -gt "$limit" ]; then
echo "Лимит был превышен, запуск архивации"


files=$(ls -tr "$log_dir" | head -n "$count")

tar -czf "$backup_dir/archive_$(date +%F_%T).tar.gz" -C "$log_dir" $files

rm -f $(echo $files | sed "s:^:$log_dir/:g")

echo "Файлы перемещены в $backup_dir"


else
echo "Архивация не требуется"
fi

exit

