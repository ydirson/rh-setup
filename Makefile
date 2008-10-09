
VERSION=$(shell awk '/^Version:/ { print $$NF }' setup.spec)
CVSTAG = r$(subst .,_,$(VERSION))
CVSROOT:=$(shell cat CVS/Root 2>/dev/null || :)

check:
	@echo Sanity checking selected files....
	bash -n bashrc
	bash -n profile
	tcsh -f csh.cshrc
	tcsh -f csh.login
	./uidgidlint ./uidgid
	./serviceslint ./services

force-tag-archive: check
	@cvs -Q tag -F $(CVSTAG)

tag-archive: check
	@cvs -Q tag -c $(CVSTAG)

create-archive:
	@rm -rf /tmp/setup
	@cd /tmp ; cvs -Q -d $(CVSROOT) export -r$(CVSTAG) setup || echo "Um... export aborted."
	@mv /tmp/setup /tmp/setup-$(VERSION)
	@cd /tmp ; tar -c --bzip2 -Spf setup-$(VERSION).tar.bz2 setup-$(VERSION)
	@rm -rf /tmp/setup-$(VERSION)
	@cp /tmp/setup-$(VERSION).tar.bz2 .
	@rm -f /tmp/setup-$(VERSION).tar.bz2
	@echo ""
	@echo "The final archive is in setup-$(VERSION).tar.bz2"

archive: tag-archive create-archive

clean:
	rm -f *.bz2
