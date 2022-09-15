#!/bin/bash

# Enable SSM connectivity
systemctl stop snap.amazon-ssm-agent.amazon-ssm-agent.service
systemctl start snap.amazon-ssm-agent.amazon-ssm-agent.service

# Set hostname
hostname="$(cut -d'.' -f1-2 <<< ${subdomain_name})"
hostnamectl set-hostname $hostname

add-apt-repository -y ppa:certbot/certbot
apt-get update -y

apt-get install -y nvme-cli net-tools python3-certbot-nginx \
                    libltdl7 software-properties-common \
                    build-essential wget git nginx curl vim \
                    python3-pip jq libwww-perl libdatetime-perl unzip prometheus

pip3 install --upgrade awscli

systemctl enable prometheus
# Comes with prometheus package, not used atm
systemctl disable prometheus-node-exporter 
systemctl stop  prometheus-node-exporter

# Get certificate
certbot certonly --standalone \
  --non-interactive --agree-tos \
  --email ${certificate_email} \
  --domains ${subdomain_name} \
  --pre-hook 'service nginx stop' \
  --post-hook 'service nginx start'

# Check if restoring from snapshot, skip formatting the filesystem if true
if [ -z "${snapshot}" ]
then
  mkfs.ext4 `nvme list|grep TB|awk {'print $1'}` -L CHAINDATA
fi
# Mount /chaindata
mkdir /chaindata
echo "`blkid|grep CHAINDATA|awk {'print $3'}|tr -d '"'`  /chaindata  ext4  defaults,nofail  0  2" >> /etc/fstab
mount -a
chown -R ubuntu: /chaindata

# # Enable CloudWatch monitoring
# cd /tmp
# curl http://aws-cloudwatch.s3.amazonaws.com/downloads/CloudWatchMonitoringScripts-1.2.1.zip -O
# unzip CloudWatchMonitoringScripts-1.2.1.zip
# rm CloudWatchMonitoringScripts-1.2.1.zip
# mv aws-scripts-mon /opt/aws-scripts-mon
# # Add to cron
# monit_croncmdslash="/opt/aws-scripts-mon/mon-put-instance-data.pl --mem-util --disk-space-util --disk-path=/ --from-cron"
# monit_croncmdchaindata="/opt/aws-scripts-mon/mon-put-instance-data.pl --disk-space-util --disk-path=/chaindata --from-cron"
# echo "*/5 * * * *	root $monit_croncmdslash" >> /etc/crontab
# echo "*/5 * * * *	root $monit_croncmdchaindata" >> /etc/crontab

# Configure nginx to proxy to Eth node
httpupgrade='$http_upgrade'
remoteaddr='$remote_addr'
requestmethod='$request_method'
cat <<EOF > /etc/nginx/sites-enabled/default
server {
        listen 443;
        server_name ${subdomain_name};
        error_log /var/log/nginx/${subdomain_name}_error.log;

        ssl on;
        ssl_protocols TLSv1.2; # don’t use SSLv3 ref: POODLE
        ssl_certificate /etc/letsencrypt/live/${subdomain_name}/fullchain.pem;
        ssl_certificate_key /etc/letsencrypt/live/${subdomain_name}/privkey.pem;

        location ^~ /rpc {
            proxy_pass http://127.0.0.1:${http_port}/;
            proxy_http_version 1.1;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header Upgrade $http_upgrade;
            proxy_set_header Connection "upgrade";
            proxy_set_header X-NginX-Proxy true;
            proxy_redirect off;
            proxy_read_timeout 86400;
        }

        location ^~ /ws {
            proxy_pass http://127.0.0.1:${ws_port}/;
            proxy_http_version 1.1;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header Upgrade $http_upgrade;
            proxy_set_header Connection "upgrade";
            proxy_set_header X-NginX-Proxy true;
            proxy_redirect off;
            proxy_read_timeout 86400;
        }
}
EOF

service nginx reload