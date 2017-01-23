# Makefile for building and running a docker instance
#
# Copyright (C) 2017 Ahmed Masud <ahmed.masud@trustifier.com>
#
# See LICENSE for usage details
#
# @@help main
#
# make help 	-- displays this help
#
# User mode:
#
# 	make		-- builds a docker image named <image-name>:latest
# 	make run	-- builds and runs a docker image named <image-name>:latest
#
# ** Note that in user mode all existing docker images of the same name are removed 
#
# -----------------------------------------------------------------------------
# Developer mode (assumed if .git is present):
#
# 	make		-- build image from the current git branch
# 	make run 	-- build & run image from the current git branch
# 			   NOTE: the executed image gets deleted upon exit
#
# 	make latest	-- build image as latest from current git branch
# 	make run-latest	-- build & run image as latest from current git branch
#
# @@end-help

# @@help parameters
# 
# You can provide RUN, IMAGE and TAG as part of the build process:
#
# For example
#
# 	make TAG=3.5 (tag the image as 3.5)
# 	make IMAGE=foo TAG=bar (create image named 'foo' tagged as 'bar')
# 	make ROOT=<PATH | URL> (create image from path or URL instead of pwd)
#
# Use RUNAS to specify the instance name (defaults to docker-deepdive-instance)
#
# DATADIR default is ./data
# 
# For example
#
# 	make run RUNAS=my-instance DATADIR=/var/lib/deepdive/foo
#
# @@end-help


# @@help
# DOCKERFILE= specifies which Dockerfile to use
# TARGET= has multiple effects
# 	uses Dockerfile.$(TARGET) as the key docker file
#
# @@end-help
#

TARGET:=ansible
DOCKERFILE:=Dockerfile$(if $(TARGET),.$(TARGET),,)
ROOTDIR:=.
IMAGE:=dfars-kit/$(TARGET)
TAG:=latest
RUNAS:=dfars-kit-$(TARGET)
INSTANCEID:=instance-id-$(TARGET)

export PORTS:=
PORTREDIRECTS_P=$(shell echo ${PORTS} | sed 's/[0-9][0-9]*:[0-9][0-9]*/-p &/g')


#
# on a production system set DATADIR to /var/lib/docker-deepdive
#
export DATADIR:=$${PWD}/data

export DATAMOUNTPOINT=/data
#
# User inside the container ... 
#
export USERNAME:=$(TARGET)

####### do not edit below this #####

MAKEFLAGS += -rR --no-print-directory
 
