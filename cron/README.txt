Install steps:

sudo install -m 755 cron/get-powerball.sh /usr/local/bin/get-powerball.sh
sudo install -m 644 cron/powerball.cron.d /etc/cron.d/powerball
sudo mkdir -p /var/local/powerball/history
sudo chown -R root:root /var/local/powerball
# sudo systemctl reload cron [NOPE]  # or: sudo service cron reload
sudo service cron reload

This will maintain:

Latest file: /var/local/powerball/pb.pdf

History: /var/local/powerball/history/pb-YYYY-MM-DD.pdf

Log: /var/local/poweball/cron.log

Want me to add a companion cron that triggers parsing to blocks/JSON
right after the download?
