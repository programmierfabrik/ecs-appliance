# ECS-Appliance

the ecs appliance is a selfservice production setup virtual machine builder and executor.
it can be stacked on top of the developer vm, but is independend of it.

## installing on top of a existing machine

### upgrade your developer-vm

on your local machine:

+ insert your devserver name (eg. "testecs") into your /etc/hosts

```
sudo -s 'printf "%s" "127.0.0.1 testecs" >> /etc/hosts'
```

+ connect to your developer vm with port 80 and 443:

```
sudo -E ssh -F ~/.ssh/config testecs -L 80:localhost:80 -L 443:localhost:443 -L 8050:localhost:8050
```

inside the developer vm:

+ install appliance

```
# clone appliance code
git clone ssh://git@gogs.omoikane.ep3.at:10022/ecs/ecs-appliance.git /app/appliance
# install saltstack
curl -o /app/bootstrap_salt.sh -L https://bootstrap.saltstack.com
sudo bash -c "mkdir -p /etc/salt; cp /app/appliance/salt/minion /etc/salt/minion; \
    chmod +x /app/bootstrap_salt.sh; /app/bootstrap_salt.sh -X; \
    systemctl stop salt-minion; systemctl disable salt-minion"
# execute appliance install
sudo salt-call state.highstate pillar='{"appliance": {"enabled": true}}'
```

if you also want the builder (for building the appliance image) installed:

```
sudo salt-call state.highstate pillar='{"builder": {"enabled": true}, "appliance": {"enabled": true}}'
```

### upgrade your xenial desktop

it is the same procedure as with the developer vm,
but be aware that the appliance takes over the following services:

+ postgresql config, postgres user "app" and database "ecs"
  + set password of user ecs for tcp connect to postgresql
  + does not drop any data, unless told
+ docker and docker container (stops all container at salt-call state.highstate, expects docker0 to be the default docker bridge with default ip values)
+ nginx configuration
+ postfix configuration
+ listens to port 25,80,443,465


## configure appliance

### make a new environment config file
+ make a new env.yml: `generate-new-env.sh testecs /app/env.yml`
+ edit your settings in /app/env.yml

## start appliance
+ start appliance: `sudo systemctl start appliance`
+ open your browser and go to: http://testecs or http://localhost
+ stop appliance: `sudo systemctl stop appliance`

### commands of interest

+ quick update appliance:
    + `cd ~/appliance; git pull; sudo salt-call state.highstate pillar='{"appliance": "enabled": true}}'`
+ standard update appliance `sudo update-appliance` (~ git pull , state.highstate, restart)
+ update ecs `sudo update-ecs`
+ enter a running ecs container:
  + `sudo docker exec -it ecs_image[.startcommand]_1 /bin/bash`
  + image = ecs, mocca pdfas memcached redis
  + ecs .startcommand = web worker beat smtpd
+ enter a django shell_plus in a running (eg. ecs_ecs.web_1) container:
  + `sudo docker exec -it ecs_ecs.web_1 /start run ./manage.py shell_plus`
+ run a new django shell `sudo docker-compose -f /etc/appliance/ecs/docker-compose.yml run --no-deps ecs.web run ./manage.py shell_plus`
+ follow the appliance log file (including web,beat,worker,smtp,redis,memcached,pdfas,mocca):
    + `sudo journalctl -u appliance -f`
+ look at the last things happened in the journal: `sudo journalctl -xe`


+ read container details in yaml `docker inspect 1b17069fe3ba | python -c 'import sys, yaml, json; yaml.safe_dump(json.load(sys.stdin), sys.stdout, default_flow_style=False)' | less`
+ look at all appliance http status pages: `git grep "\(noupdate\|appliance\)_\(exit\|status\)"  | grep '"' | sed -re 's/[^"]+"(.*)/\1/g' | sort`
+ line and word count appliance:

```
wc `find . -regex ".*\.\(sls\|yml\|sh\|json\|conf\|template\|include\|md\|service\|identity\)" `
```


### files of interest

Path | Description
--- | ---
/pillar/                    | salt environment
/pillar/top.sls             | defines the root of the environment tree
/pillar/default-env.sls     | fallback env yaml and example localhost ecs config
/salt/*.sls                 | states (to be executed)
/salt/top.sls               | defines the root of the state tree
/salt/common/init.sls       | common install
/salt/appliance/init.sls    | ecs appliance install
/salt/appliance/appliance.service    | systemd appliance service (starts prepare and docker-compose)
/salt/appliance/prepare-appliance.sh | script started on ready to run appliance
/salt/appliance/prepare-ecs.sh       | script startet after prepare_appliance


### Environment

#### Buildtime Environment Usage

* salt-call state.highstate (the install part) does not need an environment, but has a default one

#### VM Runtime Environment Usage
* prepare-appliance tries to get a environment yaml from all local and network sources
  * writes the filtered result ("ecs,appliance") to /app/active-env.yml
  * Storage Setup (`salt-call state.sls storage.sls`) expects /app/active-env.yml
* prepare-ecs and the appliance.service both parse /app/active-env.yml
* appliance.service calls docker-compose up with active-env
  * docker compose passes the following to the ecs/ecs* container
      * service_urls.env,
      * ECS_SETTINGS, ECS_VAULT_SIGN, ECS_VAULT_ENCRYPT
  * docker compose passes APPLIANCE_DOMAIN as HOSTNAME to mocca and pdfas


## Builder

appliance gets build using packer.

`vagrant up` installs all packages needed for builder

add on top of developer-vm or appliance update:
`sudo salt-call state.highstate pillar='{"builder": "enabled": true}}'`


### Partitioning

+ default xenial cloud image partition layout:
    + dos-mbr
    + p1 Boot ext4 label cloudimg-rootfs (10G)
    + used space ~ 900MB naked , ~ 1700MB with ecs appliance (currently, will grow)

+ developer setup:
    + vagrantfile has grow-root baked into it, p1 will take all space, appliance will not create additional partitions
    + storage setup will create the directories but do not expect a mountpoint

+ production setup:
    + storage.setup will (if told in env.yml):
        + add p2 (all usable space) as pv-lvm
        + add a vg and volumes ecs-data (60%) ecs-volatile (30%), rest is for snapshots
