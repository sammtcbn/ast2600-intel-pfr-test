#!/bin/bash
# refer to from SDK_User_Guide_V08.06.pdf p.452
# https://github.com/AspeedTech-BMC/openbmc/releases/download/v08.06/SDK_User_Guide_v08.06.pdf

#Generate root key
openssl ecparam -name secp256r1 -genkey -out rk256_prv.pem
openssl ec -in rk256_prv.pem -pubout -out rk256_pub.pem

#Generate CSK key
openssl ecparam -name secp256r1 -genkey -out csk256_prv.pem
openssl ec -in csk256_prv.pem -pubout -out csk256_pub.pem
