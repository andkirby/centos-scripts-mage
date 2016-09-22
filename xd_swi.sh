#!/usr/bin/env bash
# Download this gist into file "~/.xd_swi"
#    curl -Ls https://gist.github.com/andkirby/8db337ea6495951e6f952005ce7c170b/raw/.xd_swi -o ~/.xd_swi
# And run:
#    ~/.xd_swi

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

match_string=$(cat ${file_ini} | grep -Eo 'zend_extension=.*xdebug')
if [ -z ${match_string} ]; then
        echo "There is no declaration about xdebug PHP extension."
        exit 1
fi

is_on=$(php -i | grep 'xdebug support => enabled' 2>&1);
if [ -n "${is_on}" ] ; then
    find="${match_string}"
        replace=";${match_string}"
else
        find=";${match_string}"
        replace="${match_string}"
fi

sudo sed -i.bak "s|${find}|${replace}|g" ${file_ini}
echo -e '\e[0;33m'$(php -i | grep 'xdebug support => enabled' 2>&1 || echo xdebug disabled)'\e[0m'
exit 0
