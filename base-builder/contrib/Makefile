CURL=curl
OVIRT_SETUP_PATCH=https://raw.githubusercontent.com/rmohr/docker-ovirt-engine/master/4.0/setup.patch
OVIRT_ENTRY_POINT=https://raw.githubusercontent.com/rmohr/docker-ovirt-engine/master/4.0/entrypoint.sh
OVIRT_ANSWERS_IN=https://raw.githubusercontent.com/rmohr/docker-ovirt-engine/master/4.0/answers.conf.in

default: ovirt-setup.patch ovirt-entrypoint.sh ovirt-answers.in

ovirt-setup.patch::
	$(CURL) -z $@ -o $@ $(OVIRT_SETUP_PATCH)

ovirt-entrypoint.sh::
	$(CURL) -z $@ -o $@ $(OVIRT_ENTRY_POINT)

ovirt-answers.conf.in::
	$(CURL) -z $@ -o $@ $(OVIRT_ANSWERS_IN)

