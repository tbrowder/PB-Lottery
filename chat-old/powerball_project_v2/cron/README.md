# Cron setup

Install:
```bash
sudo install -m 755 get-powerball.sh /usr/local/bin/get-powerball.sh
sudo install -m 644 powerball.cron.d /etc/cron.d/powerball
sudo mkdir -p /var/local/powerball/history
sudo chown -R root:root /var/local/powerball
sudo service cron reload
```
