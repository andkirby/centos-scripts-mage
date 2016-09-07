#!/usr/bin/env bash
# Download this gist into file "~/.xd_swi"
#    curl -Ls https://gist.github.com/andkirby/8db337ea6495951e6f952005ce7c170b/raw/.xd_swi -o ~/.xd_swi
# And run:
#    ~/.xd_swi

XD_ON=$(php -i | grep 'xdebug support => enabled' 2>&1);
if [ "$XD_ON" ] ; then
    FIND=""
	REPLACE=";"
else
	FIND=";"
	REPLACE=""
fi

file_ini=$(php -i | grep -Eo '(([A-Z]\:|/)[^ ]+)xdebug.ini')
if [ -z ${file_ini} ]; then
	file_ini=$(php -i | grep -Eo '(([A-Z]\:|/)[^ ]+)php.ini')
fi
if [ -z ${file_ini} ]; then
	echo 'There is no PHP ini file to edit.'
	exit 1
fi
if [ ! -f ${file_ini} ]; then
	echo "There is no ini file '${file_ini}' to edit."
	exit 1
fi

match_string='zend_extension = php_xdebug'
sed -i "s/""$FIND""${match_string}/""$REPLACE""${match_string}/g" ${file_ini}
php -i | grep 'xdebug support => enabled' 2>&1

######## xdebug config sample ########
: <<'sample'
zend_extension = php_xdebug-2.4.1-5.5-vc11-nts.dll
xdebug.remote_autostart = On
xdebug.remote_enable=1
xdebug.remote_mode=req
xdebug.remote_port=9000
xdebug.remote_host=127.0.0.1
xdebug.remote_connect_back=0
sample
