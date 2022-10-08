FROM rockylinux:8.6


RUN dnf install -y \
    # prerequisistes that automated installation will not install:
    java-11-openjdk-devel iproute\
    # not needed for automated installation:
    expect tcl \
    httpd postgresql-server postgresql postgresql-contrib \
    subversion mod_dav_svn fontconfig \
    # for setting the right locales:
    glibc-langpack-en

# Set the right locales
ENV LANG=en_US.UTF-8
ENV LOCALE=en_US.UTF-8

# Polarion user
RUN useradd -r polarion

# Copy install files and answer text file
COPY Polarion /workspace/Polarion
COPY install_manual.answers.txt /workspace/Polarion

# Install
RUN cp /workspace/Polarion/libinstall/predefined/redhat/etc/httpd/conf.d/* /etc/httpd/conf.d
WORKDIR /workspace/Polarion
RUN cat "install_manual.answers.txt" | ./manual_install.sh

# Fix permissions where the manual installer is messed up
RUN chown polarion /opt/polarion/etc/polarion.properties
RUN chmod u+rw /opt/polarion/etc/polarion.properties

# Configure Postgres
# https://docs.sw.siemens.com/en-US/product/230235217/doc/PL20210812782182305.linux_installation/html/xid1368400
RUN mkdir /opt/polarion/data/postgres-data
RUN chown postgres:postgres /opt/polarion/data/postgres-data
USER postgres
RUN initdb -D /opt/polarion/data/postgres-data -E utf8 --auth-host=md5
RUN pg_ctl -D /opt/polarion/data/postgres-data -l /opt/polarion/data/postgres-data/log.out -o "-p 5433" start && \
    psql postgres -U postgres -p 5433 -c "CREATE USER polarion WITH PASSWORD 'polarion' CREATEROLE;" && \
    psql postgres -U postgres -p 5433 -c "CREATE DATABASE polarion OWNER polarion ENCODING 'UTF8';" && \
    psql postgres -U postgres -p 5433 -c "CREATE DATABASE polarion_history OWNER polarion ENCODING 'UTF8';" && \
    psql polarion -U postgres -p 5433 -c "CREATE EXTENSION dblink;" && \
    psql polarion -U postgres -p 5433 -c "SELECT p.proname FROM pg_catalog.pg_namespace n JOIN pg_catalog.pg_proc p ON p.pronamespace = n.oid WHERE n.nspname = 'public';" && \
    psql polarion_history -U postgres -p 5433 -c "CREATE EXTENSION dblink;" && \
    psql polarion_history -U postgres -p 5433 -c "SELECT p.proname FROM pg_catalog.pg_namespace n JOIN pg_catalog.pg_proc p ON p.pronamespace = n.oid WHERE n.nspname = 'public';" && \
    pg_ctl -D /opt/polarion/data/postgres-data stop

USER root

WORKDIR /workspace
COPY init.sh /workspace/
CMD /workspace/init.sh