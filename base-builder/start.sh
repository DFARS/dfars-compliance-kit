__create_user() {
	local user=${1:-user}
	shift
	homedir=/home/${user}
	groupadd --system sudo
	useradd --groups sudo,wheel,root ${user}
	usermod -p '*' ${user}
	sed -i -e '/^[ \t]*%wheel/s/^/## /' -e '/NOPASSWD/s/^[ \t]*##*//' -e '/NOPASSWD/s/%wheel/%sudo/g' /etc/sudoers 
	[ -d ${homedir}/.ssh ] || mkdir -m 700 -p ${homedir}/.ssh
	mv /tmp/id_rsa.pub ${homedir}/.ssh/authorized_keys && chmod 600 ${homedir}/.ssh/authorized_keys
	chown -R ${user}:${user} ${homedir} "$@"
	echo ${user} > /etc/default-docker-user
}


__create_user "$1"
