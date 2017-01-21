__create_user() {
	local user=${1:-ansible}
	homedir=/home/${user}
	groupadd sudo
	useradd --groups sudo,wheel,root ${user}
	usermod -p '*' ${user}
	sed -i -e '/^[ \t]*%wheel/s/^/## /' -e '/NOPASSWD/s/^[ \t]*##*//' /etc/sudoers 
	[ -d ${homedir}/.ssh ] || mkdir -m 700 -p ${homedir}/.ssh
	mv /tmp/id_rsa.pub ${homedir}/.ssh/authorized_keys && chmod 600 ${homedir}/.ssh/authorized_keys
	chown -R ansible.ansible /etc/ansible ${homedir}
}


__create_user ansible
