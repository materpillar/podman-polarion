FROM rockylinux:8.6


RUN dnf install -y \
    # for setting the right locales in the rockylinux image:
    glibc-langpack-en \
    # prerequisistes that automated installation will not install:
    java-11-openjdk-devel iproute\
    # Automated installation installs the following packages:
    expect tcl fontconfig\
    httpd subversion mod_dav_svn \
    postgresql postgresql-contrib\
    # server shouldn't be needed if it is running in a different container, but also manual installation will fail if we leave it out.
    postgresql-server \
    # epel for supervisor package
    epel-release && \
    dnf install -y supervisor && \
    dnf remove -y epel-release && dnf clean all

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

COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf

WORKDIR /workspace
COPY init.sh /workspace/
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]