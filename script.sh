#!/bin/bash

log_dir='/LOG'
limit=$1
count=$2
backup_dir='/BACKUP'

#$ - оператор подстановки значения
perc=$(df -h "$log_dir" | awk 'NR==2 {print $5}' | tr -d '%') #awk - утилита для обработки текста построчно.tr-del

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
#mountpoint - проверяет, является ли каталог точкой монтирования(смонтирован ли в него отдельный диск)
#q- тихий режим без вывода 


if [ "$perc" -gt "$limit" ]; then
echo "Лимит был превышен, запуск архивации"

#gt - greather than

files=$(ls -tr "$log_dir" |grep -v "lost+found" | head -n "$count")

#ls -tr список файлов от старых к новым(-r reverse t-time); grep laf - исключаем служебную папку; 
#head - берет первые строки из вывода, -n - count 

if [ -z "$files" ];then
echo "Нет файлов для архивации"
exit 1
fi


archive_size=$(du -c --block-size=1 "$log_dir"/$files 2>/dev/null | tail -n1 | awk '{print $1}')
#du - сколько места занимают файлы, -c итоговая строка с общим размером, --block-size - рзамер в байт.
#2>/dev/null вникуда сообщения о ошибках, |tail -n1 - последняя строка из du с total 
 
free_space=$(df -B1 "$backup_dir" | awk 'NR==2 {print $4}')



if [ -z "$archive_size" ] || [ -z "$free_space" ]; then
echo "Ошибка: не удалось определить размер архива или свободное место"
exit 1
fi

compression_ratio=0.5 #коэфицент сжатия

estimated_size=$(echo "$archive_size * $compression_ratio" | bc | cut -d'.' -f1) #bc - ариф вычисления включая дрб




if [ "$estimated_size" -ge "$free_space" ]; then
echo "На разделе BACKUP может не хватить места для архива."
exit 1
fi



tar -czf "$backup_dir/archive_$(date +%F_%T).tar.gz" -C "$log_dir" $files
#-czf - create, gzip сжатие, -f - имя файла, далее аргумент это путь к архиву. -С смена директории

rm -f $(echo $files |grep -v "lost+found" | sed "s:^:$log_dir/:g")


echo "Файлы перемещены в $backup_dir"


else
echo "Архивация не требуется"
fi

exit
