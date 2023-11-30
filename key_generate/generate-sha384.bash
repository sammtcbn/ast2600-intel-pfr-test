#!/bin/bash
# refer to from SDK_User_Guide_V08.06.pdf p.452
# https://github.com/AspeedTech-BMC/openbmc/releases/download/v08.06/SDK_User_Guide_v08.06.pdf

#Generate root key
openssl ecparam -name secp384r1 -genkey -out rk384_prv.pem
openssl ec -in rk384_prv.pem -pubout -out rk384_pub.pem

#Generate CSK key
openssl ecparam -name secp384r1 -genkey -out csk384_prv.pem
openssl ec -in csk384_prv.pem -pubout -out csk384_pub.pem