DOCKER=docker
MKDIR_P=mkdir -p
PERL=perl -w
DOCKERTARGETS=$(shell echo Dockerfile.* | sed s/Dockerfile\.//g)


DOCKERTARGETS_BUILD  := $(DOCKERTARGETS:%=%-build)
DOCKERTARGETS_RUN    := $(DOCKERTARGETS:%=%-run)
DOCKERTARGETS_CLEAN  := $(DOCKERTARGETS:%=%-clean)
DOCKERTARGETS_STOP   := $(DOCKERTARGETS:%=%-stop)
DOCKERTARGETS_START   := $(DOCKERTARGETS:%=%-start)
IPOF := $(DOCKERTARGETS:%=%-ip)


default::
	@$(if $(Q),$(call e),:)
	$(Q)$(MAKE) list-targets
	@$(if $(Q),$(call e),:)

$(DOCKERTARGETS_BUILD)::
	$(Q)$(MAKE) TARGET=$(@:%-build=%) build

$(DOCKERTARGETS_RUN)::
	$(Q)$(MAKE) TARGET=$(@:%-run=%) run

$(DOCKERTARGETS_CLEAN)::
	$(Q)$(MAKE) TARGET=$(@:%-clean=%) clean

$(DOCKERTARGETS_START)::
	$(Q)$(MAKE) TARGET=$(@:%-start=%) start

$(DOCKERTARGETS_STOP)::
	$(Q)$(MAKE) TARGET=$(@:%-stop=%) stop

$(IPOF)::
	$(Q)$(MAKE) TARGET=$(@:%-ip=%) ip

# @@help verbosity
#
# Make flag increase make verbosity by setting V=1 
# For example, 
#
# 	make V=1 build
#
# @@end-help 

ifeq ($(V),)
Q=@
e=(echo $(1) 1>&2)

S=([ -n "$(1)" ] && (							\
	echo -ne "	\e[0;37m[\e[32m"; echo -ne $(1); 		\
	if [ -n '$(2)' ] ; then $(if $(2),./scripts/spin-tee.sh -L $(if $(3), $(3), /dev/null) -- $(2), :);  \
		rv=$$?; if [ $$rv -eq 0 ]; then				\
			echo -e "\e[0;37m:\e[1;34m Success\e[0m]";	\
		else 							\
			echo -e "\e[0;37m:\e[0;31m Failure\e[0m]";	\
			exit $$rv;					\
		fi;							\
	else echo -e "\e[0;37m]"; fi) 1>&2)
T=(echo -e "      -=|\e[0;31m$(1)\e[0;37m |=-"; $(if $(2), echo 1>&2; $(2) | sed -e '$(if $(3),$(3),s/^/\t/)' 1>&2, :))

else
Q=
S=$(if $(2),$(2),:)
e=
T=(echo $(1))
endif

export Q
export E
export e

PHONY=


# Suppress entering/leaving messages

PHONY += default 




PHONE += Dockerfile

Dockerfile::
	$(Q)(echo ; echo -e "\n\tdefault Dockerfile does not exist, use one of the following targets\n\t\t$(DOCKERTARGETS)\n") 1>&2 && false

PHONY += help
help::
	$(Q)$(PERL) scripts/help.pl Makefile | $${PAGER:-less -XeF --prompt "Use j/k to scroll, quits at the end"}

maintainer-clean:: clean
	$(Q)$(RM) -r .deps 


PHONY+=space

PHONY+= build

build: 
	$(Q)$(call S, DOCKER BUILD, $(DOCKER) build -f '$(DOCKERFILE)' -t $(IMAGE):$(TAG) $(ROOTDIR), build-log ) || \
		$(call T, Error: docker build log, tac build-log | grep -m1 Step -B10 | tac)

PHONY+=run
run:
	$(Q)$(call e); $(MAKE) DOCKERFILE=$(DOCKERFILE) TARGET=$(TARGET) build clean-instance run-instance; $(call e)

stop:
	$(Q)$(call e); $(MAKE) DOCKERFILE=$(DOCKERFILE) TARGET=$(TARGET) stop-instance; $(call e)

start:
	$(Q)$(call e); $(MAKE) DOCKERFILE=$(DOCKERFILE) TARGET=$(TARGET) start-instance; $(call e)

clean:
	$(Q)$(call e); $(MAKE) DOCKERFILE=$(DOCKERFILE) TARGET=$(TARGET) stop-instance clean-instance; $(call e)

status:
	$(Q)INSTANCEID="$$($(DOCKER) ps -q -f 'name=$(RUNAS)')";  test -n "$${INSTANCEID}" && \
		( echo "Instance is running as $(RUNAS) (id: $${INSTANCEID})" )  || ( echo "Instance is not running" )

run-instance:
	$(Q)test -z "$$($(DOCKER) ps -qa -f 'name=$(RUNAS)')" || \
		( echo "Please remove the instance before issuing make run" 1>&2 && exit 127 )
	$(Q)$(call S, CREATING DATA DIR $(DATADIR), mkdir -p $(DATADIR))
	$(Q)$(call S, DOCKER RUN $(RUNAS), \
		$(DOCKER) run -v $(DATADIR):$(DATAMOUNTPOINT) ${PORTREDIRECTS_P} -tid --name $(RUNAS) $(IMAGE):$(TAG), $(INSTANCEID)) \
	 && $(call S, $(RUNAS) is running)
	$(MAKE) attach-help


clean-instance:
	$(Q)test -z "$$($(DOCKER) ps -q -f 'name=$(RUNAS)')" || \
		( echo "Please stop the instance before issuing make clean-instance" 1>&2 && exit 127 )
	$(Q)$(call S, 'DOCKER CLEAN', $(DOCKER) rm $(RUNAS) || echo $(RUNAS), $(INSTANCEID) )

start-instance:
	$(Q)$(call S, 'DOCKER START', $(DOCKER) start $(RUNAS), $(INSTANCEID))

stop-instance:
	$(Q)test -n "$$($(DOCKER) ps -q -f 'name=$(RUNAS)')" && $(call S, 'DOCKER STOP', $(DOCKER) stop $(RUNAS)) || true

attach: attach-help

attach-help:
	@echo -e "\n\n	Use \e[1mdocker exec -ti $(RUNAS) su - $(USERNAME)\e[0m to attach to the environment.\n"
	@echo -e "\n\n	Use \e[1mdocker exec -ti $(RUNAS) /bin/bash\e[0m to attach to the raw instance.\n"

ip:
	$(Q)docker exec -ti $(RUNAS) /usr/sbin/ip addr

.deps:
	$(Q)$(MKDIR_P) $@

PHONE+=first-time-help

first-time-help:
	$(Q)test -f .deps/first-time-help || ($(MAKE) help && mkdir .deps && touch .deps/first-time-help)

PHONE+=list-targets

list-targets:
	@echo -ne "\nYou need to specify a Docker target, following targets are available:\n\n" \
		"\tBuild Targets: \e[1m" $(DOCKERTARGETS_BUILD) "\e[0m\n"	\
		"\tClean Targets: \e[1m" $(DOCKERTARGETS_CLEAN) "\e[0m\n"	\
		"\tRun Targets: \e[1m" $(DOCKERTARGETS_RUN) "\e[0m\n"	\
		"\tStart a particular instance: \e[1m" $(DOCKERTARGETS_START) "\e[0m\n"	\
		"\tStop a particular instance: \e[1m" $(DOCKERTARGETS_STOP) "\e[0m\n"	\
		""

PHONE += $(DOCKERTARGETS)

# build and run targets for various Dockerfile.* 
#
# $(DOCKERTARGETS):
#	$(Q)$(MAKE) DOCKERFILE=Dockerfile.$@ TARGET=$@ build

.PHONY: $(PHONY)
