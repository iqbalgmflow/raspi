#!/usr/bin/bash
. /home/pi/.bashrc
unset power_state
unset pingstat
echo " ############  STARTING RASPI INTERNET CHECK ON `date` ########### ">> cron_raspi.log
pingstat=$(if ping -c 1 4.2.2.2 &> /dev/null; then echo 1;  elif ping -c 1 8.8.8.8 &> /dev/null; then echo 1;fi)

if [[ $pingstat != "1" ]]
then
    echo "Netconnection not detected ... starting wlan0 to check desired state" >> cron_raspi.log
    sudo ifconfig wlan0 up
    sleep 20
else
    echo "Netconnection detected ... not disturbing wlan0 state" >> cron_raspi.log
fi
### Below steps to retrieve github status

rm -rf /home/pi/raspi
cd /home/pi/
git clone https://github.com/iqbalgmflow/raspi
chmod 777 /home/pi/raspi/logon.status
source /home/pi/raspi/logon.status

### Changing state as per github
if [[ $power_state == "ON" ]]
then
     if [[ $pingstat == "1" ]]
       then
             echo "PINGSTAT power state was ON, maintained state" >> cron_raspi.log
             exit
       else
             echo "PINGSTAT power state was OFF, will turn ON" >> cron_raspi.log
             echo "Power state will change to ON" >> cron_raspi.log
             echo "################### Checking / Starting Internet access -- DONE !! on `date` ########################" >> cron_raspi.log
             sudo ifconfig eth0 up
             echo >> cron_raspi.log
             ifconfig wlan0 >> cron_raspi.log
       fi
else
     echo "Power state will be OFF" >> cron_raspi.log
     echo "Shutting down WLAN" >> cron_raspi.log
     sleep 2
     sudo ifconfig eth0 down >> cron_raspi.log
     sudo ifconfig wlan0 down >> cron_raspi.log
     echo "################### Shutting down Internet access --  DONE !! #############################" >> cron_raspi.log
fi
echo "######### Completed raspi Internet check at `date` ########" >> cron_raspi.log
