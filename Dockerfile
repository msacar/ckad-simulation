# Use Ubuntu 18.04 as the base image
FROM ubuntu:18.04

# Prevent interactive prompts during package installation
ENV DEBIAN_FRONTEND=noninteractive
ENV LANG=tr_TR.UTF-8
ENV LANGUAGE=tr_TR:en
ENV LC_ALL=tr_TR.UTF-8


# Install necessary packages (including tightvncserver, X11, etc.)
RUN apt-get update && apt-get install -y \
    xfce4 \
    xfce4-goodies \
    tightvncserver \
    supervisor \
    wget \
    firefox \
    curl \
    git \
    nano \
    vim \
    dbus-x11 \
    x11-xserver-utils \
    xauth \
    xfonts-base \
    xfonts-75dpi \
    xfonts-100dpi \
    libxrender1 \
    libxext6 \
    libxft2 \
    gtk2-engines-pixbuf \
    xfce4-terminal \
    locales console-common console-data console-setup \
    tor \
    gnupg2 \
    apt-transport-https \
    && apt-get clean && rm -rf /var/lib/apt/lists/*


RUN apt-get update && \
    apt-get install -y python3 python3-pip && \
    pip3 install --upgrade pip && \
    pip3 install cython && \
    pip3 install numpy && \
    apt-get clean && rm -rf /var/lib/apt/lists/*


# Generate the Turkish locale (e.g. tr_TR.UTF-8)
RUN sed -i 's/# tr_TR.UTF-8 UTF-8/tr_TR.UTF-8 UTF-8/' /etc/locale.gen && \
    locale-gen

# Create non-root user 'vncuser' with a home directory
RUN useradd -m -s /bin/bash vncuser

# If you need sudo for this user, you can install sudo and add it:
RUN apt-get update && apt-get install -y sudo && \
    echo "vncuser ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# Switch to non-root user
USER vncuser

# Set HOME environment variable for the new user
ENV USER=vncuser
ENV HOME=/home/vncuser
WORKDIR /home/vncuser

# Create the .vnc directory, set VNC password, and create xstartup
# Replace 'YOUR_VNC_PASSWORD' with a secure password
RUN mkdir -p /home/vncuser/.vnc && \
    echo "YOUR_VNC_PASSWORD" | vncpasswd -f > /home/vncuser/.vnc/passwd && \
    chmod 600 /home/vncuser/.vnc/passwd && \
    echo "#!/bin/bash\n\
unset SESSION_MANAGER\n\
unset DBUS_SESSION_BUS_ADDRESS\n\
setxkbmap -layout tr\n\
xrdb \$HOME/.Xresources\n\
startxfce4 &" > /home/vncuser/.vnc/xstartup && \
    chmod +x /home/vncuser/.vnc/xstartup

# (Optional) Ensure an empty .Xresources exists
RUN touch /home/vncuser/.Xresources

# Switch back to root to install noVNC, Supervisor config, etc. if needed
USER root

# Install noVNC (as root)
RUN wget https://github.com/novnc/noVNC/archive/refs/tags/v1.3.0.tar.gz && \
    tar -xvzf v1.3.0.tar.gz && \
    mv noVNC-1.3.0 /opt/noVNC && \
    rm v1.3.0.tar.gz && \
    chown -R vncuser:vncuser /opt/noVNC

# 6. Set the Default Terminal Emulator to xfce4-terminal
RUN update-alternatives --install /usr/bin/x-terminal-emulator x-terminal-emulator /usr/bin/xfce4-terminal 50 && \
    update-alternatives --set x-terminal-emulator /usr/bin/xfce4-terminal
# Copy Supervisor configuration
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# Set ownership if the config needs to be owned by root or left as is
# For logs, if any, ensure directories are created and set with proper perms

# Expose VNC and noVNC ports
EXPOSE 5901 6080

COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

CMD ["/usr/local/bin/entrypoint.sh"]
