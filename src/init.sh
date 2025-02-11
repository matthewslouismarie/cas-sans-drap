#!/bin/bash

apt update
apt full-upgrade -y
apt install python3.10-venv -y
python3 -m venv venv
source venv/bin/activate
pip install pandas

# To be able to export the notebook to PDF
apt install -y texlive-xetex texlive-fonts-recommended texlive-plain-generic pandoc

# Download and install DSBulk
wget https://github.com/datastax/dsbulk/releases/download/1.11.0/dsbulk-1.11.0.tar.gz
tar -zxvf dsbulk-1.11.0.tar.gz
mv dsbulk-1.11.0/ /opt/
echo 'PATH=/opt/dsbulk-1.11.0/bin/:$PATH' >> .profile
source .profile