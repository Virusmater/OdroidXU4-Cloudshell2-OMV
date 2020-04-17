# Odroid XU4 & Cloudshell2 as NAS in 2020
My setup: Odroud XU4 (active cooling), Cloudshell2, MMC 32GB, 2x Seagate Barracuda 6TB ST6000DM003, RAID1

## Distro
Since this is a NAS - we need OMV. Currently OMV doesn't build separate images for each and every pc. OMV provided as the script for the installation on top of the base Debian system. So we cannot use official Ubuntu image from Odroid here. Way to go - Armbian. Go for Buster server with 4.14 kernel (https://dl.armbian.com/odroidxu4/Buster_legacy.torrent). Install it as any other OS.

## Open Media Vault 5
Just run
```bash
wget -O - https://github.com/OpenMediaVault-Plugin-Developers/installScript/raw/master/install | sudo bash
```
it will take some time

## Fan and screen
On 5.4 kernel I wasn't able to initiate (at least out of the box) and use the fan and the display supplied with Cloudshell2. Since Armbian is Debian based and all packages for the fan and the display are provided only for Ubuntu it would be required to do following:

add ppa
```bash
kompot@odroidxu4:~$ sudo add-apt-repository ppa:kyle1117/ppa
 
More info: https://launchpad.net/~kyle1117/+archive/ubuntu/ppa
Press [ENTER] to continue or ctrl-c to cancel adding it

gpg: keybox '/tmp/tmpf11e1bb0/pubring.gpg' created
gpg: /tmp/tmpf11e1bb0/trustdb.gpg: trustdb created
gpg: key 3028C3C96AD57103: public key "Launchpad PPA for KYLE LEE" imported
gpg: Total number processed: 1
gpg:               imported: 1
gpg: no valid OpenPGP data found.
add key manually
kompot@odroidxu4:~$ sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 3028C3C96AD57103
Executing: /tmp/apt-key-gpghome.WU8NDps3LZ/gpg.1.sh --keyserver keyserver.ubuntu.com --recv-keys 3028C3C96AD57103
gpg: key 3028C3C96AD57103: public key "Launchpad PPA for KYLE LEE" imported
gpg: Total number processed: 1
gpg:               imported: 1
```
change distro name to something from ubuntu
```bash
kompot@odroidxu4:~$ sudo sed -i 's/focal/bionic/g' /etc/apt/sources.list.d/kyle1117-ubuntu-ppa-focal.list 
```
update
```bash
kompot@odroidxu4:~$ sudo apt update
```
install
```bash
kompot@odroidxu4:~$ apt install cloudshell-lcd cloudshell2-fan odroid-cloudshell 
Reading package lists... Done
Building dependency tree       
Reading state information... Done
The following additional packages will be installed:
  i2c-tools libi2c0
```
change the interface name from eth* to enx*
```bash
kompot@odroidxu4:~$ sed -i 's/\/eth/\/enx/g' /bin/cloudshell-lcd 
```
reboot to see the result

