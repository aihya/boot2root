#!/bin/sh
IP_ADDRESS=$1
nmap -sn $IP_ADDRESS/16
