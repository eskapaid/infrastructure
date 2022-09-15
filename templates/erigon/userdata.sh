
# Install Go dependencies
chmod 666 /dev/null # ubuntu bug?
sudo su - ubuntu
export HOME=/home/ubuntu
wget -O go.tar.gz https://go.dev/dl/go1.18.3.linux-amd64.tar.gz
sudo rm -rf /usr/local/go && sudo tar -C /usr/local -xzf go.tar.gz
echo export PATH=$PATH:/usr/local/go/bin >> $HOME/.bashrc
source $HOME/.bashrc
rm go.tar.gz

# Build and install Erigon
cd $HOME
git clone --recurse-submodules -j8 https://github.com/ledgerwatch/erigon.git
cd erigon
git fetch --all --tags
ERIGON_VERSION="v2022.09.01"
git checkout tags/$ERIGON_VERSION -b $ERIGON_VERSION
make erigon

# Create JWT token file
sudo su
mkdir -p /var/lib/ethereum
openssl rand -hex 32 | tr -d "\n" | sudo tee /var/lib/ethereum/jwttoken
chmod +r /var/lib/ethereum/jwttoken

# For a minimalistic setup (Execution Node is purely complimenting the Consensus Node) we can prune Erigon data, add these flags:
# --prune=htc \
# --prune.r.before=11052984 \
# See Erigon help for the "htc" descriptions.
# ETH2 Deposit Contract Block Number is 11052984, we don't need to keep receipts older than that.

# Setup and configure systemd
cat > /etc/systemd/system/erigon.service << EOF 
[Unit]
Description = erigon service
Wants       = network.target
After       = network.target 

[Service]
User      = ubuntu
ExecStart = /home/ubuntu/erigon/build/bin/erigon \
  --chain=${network} \
  --datadir=/chaindata/erigon \
  --port=30303 \
  --ws \
  --http \
  --http.port=8545 \
  --http.api=${http_apis} \
  --torrent.port=42069 \
  --torrent.download.rate=200mb \
  --metrics \
  --metrics.addr=0.0.0.0 \
  --metrics.port=6060 \
  --private.api.addr=0.0.0.0:9090 \
  --authrpc.jwtsecret=/var/lib/ethereum/jwttoken \

Restart    = on-failure
RestartSec = 3

[Install]
WantedBy = multi-user.target
EOF

systemctl daemon-reload
systemctl enable erigon
systemctl start erigon