## Fan speed
The fan cannot be adjusted by a software because of the mistake in the Cloudshell2 board, so make a cron script to be able to live in the same room with your NAS. Always check downloaded script content before the execution.
```bash
wget -P /usr/local/sbin/ https://raw.githubusercontent.com/Virusmater/OdroidXU4-Cloudshell2-OMV/master/usr/local/sbin/fan_control.sh
chmod +x /usr/local/sbin/fan_control.sh
```
Add task to cron:
```bash
crontab -e
 * * * * * /usr/local/sbin/fan_control.sh
```
## USB2SATA controller hacks
### S.M.A.R.T. info
USB2SATA microcontroller used in the Cloudshell2 has few unfixable bugs. During some S.M.A.R.T requests from the OMV WebUI hard drives disappear from the system.
```bash
root@odroidxu4:~# wget https://raw.githubusercontent.com/Virusmater/OdroidXU4-Cloudshell2-OMV/master/root/chop_smart_info.sh
root@odroidxu4:~# chmod +x chop_smart_info.sh 
root@odroidxu4:~# ./chop_smart_info.sh 
Okay
Okay
```
### UAS vs USB-STORAGE
During tests UAS driver failed few times, so one of the main features isn't stabe even now. dmesg:
```bash
[10484.934146] sd 0:0:0:0: [sda] tag#27 uas_eh_abort_handler 0 uas-tag 28 inflight: CMD OUT 
[10484.934157] sd 0:0:0:0: [sda] tag#27 CDB: opcode=0x8a 8a 00 00 00 00 00 01 29 70 18 00 00 04 00 00 00
[10490.041882] xhci-hcd xhci-hcd.3.auto: xHCI host not responding to stop endpoint command.
[10490.057895] xhci-hcd xhci-hcd.3.auto: Host halt failed, -110
[10490.057902] xhci-hcd xhci-hcd.3.auto: xHCI host controller not responding, assume dead
[10490.058312] xhci-hcd xhci-hcd.3.auto: HC died; cleaning up
```
Don't know if this is the problem of XU4, Armbian, Linux, Cloudshell2, HDD or me. Consider using usb-storage driver:
```bash
sudo wget -P /boot https://raw.githubusercontent.com/Virusmater/OdroidXU4-Cloudshell2-OMV/master/boot/armbianEnv.txt
```

# Tests
Everything seem to work fine, but upload to network share is significantly lower than download
## Lan Network
```bash
desktop:~/iso$ iperf3 -c odroid.lan
Connecting to host odroid.lan, port 5201
[  5] local 192.168.1.10 port 59886 connected to 192.168.1.20 port 5201
[ ID] Interval           Transfer     Bitrate         Retr  Cwnd
[  5]   0.00-1.00   sec  86.4 MBytes   725 Mbits/sec    0    378 KBytes       
[  5]   1.00-2.00   sec  83.8 MBytes   703 Mbits/sec    0    378 KBytes       
[  5]   2.00-3.00   sec  87.2 MBytes   731 Mbits/sec    0    378 KBytes       
[  5]   3.00-4.00   sec  87.2 MBytes   731 Mbits/sec    0    378 KBytes       
[  5]   4.00-5.00   sec  87.2 MBytes   732 Mbits/sec    0    378 KBytes       
[  5]   5.00-6.00   sec  81.7 MBytes   685 Mbits/sec    0    421 KBytes       
[  5]   6.00-7.00   sec  87.7 MBytes   735 Mbits/sec    0    421 KBytes       
[  5]   7.00-8.00   sec  86.9 MBytes   729 Mbits/sec    0    421 KBytes       
[  5]   8.00-9.00   sec  85.8 MBytes   719 Mbits/sec    0    421 KBytes       
[  5]   9.00-10.00  sec  88.4 MBytes   741 Mbits/sec    0    421 KBytes       
- - - - - - - - - - - - - - - - - - - - - - - - -
[ ID] Interval           Transfer     Bitrate         Retr
[  5]   0.00-10.00  sec   862 MBytes   723 Mbits/sec    0             sender
[  5]   0.00-10.00  sec   860 MBytes   722 Mbits/sec                  receiver

iperf Done.
```
## Storage
### UAS
```bash
#Write - 116 MB/s
root@odroid:/srv/dev-disk-by-label-data# dd if=/dev/zero of=output.img bs=8k count=256k
262144+0 records in
262144+0 records out
2147483648 bytes (2.1 GB, 2.0 GiB) copied, 18.4498 s, 116 MB/s
#Read - 143 MB/s
root@odroid:/srv# dd if=dev-disk-by-label-data/output.img of=/dev/null bs=8k count=256k
262144+0 records in
262144+0 records out
2147483648 bytes (2.1 GB, 2.0 GiB) copied, 15.0103 s, 143 MB/s
```
### USB-STORAGE
```bash
#write - 94 MB/s
kompot@odroid:/srv/dev-disk-by-label-data$ dd if=/dev/zero of=output.img bs=8k count=256k
262144+0 records in
262144+0 records out
2147483648 bytes (2.1 GB, 2.0 GiB) copied, 22.8336 s, 94.0 MB/s
#read - 111 MB/s
kompot@odroid:/srv/dev-disk-by-label-data$ dd if=output.img of=/dev/null bs=8k count=256k
262144+0 records in
262144+0 records out
2147483648 bytes (2.1 GB, 2.0 GiB) copied, 19.2938 s, 111 MB/s
```
## Network share
### wifi
#### UAS
```bash
#download smb - 42.70MB/s
desktop:~/iso$ rsync --info=progress2 /mnt/smb/tmp.img  .
1,182,793,728 100%   42.70MB/s    0:00:26 (xfr#1, to-chk=0/1)
#upload smb - 42.74MB/s
desktop:~/iso$ rsync --info=progress2 tmp.img  /mnt/smb/
1,182,793,728 100%   42.74MB/s    0:00:26 (xfr#1, to-chk=0/1)
#download nfs - 43.18MB/s
desktop:~/iso$ rsync --info=progress2 /mnt/nfs/tmp.img  .
1,182,793,728 100%   43.18MB/s    0:00:26 (xfr#1, to-chk=0/1)
#upload nfs - 42.30MB/s
desktop:~/iso$ rsync --info=progress2 tmp.img  /mnt/nfs
1,182,793,728 100%   42.30MB/s    0:00:26 (xfr#1, to-chk=0/1)
```
#### usb-storage
```bash
#Upload smb - 43.07MB/s
kompot@kompot-ThinkPad-T480s:~/iso$ rsync --info=progress2 tmp.img  /mnt/smb/
1,182,793,728 100%   43.07MB/s    0:00:26 (xfr#1, to-chk=0/1)

#dowload smb - 43.54MB/s
kompot@kompot-ThinkPad-T480s:~/iso$ rsync --info=progress2 /mnt/smb/tmp.img .
1,182,793,728 100%   43.54MB/s    0:00:25 (xfr#1, to-chk=0/1)

#download nfs - 44.80MB/s
kompot@kompot-ThinkPad-T480s:~/iso$ rsync --info=progress2 /mnt/nfs/tmp.img .
1,182,793,728 100%   44.80MB/s    0:00:25 (xfr#1, to-chk=0/1)

#upload nfs - 42.28MB/s
kompot@kompot-ThinkPad-T480s:~/iso$ rsync --info=progress2 tmp.img /mnt/nfs/
1,182,793,728 100%   42.28MB/s    0:00:26 (xfr#1, to-chk=0/1)
```

