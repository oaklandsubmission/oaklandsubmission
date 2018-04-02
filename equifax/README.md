Run as root:
# Install common utilities 
./install-common-util.sh

# Install Docker
./install-docker.sh

# Install osquery
./install-osquery.sh

## Manual replacement of conf files (in conf folder) for osquery
copy conf folder to root directory and replace the following two files (by running commands in install-osquery.sh (cp)):<br />
file-asscess.conf and osquery.conf

## Commented out (because they check the status of osquery, which is also available in check-status.sh):
journalctl -fu osqueryd<br />
tail -f /var/log/osquery/osqueryd.results.log

# install bro
./install-bro.sh
## Manual replacement of conf files (in conf folder) for bro
copy conf folder to root directory and replace the following files (by running commands in install-bro.sh (cp)):<br />
node.cfg<br />
local.bro<br />
dns-bad_behavior.bro<br />
json-logs.bro<br />
networks.cfg
## Notes:
node.cfg: may need to change network interface: choose from available ones: e.g. enp0s3, ens3, eth0, etc. (Use ifconfig to check.)

# install filebeat
./install-filebeat.sh
## Manual replacement of conf files (in conf folder) for filebeat
copy conf folder to root directory and replace the following files (by running commands in install-filebeat.sh (cp)):<br />
filebeat.yml<br />

## Check the status of filebeat
journalctl -fu filebeat

# install redis
./install-redis.sh

## Let Redis subscribe filebeat and check the status of redis
redis-cli<br />
> SUBSCRIBE filebeat<br />

redis-cli monitor

# install iodine
./install-iodine.sh

## iodined on server:
iodined -fP test 10.0.0.1 test.com

# install rootkit
./install-rootkit.sh

# equifax vulnerability
./install-equifax.sh

# After installation, need to manually start and check status (status checking also available in check-status.sh):
## osquery
(
osquery daemon is already started by ./install_osquery.sh:<br />
systemctl enable osqueryd<br />
systemctl restart osqueryd
)<br />
journalctl -fu osqueryd<br />
tail -f /var/log/osquery/osqueryd.results.log<br />
(ctrl+c to exit)
## bro
export PATH=$PATH:/opt/bro/bin<br />
cd /opt/bro/bin<br />
broctl<br />
> deploy<br />
> restart<br />
> status
## filebeat
(
filebeat is already started by ./filebeat.sh:<br />
systemctl enable filebeat<br />
systemctl restart filebeat
)<br />
journalctl -fu filebeat<br />
(ctrl+c to exit)
## redis
redis-cli<br />
> SUBSCRIBE filebeat<br />

redis-cli monitor

## iodine
To start iodined on server:<br />
iodined -fP test 10.0.0.1 test.com

# Install knockd kernel module (in attack/rootkit folder) (Purpose: block port 53)
(as root) <br />
make build # will build knockd.ko kernel module<br />
insmod knockd.ko # will insert knockd.ko kernel module<br />
lsmod | grep knockd # to check if kncokd kernel module has been successfully inserted<br />
(<br />
whenever want to rebuild the kernel module:<br />
(as root)<br />
make clean<br />
make build<br />
)

# Monitor real-time attack tagger output (src/subscriberv3.py)
(suggest using tmux to split the terminal to observe the output of subscriberv3.py while executing the attacks)<br />
python3 subscriberv3.py
