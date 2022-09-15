
# Install Lighthouse
export LIGHTHOUSE_VERSION="v3.1.0"

cd /home/ubuntu
wget https://github.com/sigp/lighthouse/releases/download/$LIGHTHOUSE_VERSION/lighthouse-$LIGHTHOUSE_VERSION-x86_64-unknown-linux-gnu.tar.gz
tar xvf lighthouse-$LIGHTHOUSE_VERSION-x86_64-unknown-linux-gnu.tar.gz
rm lighthouse-$LIGHTHOUSE_VERSION-x86_64-unknown-linux-gnu.tar.gz
mv lighthouse /usr/local/bin
chown ubuntu: /usr/local/bin/lighthouse

# Configure Lighthouse
mkdir -p /chaindata/lighthouse
chown -R ubuntu: /chaindata/lighthouse

cat <<EOF > /etc/systemd/system/lighthouse-beacon.service
[Unit]
Description=Lighthouse Ethereum Client Beacon Node
Wants=network-online.target
After=network-online.target

[Service]
Type=simple
User=ubuntu
Group=ubuntu
Restart=on-failure
RestartSec=5
ExecStart=/usr/local/bin/lighthouse bn \
    --network ${network} \
    --datadir /chaindata/lighthouse \
    --http \
    --execution-endpoint http://127.0.0.1:8551 \
    --metrics \
    --validator-monitor-auto \
    --checkpoint-sync-url https://mainnet.checkpoint-sync.ethpandaops.io \
    --execution-jwt /var/lib/ethereum/jwttoken

[Install]
WantedBy=multi-user.target
EOF

systemctl enable lighthouse-beacon.service
systemctl start lighthouse-beacon.service