# centos-scripts-mage

These script files intended for [redbox-digital/magento-virtual-appliance VM](../../../../redbox-digital/magento-virtual-appliance)

# Installation

```
git clone git@github.com:andkirby/centos-scripts-mage.git ~/centos.scripts
```

## Generate SSL certificates
```
$ sudo mkdir /etc/nginx/cert && cd /etc/nginx/cert
$ sudo openssl req -new -x509 -days 365 -sha1 -newkey rsa:1024 -nodes -keyout cc.key -out cc.crt -subj '/C=UA/ST=Kiev/L=Kiev/O=My Inc./OU=Department/CN=*.cc'
```

# Usage
## Make VirtualHost
```
~/centos.scripts/make-host.sh some-domain.cc
```

## Switch status of XDebug in PHP
```
~/centos.scripts/xd_swi.sh
```
