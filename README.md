Lab Script 1 — Backup & Log Archiver
Скрипт для автоматической архивации файлов из раздела /LOG в раздел /BACKUP
при превышении заданного порога использования диска.
Работает в среде Linux/WSL и написан на Bash.

В WSL при отсутствии разделов /LOG и /BACKUP необходимо их создать:
```bash
mkdir -p ~/lab_disks

dd if=/dev/zero of=~/lab_disks/log.img bs=1M count=100
dd if=/dev/zero of=~/lab_disks/backup.img bs=1M count=100

mkfs.ext4 ~/lab_disks/log.img
mkfs.ext4 ~/lab_disks/backup.img

sudo mkdir -p /LOG /BACKUP
sudo mount -o loop ~/lab_disks/log.img /LOG
sudo mount -o loop ~/lab_disks/backup.img /BACKUP
```

Использование:
```bash
./script.sh <LIMIT_PERCENT> <FILES_COUNT>
```
<LOG_DIR> - путь к разделу с логами (/LOG)
<LIMIT_PERCENT> - порог заполнения раздела (например, 30)
<FILES_COUNT> - количество файлов для архивации при превышении лимита
