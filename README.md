# Build BookStack docker image with PDF exporting support chinese.

## Refer to
- [BookStack](https://www.bookstackapp.com/)
- [Image Base](https://hub.docker.com/r/linuxserver/bookstack)
- [PDF exporting support chinese](https://github.com/chenwaichung/bookstack.git)
- [Building Steps](https://github.com/falconray0704/docker-bookstack.git)

## Build

### Build image
```bash
make build
```

### Release and push
```bash
make release
make push-release
```

## Deploy

### Default access account/pwd
* acc: `admin@admin.com`
* pwd: `password`

### Localhost
```bash
sudo docker-compose up -d
```
Access with http://127.0.0.1:26875

### Synology NAS
- [Install](https://mariushosting.com/how-to-install-bookstack-on-your-synology-nas/)

## Backup and Restore
- [Backup and Restore](https://www.bookstackapp.com/docs/admin/backup-restore/)

### Backup

#### Note: Remember to disable Multi-Factor Authentication first!!! 

#### Database
Attach into the shell of database docker container.
```bash
mysqldump -u bookstack -p bookstackapp > /bookstack_tmp/bookstackapp.backup.sql
```

#### BookStack APP
Attach into the shell of BookStack docker container.
```bash
cd /config/nginx/www
tar -czvf /bookstack_tmp/bookstack-files-backup.tar.gz .env uploads 
```

### Restore
You can reset all data storage path to the new path.
After that, launching bookstack with docker compose.

#### Database
Attach into the shell of database docker container.
```bash
mysql -u bookstack -p bookstackapp < /bookstack_tmp/bookstackapp.backup.sql
```

#### BookStack APP
Attach into the shell of BookStack docker container.
```bash
tar -xvzf bookstack-files-backup.tar.gz -C /config/www
```

