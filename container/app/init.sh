
# Start apache
httpd -k start

# Initalise subversion database without sample data if no subversion repository can be found.
# We cannot do this in the containerfile as it would require to bind httpd to to port 80
if [ ! -f "/opt/polarion/data/svn/passwd" ]; then
    /opt/polarion/bin/polarion.init init
fi

# When starting the polarion process via:
#/opt/polarion/bin/polarion.init start
# a lot of other stuff is happening. I don't really get what  that is for,
# but the essential stuff seems to be this:

/opt/polarion/bin/java-run.sh -server -Xms512m -Xmx512m -XX:+UseG1GC \
    -XX:+HeapDumpOnOutOfMemoryError \
    -XX:-OmitStackTraceInFastThrow \
    -Dosgi.parentClassloader=ext  '-Dcom.polarion.propertyFile=/opt/polarion/etc/polarion.properties' '-Dcom.polarion.logs.main=/opt/polarion/data/logs/main' '-cp' '/opt/polarion/polarion/startup.jar' 'org.eclipse.core.launcher.Main' '-nosplash' '-data' '/opt/polarion/data/workspace' '-configuration' '/opt/polarion/data/workspace/.config'  2>&1 #>> /var/log/polarion/polarion.log 2>&1

# Todo: Some logic to handle container shutdown here...