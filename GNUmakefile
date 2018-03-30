#
# Copyright (c) 2018, Joyent, Inc. All rights reserved.
#
# GNUmakefile: top-level Makefile
#
# This Makefile contains only repo-specific logic and uses included makefiles
# to supply common targets (javascriptlint, jsstyle, restdown, etc.), which are
# used by other repos as well.
#

#
# Tools
#
CATEST		 = deps/catest/catest
NPM		 = npm

#
# Files
#
JS_FILES	:= bin/httpmd5
JSL_FILES_NODE   = $(JS_FILES)
JSSTYLE_FILES	 = $(JS_FILES)
JSL_CONF_NODE	 = jsl.node.conf

.PHONY: all
all:
	$(NPM) install
CLEAN_FILES += node_modules

.PHONY: test
test: $(CATEST)
	$(CATEST) -a

$(CATEST): deps/catest/.git

include ./Makefile.targ
