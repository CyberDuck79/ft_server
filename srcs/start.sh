
# Launch services
service mysql restart
/etc/init.d/php7.3-fpm start
service nginx restart

# endless loop to keep container running
tail -f /dev/null
