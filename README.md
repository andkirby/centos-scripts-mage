# centos-scripts-mage

These script files intended for [redbox-digital/magento-virtual-appliance VM](../../../../redbox-digital/magento-virtual-appliance)

# Installation

```
git clone git@github.com:andkirby/centos-scripts-mage.git ~/centos.scripts
sudo cp ~/centos.scripts/magento.ssl.conf /etc/nginx/conf/magento_ssl.conf
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
