#!/bin/bash

# Ensure the script is run as root
if [ "$(id -u)" -ne 0 ]; then
  echo "This script must be run as root." >&2
  exit 1
fi

# Path to the cPanel configuration file
CPANEL_CONFIG_FILE="/etc/cpupdate.conf"

# Backup the current configuration file
cp "$CPANEL_CONFIG_FILE" "${CPANEL_CONFIG_FILE}.bak"

# Function to update the configuration file
deactivate_fork_bomb_protection() {
  sed -i 's/ENABLE_FORKBOMB_PROTECT=1/ENABLE_FORKBOMB_PROTECT=0/' "$CPANEL_CONFIG_FILE"
}

# Call the function to update the configuration file
deactivate_fork_bomb_protection

# Restart necessary services to apply changes
service cpanel restart

echo "Shell fork bomb protection has been deactivated. Please verify the settings in WHM."

# Function to modify PHP configuration values for a given version
modify_php_config() {
    local php_version=$1
    local config_file="/opt/cpanel/ea-php${php_version}/root/etc/php.ini"

    sed -i '/disable_functions =/c\disable_functions = \"exec,passthru,shell_exec,system,proc_open,popen,show_source\"' $config_file
    sed -i '/open_basedir =/c\open_basedir = \"\/home:\/usr\/lib\/php:\/usr\/local\/lib\/php:\/tmp:\/var\/cpanel\/php\/sessions\/ea-php'"${php_version}"':\/usr\/local\/lsws\"' $config_file
    sed -i '/max_execution_time/c\max_execution_time = 3600' $config_file
    sed -i '/max_input_time/c\max_input_time = 3600' $config_file
    sed -i '/max_input_vars/c\max_input_vars = 10000' $config_file
    sed -i '/memory_limit/c\memory_limit = 2048M' $config_file
    sed -i '/upload_max_filesize/c\upload_max_filesize = 512M' $config_file
    sed -i '/post_max_size/c\post_max_size = 1024M' $config_file
    sed -i '/date.timezone = /c\date.timezone = \"Europe\/Bucharest\"' $config_file
    sed -i '/allow_url_fopen =/c\allow_url_fopen = On' $config_file
    sed -i '/display_errors =/c\display_errors = On' $config_file

    echo "Configurations updated for PHP $php_version"
}

# Loop through PHP versions including 5.4 to 5.6, 7.0 to 7.4, and 8.0 to 8.3
for php_version in 54 55 56 {70..74} {80..83}; do
    modify_php_config "$php_version"
done

# Define file paths for the cPanel profile update
backup_file="/etc/cpanel/ea4/profiles/cpanel/allphp-opcache.json.backup"
target_file="/etc/cpanel/ea4/profiles/cpanel/allphp-opcache.json"

# Backup the target file
cp "$target_file" "$backup_file"

