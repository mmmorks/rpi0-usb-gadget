#!/bin/bash

echo placing files...
cmp -s g_ether.conf /etc/modprobe.d/g_ether.conf
if [ $? -ne 0 ]
  then
  echo updating /etc/modprobe.d/g_ether.conf
  cp -f g_ether.conf /etc/modprobe.d/g_ether.conf
fi
cmp -s usb-gadget-init /usr/bin/usb-gadget-init
if [ $? -ne 0 ]
  then
  echo updating /usr/bin/usb-gadget-init
  cp -f usb-gadget-init /usr/bin/usb-gadget-init
fi
cmp -s usb-gadget.service /usr/lib/systemd/system/usb-gadget.service
if [ $? -ne 0 ]
  then
  echo updating /usr/lib/systemd/system/usb-gadget.service
  mkdir -p /usr/lib/systemd/system && cp -f usb-gadget.service /usr/lib/systemd/system/usb-gadget.service
  chmod +x /usr/bin/usb-gadget-init
fi
cmp -s 99-toggle-wifi-when-usb-connects /etc/NetworkManager/dispatcher.d/99-toggle-wifi-when-usb-connects
if [ $? -ne 0 ]
  then
  echo updating 99-toggle-wifi-when-usb-connects
  cp -f 99-toggle-wifi-when-usb-connects /etc/NetworkManager/dispatcher.d/99-toggle-wifi-when-usb-connects
  chmod 700 /etc/NetworkManager/dispatcher.d/99-toggle-wifi-when-usb-connects
fi

echo updating system configuration...
rebootneed=0
grep -q "dtoverlay=dwc2" /boot/config.txt|| {
echo "dtoverlay=dwc2" >> /boot/config.txt
rebootneed=1
}
#grep -q "dwc2" /etc/modules|| echo "dwc2" >> /etc/modules

nmcli con add type bridge ifname br0
nmcli con add type bridge-slave ifname usb0 master br0
nmcli con add type bridge-slave ifname usb1 master br0
nmcli con modify bridge-br0 ipv4.method auto ipv4.dhcp-timeout 5 ipv6.addr-gen-mode default ipv6.dhcp-timeout 5 ipv6.method auto

echo enabling services...
systemctl enable usb-gadget.service
if [ ! $rebootneed -eq 1 ]
  then
  echo type '"systemctl start usb-gadget.service"' to start service
  else
  echo "system reboot required!"
fi