### ethernet
#### UAS
```bash
#upload nfs - 65.55MB/s  
desktop:~/iso$ rsync --info=progress2 tmp.img  /mnt/nfs
1,182,793,728 100%   65.55MB/s    0:00:17 (xfr#1, to-chk=0/1)

#download nfs - 108.06MB/s
desktop:~/iso$ rsync --info=progress2 /mnt/nfs/tmp.img  .
1,182,793,728 100%  108.06MB/s    0:00:10 (xfr#1, to-chk=0/1)

#upload smb - 67.48MB/s
desktop:~/iso$ rsync --info=progress2 tmp.img  /mnt/mountpoint/
1,182,793,728 100%   67.48MB/s    0:00:16 (xfr#1, to-chk=0/1)

#download smb:
# here UAS failed me another time and I decided to go with usb-storage
```
#### usb-storage
```bash
#upload smb - 59.55MB/s
desktop:~/iso$ rsync --info=progress2 tmp.img  /mnt/mountpoint/
1,182,793,728 100%   59.55MB/s    0:00:18 (xfr#1, to-chk=0/1)

#download smb - 96.57MB/
desktop:~/iso$ rsync --info=progress2 /mnt/mountpoint/tmp.img  .
1,182,793,728 100%   96.57MB/s    0:00:11 (xfr#1, to-chk=0/1)

#upload nfs - 67.49MB/s
desktop:~/iso$ rsync --info=progress2 tmp.img  /mnt/nfs/
1,182,793,728 100%   67.49MB/s    0:00:16 (xfr#1, to-chk=0/1)

#download nfs - 103.17MB/s
desktop:~/iso$ rsync --info=progress2 /mnt/nfs/tmp.img  .
1,182,793,728 100%  103.17MB/s    0:00:10 (xfr#1, to-chk=0/1)
```
