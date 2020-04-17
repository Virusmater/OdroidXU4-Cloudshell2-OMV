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
The fan cannot be adjusted by a software because of the mistake in the Cloudshell board, so make a cron script to be able to live in the same room with your NAS. Always check downloaded script content before the execution.
```bash
wget -P /usr/local/sbin/ https://raw.githubusercontent.com/Virusmater/OdroidXU4-Cloudshell2-OMV/master/usr/local/sbin/fan_control.sh
chmod +x /usr/local/sbin/fan_control.sh
```
Add task to cron:
```bash
crontab -e
 * * * * * /usr/local/sbin/fan_control.sh
```
