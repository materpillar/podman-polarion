#su -c "pg_ctl -D /opt/polarion/data/postgres-data -l /opt/polarion/data/postgres-data/log.out -o \"-p 5433\" start" - postgres
httpd -k start

# Initalise subversion database without sample data if no subversion repository can be found.
# We cannot do this in the containerfile as it would require to bind httpd to to port 80
if [ ! -f "/opt/polarion/data/svn/passwd" ]; then
    /opt/polarion/bin/polarion.init init
fi

/opt/polarion/bin/polarion.init start