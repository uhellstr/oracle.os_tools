#!/bin/bash
ansible-playbook ./collect.yml -i ./hosts -e ansible_ssh_port=22