# Create the new JSON content
new_json='{
    "version": 0.9,
    "desc": "This is the MPM Worker cPanel profile plus every supported PHP version and each version’s options (sans recode and zendguard due to incompatibilities). This package can host multiple sites and users.",
    "name": "All PHP Options + OpCache",
    "tags": [
        "All PHP Opts",
        "Apache 2.4",
        "PHP 8.1",
        "PHP 8.2"
    ],
    "pkgs": [
        "ea-apache24",
        "ea-apr",
        "ea-apr-util",
        "ea-apache24-mod_mpm_worker",
        "ea-apache24-mod_ssl",
        "ea-apache24-mod_deflate",
        "ea-apache24-mod_expires",
        "ea-apache24-mod_headers",
        "ea-apache24-mod_proxy",
        "ea-apache24-mod_cgid",
        "ea-apache24-mod_suexec",
        "ea-apache24-mod_suphp",
        "ea-apache24-mod_security2",
        "ea-apache24-mod_proxy_fcgi",
        "ea-php72",
        "ea-php72-php-bcmath",
        "ea-php72-php-bz2",
        "ea-php72-php-calendar",
        "ea-php72-php-cli",
        "ea-php72-php-common",
        "ea-php72-php-curl",
        "ea-php72-php-dba",
        "ea-php72-php-devel",
        "ea-php72-php-enchant",
        "ea-php72-php-exif",
        "ea-php72-php-fileinfo",
        "ea-php72-php-fpm",
        "ea-php72-php-ftp",
        "ea-php72-php-gd",
        "ea-php72-php-gettext",
        "ea-php72-php-gmp",
        "ea-php72-php-iconv",
        "ea-php72-php-imap",
        "ea-php72-php-intl",
        "ea-php72-php-ldap",
        "ea-php72-php-mbstring",
        "ea-php72-php-mysqlnd",
        "ea-php72-php-odbc",
        "ea-php72-php-opcache",
        "ea-php72-php-pdo",
        "ea-php72-php-pgsql",
        "ea-php72-php-posix",
        "ea-php72-php-process",
        "ea-php72-php-pspell",
        "ea-php72-php-snmp",
        "ea-php72-php-soap",
        "ea-php72-php-sockets",
        "ea-php72-php-tidy",
        "ea-php72-php-xml",
        "ea-php72-php-zip",
        "ea-php72-runtime",
        "ea-php73",
        "ea-php73-php-bcmath",
        "ea-php73-php-bz2",
        "ea-php73-php-calendar",
        "ea-php73-php-cli",
        "ea-php73-php-common",
        "ea-php73-php-curl",
        "ea-php73-php-dba",
        "ea-php73-php-devel",
        "ea-php73-php-enchant",
        "ea-php73-php-exif",
        "ea-php73-php-fileinfo",
        "ea-php73-php-fpm",
        "ea-php73-php-ftp",
        "ea-php73-php-gd",
        "ea-php73-php-gettext",
        "ea-php73-php-gmp",
        "ea-php73-php-iconv",
        "ea-php73-php-imap",
        "ea-php73-php-intl",
        "ea-php73-php-ldap",
        "ea-php73-php-mbstring",
        "ea-php73-php-mysqlnd",
        "ea-php73-php-odbc",
        "ea-php73-php-opcache",
        "ea-php73-php-pdo",
        "ea-php73-php-pgsql",
        "ea-php73-php-posix",
        "ea-php73-php-process",
        "ea-php73-php-pspell",
        "ea-php73-php-snmp",
        "ea-php73-php-soap",
        "ea-php73-php-sockets",
        "ea-php73-php-tidy",
        "ea-php73-php-xml",
        "ea-php73-php-zip",
        "ea-php73-runtime",
        "ea-php74",
        "ea-php74-php-bcmath",
        "ea-php74-php-bz2",
        "ea-php74-php-calendar",
        "ea-php74-php-cli",
        "ea-php74-php-common",
        "ea-php74-php-curl",
        "ea-php74-php-dba",
        "ea-php74-php-devel",
        "ea-php74-php-enchant",
        "ea-php74-php-exif",
        "ea-php74-php-fileinfo",
        "ea-php74-php-fpm",
        "ea-php74-php-ftp",
        "ea-php74-php-gd",
        "ea-php74-php-gettext",
        "ea-php74-php-gmp",
        "ea-php74-php-iconv",
        "ea-php74-php-imap",
        "ea-php74-php-intl",
        "ea-php74-php-ldap",
        "ea-php74-php-mbstring",
        "ea-php74-php-mysqlnd",
        "ea-php74-php-odbc",
        "ea-php74-php-opcache",
        "ea-php74-php-pdo",
        "ea-php74-php-pgsql",
        "ea-php74-php-posix",
        "ea-php74-php-process",
        "ea-php74-php-pspell",
        "ea-php74-php-snmp",
        "ea-php74-php-soap",
        "ea-php74-php-sockets",
        "ea-php74-php-tidy",
        "ea-php74-php-xml",
        "ea-php74-php-zip",
        "ea-php74-runtime",
        "ea-php80",
        "ea-php80-php-bcmath",
        "ea-php80-php-bz2",
        "ea-php80-php-calendar",
        "ea-php80-php-cli",
        "ea-php80-php-common",
        "ea-php80-php-curl",
        "ea-php80-php-dba",
        "ea-php80-php-devel",
        "ea-php80-php-enchant",
        "ea-php80-php-exif",
        "ea-php80-php-fileinfo",
        "ea-php80-php-fpm",
        "ea-php80-php-ftp",
        "ea-php80-php-gd",
        "ea-php80-php-gettext",
        "ea-php80-php-gmp",
        "ea-php80-php-iconv",
        "ea-php80-php-imap",
        "ea-php80-php-intl",
        "ea-php80-php-ldap",
        "ea-php80-php-mbstring",
        "ea-php80-php-mysqlnd",
        "ea-php80-php-odbc",
        "ea-php80-php-opcache",
        "ea-php80-php-pdo",
        "ea-php80-php-pgsql",
        "ea-php80-php-posix",
        "ea-php80-php-process",
        "ea-php80-php-pspell",
        "ea-php80-php-snmp",
        "ea-php80-php-soap",
        "ea-php80-php-sockets",
        "ea-php80-php-tidy",
        "ea-php80-php-xml",
        "ea-php80-php-zip",
        "ea-php80-runtime",
        "ea-php81",
        "ea-php81-php-bcmath",
        "ea-php81-php-bz2",
        "ea-php81-php-calendar",
        "ea-php81-php-cli",
        "ea-php81-php-common",
        "ea-php81-php-curl",
        "ea-php81-php-dba",
        "ea-php81-php-devel",
        "ea-php81-php-enchant",
        "ea-php81-php-exif",
        "ea-php81-php-fileinfo",
        "ea-php81-php-fpm",
        "ea-php81-php-ftp",
        "ea-php81-php-gd",
        "ea-php81-php-gettext",
        "ea-php81-php-gmp",
        "ea-php81-php-iconv",
        "ea-php81-php-imap",
        "ea-php81-php-intl",
        "ea-php81-php-ldap",
        "ea-php81-php-mbstring",
        "ea-php81-php-mysqlnd",
        "ea-php81-php-odbc",
        "ea-php81-php-opcache",
        "ea-php81-php-pdo",
        "ea-php81-php-pgsql",
        "ea-php81-php-posix",
        "ea-php81-php-process",
        "ea-php81-php-pspell",
        "ea-php81-php-snmp",
        "ea-php81-php-soap",
        "ea-php81-php-sockets",
        "ea-php81-php-tidy",
        "ea-php81-php-xml",
        "ea-php81-php-zip",
        "ea-php81-runtime",
        "ea-php82",
        "ea-php82-php-bcmath",
        "ea-php82-php-bz2",
        "ea-php82-php-calendar",
        "ea-php82-php-cli",
        "ea-php82-php-common",
        "ea-php82-php-curl",
        "ea-php82-php-dba",
        "ea-php82-php-devel",
        "ea-php82-php-enchant",
        "ea-php82-php-exif",
        "ea-php82-php-fileinfo",
        "ea-php82-php-fpm",
        "ea-php82-php-ftp",
        "ea-php82-php-gd",
        "ea-php82-php-gettext",
        "ea-php82-php-gmp",
        "ea-php82-php-iconv",
        "ea-php82-php-imap",
        "ea-php82-php-intl",
        "ea-php82-php-ldap",
        "ea-php82-php-mbstring",
        "ea-php82-php-mysqlnd",
        "ea-php82-php-odbc",
        "ea-php82-php-opcache",
        "ea-php82-php-pdo",
        "ea-php82-php-pgsql",
        "ea-php82-php-posix",
        "ea-php82-php-process",
        "ea-php82-php-pspell",
        "ea-php82-php-snmp",
        "ea-php82-php-soap",
        "ea-php82-php-sockets",
        "ea-php82-php-tidy",
        "ea-php82-php-xml",
        "ea-php82-php-zip",
        "ea-php82-runtime"
    ]
}'

# Write the new JSON content to the target file
echo "$new_json" > "$target_file"

# Restart necessary services to apply changes
service cpanel restart

echo "PHP configuration and cPanel profile update complete. Please verify the settings."
