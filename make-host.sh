#!/usr/bin/env sh

SCRIPT_DIR=$(cd "$(dirname "$0")"; pwd)
cd "$SCRIPT_DIR"

NAME="$1"
while [ -z "$NAME" ] ; do
    if [ -z "$NAME" ] ; then
        echo "PLease set vitualhost name. (HTTPS is supported for *.cc domains by default)"
        printf "Virtualhost : "
        read NAME
    fi
done

HTTPS_ON=1
# Check an ability to use exists SSL certificate
if [[ ! "$NAME" =~ .+\.cc$ ]] ; then
    echo "Notice: HTTPS is allowed for *.cc domains. HTTPS NginX configuration won't be created."
    printf "Would you like to continue? (yes|no) [no] : "
    read answer
    case "$answer" in
    yes | y)
        HTTPS_ON=0
        break ;; # continue setup
    *)
        echo "Interapted!"
        exit 1 ;;
    esac
fi

PROJECT_ROOT="/var/www/""$NAME"


# Make NGinX configuration files by templates
cp magento.conf "$NAME".conf
sed -i "s/virtualhost/""$NAME""/g" "$NAME".conf
if [ "$HTTPS_ON" = "1" ] ; then
    cp magento.ssl.conf "$NAME".ssl.conf
    sed -i "s/virtualhost/""$NAME""/g" "$NAME".ssl.conf
fi
sudo mv "$NAME".conf /etc/nginx/conf.d/
sudo mv "$NAME".ssl.conf /etc/nginx/conf.d/

echo "NginX configuration files has been created in file/s:"
find /etc/nginx/conf.d/ -name "$NAME.*"

# Create project dir
mkdir -p "$PROJECT_ROOT"
echo "Project directory: $PROJECT_ROOT"

# Restrart server
sudo service nginx restart
sudo service php-fpm restart
echo "Project domain: http://$NAME/"

# Add local host
TEST=$(cat /etc/hosts | grep " $NAME " 2>&1)
if [ "$TEST" ] ; then
    echo "Notice: Virtualhost already added."
else
    cp /etc/hosts ./
    echo "127.0.0.1 $NAME " >> ./hosts
    sudo cp ./hosts /etc/hosts
    echo "/etc/hosts file has been updated."
fi
echo "Installing domain '$NAME' has been finished!"
echo "Please add domain '$NAME' into your system 'hosts' file."

# Set up crontab for Magento
printf "Install crontab for $NAME (yes|no) [no] : "
read answer
case "$answer" in
    no | n | "") break ;;
    yes | y)
        CRONTABS=$(crontab -l 2>&1)
        # Check empty tabs
        TEST=$(echo "$CRONTABS" | grep "no crontab" 2>&1)
        if [ "$TEST" ] ; then
            CRONTABS=""
        fi
        # Check already added tab
        TEST=$(echo "$CRONTABS" | grep "/$NAME/cron" 2>&1)
        if [ "$TEST" ] ; then
            echo "Notice: Crontab already added."
        else
            # Add new tab
            echo "$CRONTABS" > cron-update
            echo "# Domain $NAME" >> cron-update
            echo "*/10 * * * * php /var/www/$NAME/cron.php" >> cron-update
            crontab cron-update
            rm cron-update
        fi
        break
        ;;
esac

# Install magento
if [ -d "/var/www/magento/vendor/onepica/magento/" ] ; then
    printf "Would you like to install Magento (yes|no) [no] : "
    read answer
    case "$answer" in
        yes | y)
            cp -R /var/www/magento/vendor/onepica/magento/* /var/www/"$NAME"/
            mageshell -p "$NAME"
            break
            ;;
    esac
else
    echo "No Magento source files by path /var/www/magento/vendor/onepica/magento/.";
    echo "Installation cannot be suggested.";
fi
