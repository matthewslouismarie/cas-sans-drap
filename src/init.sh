#!/bin/bash

apt update
apt full-upgrade -y
apt install python3.10-venv -y
python3 -m venv venv
source venv/bin/activate
pip install pandas
apt install -y texlive-xetex texlive-fonts-recommended texlive-plain-generic pandoc