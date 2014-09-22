#!/bin/bash
## @author gdm85
## this script is an adapted version of jpetazzo's original:
## https://github.com/jpetazzo/dind/blob/master/wrapdocker
## (thus most of the comment are his voice)
#

## prevent (re)starting of sshd
## we want to use sshd as our container process
echo -e "#!/bin/sh\nexit 101" > /usr/sbin/policy-rc.d && \
chmod +x /usr/sbin/policy-rc.d

## regenerate host keys
/bin/rm -v /etc/ssh/ssh_host_* && \
dpkg-reconfigure -f noninteractive openssh-server || exit $?

## removed, in case you want to install other packages at container-time
rm /usr/sbin/policy-rc.d

# First, make sure that cgroups are mounted correctly.
CGROUP=/sys/fs/cgroup

[ -d $CGROUP ] ||
	mkdir $CGROUP

mountpoint -q $CGROUP ||
	mount -n -t tmpfs -o uid=0,gid=0,mode=0755 cgroup $CGROUP || {
		echo "Could not make a tmpfs mount. Did you use -privileged?"
		exit 1
	}

if [ -d /sys/kernel/security ] && ! mountpoint -q /sys/kernel/security
then
    mount -t securityfs none /sys/kernel/security || {
        echo "Could not mount /sys/kernel/security."
        echo "AppArmor detection and -privileged mode might break."
        exit 2
    }
fi

# Mount the cgroup hierarchies exactly as they are in the parent system.
for SUBSYS in $(cut -d: -f2 /proc/1/cgroup)
do
        [ -d $CGROUP/$SUBSYS ] || mkdir $CGROUP/$SUBSYS
        mountpoint -q $CGROUP/$SUBSYS ||
                mount -n -t cgroup -o $SUBSYS cgroup $CGROUP/$SUBSYS

        # The two following sections address a bug which manifests itself
        # by a cryptic "lxc-start: no ns_cgroup option specified" when
        # trying to start containers withina container.
        # The bug seems to appear when the cgroup hierarchies are not
        # mounted on the exact same directories in the host, and in the
        # container.

        # Named, control-less cgroups are mounted with "-o name=foo"
        # (and appear as such under /proc/<pid>/cgroup) but are usually
        # mounted on a directory named "foo" (without the "name=" prefix).
        # Systemd and OpenRC (and possibly others) both create such a
        # cgroup. To avoid the aforementioned bug, we symlink "foo" to
        # "name=foo". This shouldn't have any adverse effect.
        echo $SUBSYS | grep -q ^name= && {
                NAME=$(echo $SUBSYS | sed s/^name=//)
                ln -s $SUBSYS $CGROUP/$NAME
        }

        # Likewise, on at least one system, it has been reported that
        # systemd would mount the CPU and CPU accounting controllers
        # (respectively "cpu" and "cpuacct") with "-o cpuacct,cpu"
        # but on a directory called "cpu,cpuacct" (note the inversion
        # in the order of the groups). This tries to work around it.
        [ $SUBSYS = cpuacct,cpu ] && ln -s $SUBSYS $CGROUP/cpu,cpuacct
done

# Note: as I write those lines, the LXC userland tools cannot setup
# a "sub-container" properly if the "devices" cgroup is not in its
# own hierarchy. Let's detect this and issue a warning.
grep -q :devices: /proc/1/cgroup ||
	echo "WARNING: the 'devices' cgroup should be in its own hierarchy."
grep -qw devices /proc/1/cgroup ||
	echo "WARNING: it looks like the 'devices' cgroup is not mounted."

# Now, close extraneous file descriptors.
pushd /proc/self/fd >/dev/null
for FD in *
do
	case "$FD" in
	# Keep stdin/stdout/stderr
	[012])
		;;
	# Nuke everything else
	*)
		eval exec "$FD>&-"
		;;
	esac
done
popd >/dev/null

source /home/debian/.bash_profile
## at this point environment should be ready

## bridge to be used by gitian LXC container
brctl addbr br0 && \
ifconfig br0 ${GITIAN_HOST_IP}/16 up || exit $?

##NOTE: *DO NOT* try to add eth0 to the bridge, it will kill container's networking

## temporary workaround until this bug is fixed: https://bugs.launchpad.net/ubuntu/+source/sysvinit/+bug/891045
umount /dev/shm
rmdir /dev/shm
ln -s /run/shm /dev/shm

##NOTE: this is setup here instead of Dockerfile because of a Docker glitch
AK=/root/authorized_keys
if [ -s $AK ]; then
	cp $AK /home/debian/.ssh/ && \
	rm $AK && \
	chmod -R go-rwx /home/debian/.ssh &&
	chown -R debian.debian /home/debian/.ssh || exit $?
fi

## test that debian user has access to its own .ssh (yes, Docker glitches crawling...)
su -c 'cat /home/debian/.ssh/authorized_keys' -l -- debian || exit $?

echo "Gitian host configuration for LXC guests completed successfully"
