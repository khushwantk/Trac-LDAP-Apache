# Trac-LDAP-Apache

trac.ini : Trac's setting/config file

trac.conf: Apache config

Login/logout : Pages that will be loaded while login & logout

Setup:
- Compose up the OpenLDAP container
- Change the URL of OpenLDAP server in trac.conf
- Compose up Trac

## Debugging:

Check if OpenLDAP is reachable from Trac's container : ping ldap://openldap:389

trac-admin /var/local/trac session list

trac-admin /var/local/trac session delete u6

nano /var/local/trac/conf/trac.ini

nano /etc/apache2/sites-available/trac.conf

nano /var/www/html/login.html

tail -f /var/local/trac/log/trac.log

