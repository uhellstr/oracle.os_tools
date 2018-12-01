#!/usr/bin/env python
# coding: UTF-8
import base64
import getpass
import os

pwd = getpass.getpass(prompt="Please give SYS pwd: ")
pwd =  base64.urlsafe_b64encode(pwd.encode('UTF-8)')).decode('ascii')
os.environ["DB_INFO"] = pwd
print(os.environ["DB_INFO"])
print(base64.urlsafe_b64decode(os.environ["DB_INFO"].encode('UTF-8')).decode('ascii'))
