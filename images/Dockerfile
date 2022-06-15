FROM cribl/scope:dev-x86_64
ENV LC_CTYPE C.UTF-8

RUN apt update && DEBIAN_FRONTEND=noninteractive apt install git make gcc cgdb gdb autoconf openssh-server sudo make zlib1g-dev libssl-dev python3 python3-pip wget curl netcat -y
# RUN apt update && DEBIAN_FRONTEND=noninteractive apt install git make gcc cgdb gdb autoconf sudo make zlib1g-dev libssl-dev python3 python3-pip wget curl netcat -y
RUN python3 -m pip install pwn
RUN python3 -m pip install keystone-engine ropper
RUN wget -q -O- https://github.com/hugsy/gef/raw/master/scripts/gef.sh | sh

# Create a user “sshuser” and group “sshgroup”
RUN groupadd sshgroup && useradd -ms /bin/bash -g sshgroup sshuser
RUN echo sshuser:sshuser | chpasswd 
    
# Create sshuser directory in home
RUN mkdir -p /home/sshuser/.ssh
# Copy the ssh public key in the authorized_keys file.
COPY *.pub /home/sshuser/.ssh/authorized_keys
# change ownership of the key file. 
RUN chown sshuser:sshgroup /home/sshuser/.ssh/authorized_keys && chmod 600 /home/sshuser/.ssh/authorized_keys

RUN mkdir -p /opt/test-runner

RUN git clone https://github.com/hugsy/gef.git
RUN echo source `pwd`/gef/gef.py >> ~/.gdbinit

RUN git clone https://github.com/openssh/openssh-portable
RUN cd openssh-portable && git checkout V_8_2_P1 && autoreconf && ./configure --disable-strip && make -j "$(nproc)" && make install

# Start SSH service
RUN service ssh start