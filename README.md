# Trac-LDAP-Apache

Created a secure integration of Apache and OpenLDAP for authenticating users in Trac Issue Tracker.

Also created a Dockerfile for Trac as there is no official docker image.

Used Apache mod_authnz_ldap and mod_auth_form for handling login/logout with session cookies.

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

