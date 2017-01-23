__clean_user() {
	local olduser=${1:-$(test -f /etc/default-docker-user && cat /etc/default-docker-user || echo user)}
	homedir=/home/${olduser}
	userdel -f -r ${olduser}
}


cat 1>&2 <<EOF 
*** Cleaning up base image artifacts 
EOF

__clean_user "$1"
