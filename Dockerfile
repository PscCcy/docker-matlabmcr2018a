FROM ubuntu:latest

###############################################################################################
MAINTAINER Ivan E. Cao-Berg <icaoberg@andrew.cmu.edu>
LABEL Description="Ubuntu 16.04 + MATLAB MCR 2018a"
LABEL Vendor="Murphy Lab in the Computational Biology Department at Carnegie Mellon University"
LABEL Web="http://murphylab.cbd.cmu.edu"
LABEL Version="2018a"
###############################################################################################

###############################################################################################
# UPDATE OS AND INSTALL TOOLS
USER root
ENV DEBIAN_FRONTEND noninteractive
RUN apt-get update && apt-get install -y --no-install-recommends apt-utils
RUN apt-get install -y build-essential git \
    unzip \
    xorg \
    wget \
    tree \
    pandoc \
    curl \
    vim
RUN apt-get upgrade -y
###############################################################################################

###############################################################################################
# INSTALL MATLAB MCR 2017 A
USER root
RUN echo "Downloading Matlab MCR 2017a"
RUN mkdir /mcr-install && \
    mkdir /opt/mcr
RUN cd /mcr-install && \
    wget -nc http://ssd.mathworks.com/supportfiles/downloads/R2018a/deployment_files/R2018a/installers/glnxa64/MCR_R2018a_glnxa64_installer.zip
    echo "Unzipping container" && \
    unzip -q MCR_R2017a_glnxa64_installer.zip && \
    ./install -destinationFolder /opt/mcr -agreeToLicense yes -mode silent && \
    cd / && \
    echo "Removing temporary files" && \
    rm -rvf mcr-install

# CONFIGURE ENVIRONMENT VARIABLES FOR MCR
RUN mv -v /opt/mcr/v94/sys/os/glnxa64/libstdc++.so.6 /opt/mcr/v94/sys/os/glnxa64/libstdc++.so.6.old
ENV LD_LIBRARY_PATH /opt/mcr/v94/runtime/glnxa64:/opt/mcr/v94/bin/glnxa64:/opt/mcr/v94/sys/os/glnxa64
ENV XAPPLRESDIR /opt/mcr/v94/X11/app-defaults
###############################################################################################

###############################################################################################
# INSTALL VIM
# CONFIGURE ENVIRONMENT
ENV DEBIAN_FRONTEND noninteractive
ENV SHELL /bin/bash
ENV USERNAME murphylab
ENV UID 1000
RUN useradd -m -s /bin/bash -N -u $UID $USERNAME
RUN if [ ! -d /home/$USERNAME/ ]; then mkdir /home/$USERNAME/; fi

# PREPARE IDE
USER $USERNAME
WORKDIR /home/$USERNAME/
RUN git clone https://github.com/icaoberg/vim-as-an-ide.git && mv vim-as-an-ide/vimrc.vim ~/.vimrc && rm -rf vim-as-an-ide
RUN mkdir ~/.vim && git clone https://github.com/VundleVim/Vundle.vim ~/.vim/bundle/Vundle.vim
RUN git clone https://github.com/Yggdroot/duoduo.git && mv duoduo/colors ~/.vim/ && rm -rf duoduo
RUN sed -i 's/solarized/duoduo/g' ~/.vimrc
RUN sed -i 's/nerdtree_tabs_open_on_console_startup = 0/nerdtree_tabs_open_on_console_startup = 1/g' ~/.vimrc
RUN vim +PluginInstall +qall
###############################################################################################
