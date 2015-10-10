#!/bin/bash

# Install VirtualBox Guest Additions
# The "Window System drivers" step will fail which is fine because we
# don't have Xorg
mount -o ro $(find /dev/disk/by-label | grep VBOXADDITIONS) /mnt/
/mnt/VBoxLinuxAdditions.run
chkconfig vboxadd-x11 off
umount /mnt/

# Rebuild the initrd to include only what's needed.
dracut -f -H

yum clean all  # Remove yum's cache files.

# Clean logs.
rm -f /var/log/dmesg.old /var/log/anaconda.ifcfg.log \
      /var/log/anaconda.log /var/log/anaconda.program.log \
      /var/log/anaconda.storage.log /var/log/anaconda.syslog \
      /var/log/anaconda.yum.log /root/anaconda-ks.cfg \
      /var/log/vboxadd-install.log /var/log/vbox-install-x11.log \
      /var/log/VBoxGuestAdditions.log /var/log/vboxadd-install-x11.log
echo -n | tee /var/log/dmesg /var/log/maillog /var/log/lastlog \
              /var/log/secure /var/log/yum.log >/var/log/cron

# Clear out swap partition in case it was used during install.
swapuuid=$(blkid -o value -l -s UUID -t TYPE=swap)
swappart=$(readlink -f /dev/disk/by-uuid/${swapuuid})

swapoff $swappart
dd if=/dev/zero of=$swappart bs=1M
mkswap -U $swapuuid $swappart
