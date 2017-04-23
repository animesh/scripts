if [ -f /etc/irssi.conf ] && cmp -s /etc/defaults/etc/irssi.conf /etc/irssi.conf
then
    rm /etc/irssi.conf
fi

