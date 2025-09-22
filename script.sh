#!/bin/bash

log_dir=$1
limit=$2
count=$3
backup_dir="/BACKUP"


perc=$(df -h "$log_dir" | awk 'NR==2 {print $5}' | tr -d '%')

perc_bp=$(df -h "$backup_dir" | awk 'NR==2 {print $5}' | tr -d '%')

echo "$log_dir занята на $perc % при лимите в $limit %"
echo "$backup_dir занят на $perc_bp %"


if ! mountpoint -q "$log_dir"; then
echo "не существует раздела $log_dir"
exit 1
fi

if ! mountpoint -q "$backup_dir"; then
echo "не существует раздела $backup_dir"
exit 1
fi 


if [ "$perc" -gt "$limit" ]; then
echo "Лимит был превышен, запуск архивации"

files=$(ls -tr "$log_dir" |grep -v "lost+found" | head -n "$count")


if [ ${#files[@]} -eq 0 ];then
echo "Нет файлов для архивации"
exit 1
fi

archive_size=$(du -cb "$log_dir"/$files | tail -1 | awk '{print $1}')

free_space=$(df -B1 "$backup_dir" | awk 'N==2 {print $4}')

if [ "$archive_size" -ge "$free_space" ]; then
echo "На разделе BACKUP недостаточно места для архива."
exit 1
fi



tar -czf "$backup_dir/archive_$(date +%F_%T).tar.gz" -C "$log_dir" $files

rm -f $(echo $files |grep -v "lost+found" | sed "s:^:$log_dir/:g")

echo "Файлы перемещены в $backup_dir"


else
echo "Архивация не требуется"
fi

exit
