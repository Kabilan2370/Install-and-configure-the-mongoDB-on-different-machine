#! /bin/bash

sudo yum install coreutils -y 

# Mongodb v5.0. repo
Name="MongoDB-5.0-repo"
Base_url="https://repo.mongodb.org/yum/redhat/7/mongodb-org/5.0/x86_64/"
GPGcheck=1
Enabled=1
GPGkey="https://pgp.mongodb.com/server-5.0.asc"

sudo tee /etc/yum.repos.d/$Name.repo << EOF
[$Name]
name=MongoDBv5.0
baseurl=$BaseURL
gpgcheck=$GPGcheck
enabled=$Enabled
gpgkey=$GPGkey
EOF

# Update repository
sudo yum update -y

# install mangodb
sudo yum install -y mongodb-org-5.0.29 mongodb-org-database-5.0.29 mongodb-org-server-5.0.29 mongodb-org-shell-5.0.29 mongodb-org-mongos-5.0.29 mongodb-org-tools-5.0.29


# Create 3 data dir
sudo mkdir -p /data/mem1 
sudo mkdir -p /data/mem2
sudo mkdir -p /data/mem3

sudo chown -R mongod:mongod /data/mem1 /data/mem2 /data/mem3

# Configure MongoDB
cat > /etc/mongod.conf << EOF
systemLog:
  destination: file
  path: /var/log/mongodb/mongod.log
net:
  port: 27017
replication:
  replSetName: rs0
  arbiterOnly: false
storage:
  dbPath: /data/mem1
  wiredTiger:
    cacheSizeGB: 1
security:
  javascriptEnabled: false

EOF

cat > /etc/mongod2.conf << EOF
systemLog:
  destination: file
  path: /var/log/mongodb/mongod2.log
net:
  port: 27018
replication:
  replSetName: rs0
  arbiterOnly: false
storage:
  dbPath: /data/mem2
  wiredTiger:
    cacheSizeGB: 1
security:
  javascriptEnabled: false

EOF

cat > /etc/mongod3.conf << EOF
systemLog:
  destination: file
  path: /var/log/mongodb/mongod3.log
net:
  port: 27019
replication:
  replSetName: rs0
  arbiterOnly: true
storage:
  dbPath: /data/mem3
  wiredTiger:
    cacheSizeGB: 1
security:
  javascriptEnabled: false
EOF

# Start and enable MongoDB processes
sudo systemctl enable mongod mongod2 mongod3
sudo systemctl start mongod mongod2 mongod3


# Initiate a replicaset
mongo --host locahost
rs.initiate( {
   _id : "rs0",
   members: [
      { _id: 0, host: "localhost:27017" },
      { _id: 1, host: "localhost:27018" },
      { _id: 2, host: "localhost:27019" }
   ]
})

