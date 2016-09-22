These script files intended for [redbox-digital/magento-virtual-appliance VM](../../../../redbox-digital/magento-virtual-appliance)

# Installation

```
git clone git@github.com:andkirby/centos-scripts-mage.git ~/centos.scripts
```

## Generate SSL certificates
```
$ sudo mkdir /etc/nginx/cert
$ sudo openssl req -new -x509 -days 365 -sha1 -newkey rsa:1024 -nodes -keyout /etc/nginx/cert/cc.key -out /etc/nginx/cert/cc.crt -subj '/C=UA/ST=Kiev/L=Kiev/O=My Inc./OU=Department/CN=*.cc'
```

Copy nginx config with path to these certificate files.
```
sudo cp ~/centos.scripts/nginx/ssl.cc.conf /etc/nginx/conf/magento_ssl.conf
```

# Usage
## Make VirtualHost
```
sh ~/centos.scripts/make-host.sh some-domain.cc
```

## Install switcher status of XDebug in PHP
```
sh ~/centos.scripts/xd_swi_install.sh
```
And use it with command `xd_swi`.
