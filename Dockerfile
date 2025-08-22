
FROM ubuntu:noble

ENV TRAC_ADMIN_NAME="admin"
ENV TRAC_PROJECT_NAME="trac_project"
ENV TRAC_DIR="/var/local/trac"
ENV TRAC_INI="$TRAC_DIR/conf/trac.ini"
ENV DB_LINK="sqlite:db/trac.db"
EXPOSE 8123

# Install Apache, mod_wsgi, and LDAP modules
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    python3 nano iputils-ping \
    python3-pip \
    apache2 \
    libapache2-mod-wsgi-py3 \
    libapache2-mod-ldap-userdir \
    ldap-utils build-essential python3-dev \
    libldap2-dev libsasl2-dev slapd ldap-utils tox \
    lcov valgrind && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* && \
    rm -rf /tmp/* /var/tmp/*

# Apache modules
RUN a2enmod ldap authnz_ldap auth_basic wsgi headers && \
    echo "ServerName localhost" > /etc/apache2/conf-available/servername.conf && \
    a2enconf servername && \
    echo "Listen 8123" >> /etc/apache2/ports.conf

RUN a2enmod session && \
    a2enmod session_cookie && \
    a2enmod session_crypto && \
    a2enmod request && \
    a2enmod auth_form && \
    a2enmod filter && \
    a2enmod substitute && \
    apache2ctl configtest


RUN pip3 install Babel Trac TracAccountManager --break-system-packages


RUN mkdir -p $TRAC_DIR && \
    trac-admin $TRAC_DIR initenv $TRAC_PROJECT_NAME $DB_LINK && \
    trac-admin $TRAC_DIR deploy /tmp/deploy && \
    mv /tmp/deploy/* $TRAC_DIR && \
    trac-admin $TRAC_DIR permission add $TRAC_ADMIN_NAME TRAC_ADMIN


RUN chown -R www-data: $TRAC_DIR && chmod -R 775 $TRAC_DIR

# Add site config
COPY trac.conf /etc/apache2/sites-available/trac.conf

COPY logout-complete.html /var/www/html/logout-complete.html
COPY login.html /var/www/html/login.html


RUN tee /etc/apache2/conf-available/ldap-tuning.conf > /dev/null <<'EOF'
LDAPSharedCacheSize 0
LDAPCacheEntries 0
LDAPCacheTTL 0
LDAPOpCacheEntries 0
LDAPOpCacheTTL 0
LDAPConnectionTimeout 3
LDAPTimeout 3
LDAPConnectionPoolTTL 15
EOF
RUN a2enconf ldap-tuning

COPY trac.ini /tmp/trac.ini
COPY trac.ini $TRAC_DIR/conf/trac.ini
# COPY cse_wnr.png /tmp/trac_logo.png
COPY logo.png $TRAC_DIR/htdocs/trac_logo.png


RUN chown -R www-data:www-data /var/local/trac && \
    find /var/local/trac -type d -exec chmod 775 {} \; && \
    find /var/local/trac -type f -exec chmod 664 {} \;



# Replace vars in Apache config
RUN sed -i 's|$AUTH_NAME|'"$TRAC_PROJECT_NAME"'|g' /etc/apache2/sites-available/trac.conf && \
    sed -i 's|$TRAC_DIR|'"$TRAC_DIR"'|g' /etc/apache2/sites-available/trac.conf

# Enable required modules and site
RUN a2enmod ldap authnz_ldap && \
    a2dissite 000-default && \
    a2ensite trac.conf

# CMD service apache2 stop && apache2ctl -D FOREGROUND
CMD ["apache2ctl", "-D", "FOREGROUND"]
