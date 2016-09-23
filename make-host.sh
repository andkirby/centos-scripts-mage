#!/usr/bin/env sh

SCRIPT_DIR=$(cd "$(dirname "$0")"; pwd)
cd "${SCRIPT_DIR}"
readonly SCRIPT_DIR

name="$1"
while [ -z "${name}" ] ; do
    if [ -z "${name}" ] ; then
        echo "PLease set vitualhost name. (HTTPS is supported for *.cc domains by default)"
        printf "Virtualhost : "
        read name
    fi
done

https_on=1
# Check an ability to use exists SSL certificate
if [[ ! "${name}" =~ .+\.cc$ ]] ; then
    echo "notice: HTTPS is allowed for *.cc domains. HTTPS NginX configuration won't be created."
    printf "Would you like to continue? (yes|no) [no] : "
    read answer
    case "${answer}" in
    yes | y)
        https_on=0
        break ;; # continue setup
    *)
        echo "Interrupted!"
        exit 1 ;;
    esac
fi

project_root="/var/www/""${name}"

# Make NGinX configuration files by templates
cp magento.conf "${name}".conf
sed -i "s/virtualhost/""${name}""/g" "${name}".conf
if [ "${https_on}" = "1" ] ; then
    # Install SSL
    if [ ! -f /etc/nginx/conf/magento_ssl.conf ]; then
        sudo cp ${SCRIPT_DIR}/nginx/ssl.cc.conf /etc/nginx/conf/magento_ssl.conf
        sudo mkdir /etc/nginx/cert
        sudo openssl req -new -x509 -days 365 -sha1 -newkey rsa:1024 -nodes -keyout /etc/nginx/cert/cc.key \
            -out /etc/nginx/cert/cc.crt -subj '/C=UA/ST=Kiev/L=Kiev/O=My Inc./OU=Department/CN=*.cc'
    fi
    cp magento.ssl.conf "${name}".ssl.conf
    sed -i "s/virtualhost/""${name}""/g" "${name}".ssl.conf
    sudo mv "${name}".ssl.conf /etc/nginx/conf.d/
fi
sudo mv "${name}".conf /etc/nginx/conf.d/

echo "Nginx configuration files has been created in file/s:"
find /etc/nginx/conf.d/ -name "${name}.*"

# Create project dir
sudo mkdir -p "${project_root}" || exit 1
sudo chown vagrant:vagrant "${project_root}"
echo "Project directory: ${project_root}"

# Restart nginx server
sudo service nginx restart
echo "Project domain: http://${name}/"

# Add local host
test=$(cat /etc/hosts | grep " ${name} " 2>&1)
if [ "${test}" ] ; then
    echo "notice: VirtualHost already added."
else
    sudo bash -c 'echo "127.0.0.1 '${name}'" >> /etc/hosts'
    echo "/etc/hosts file has been updated."
fi
echo "Installing domain '${name}' has been finished!"
echo "Please add domain '${name}' into your system '/etc/hosts' file."

# Install crontab
if [ -f "/var/www/${name}/cron.php" ]; then
    # Set up crontab for Magento
    printf "Install crontab for ${name} (yes|no) [no] : "
    read answer
    case "${answer}" in
        no | n | "") break ;;
        yes | y)
            cron_tabs=$(crontab -l 2>&1)
            # Check empty tabs
            test=$(echo "${cron_tabs}" | grep "no crontab" 2>&1)
            if [ "${test}" ] ; then
                cron_tabs=""
            fi
            # Check already added tab
            test=$(echo "${cron_tabs}" | grep "/${name}/cron" 2>&1)
            if [ "${test}" ] ; then
                echo "notice: crontab already added."
            else
                # Add new tab
                echo "${cron_tabs}" > cron-update
                echo "# Domain ${name}" >> cron-update
                echo "*/10 * * * * php /var/www/${name}/cron.php" >> cron-update
                crontab cron-update
                rm cron-update
            fi
            break
            ;;
    esac
fi
