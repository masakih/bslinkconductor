// encoding=utf-8
PRODUCT_NAME=BSLinkConductor
PRODUCT_EXTENSION=plugin
BUILD_PATH=./build
DEPLOYMENT=Release
APP_BUNDLE=$(PRODUCT_NAME).$(PRODUCT_EXTENSION)
APP=$(BUILD_PATH)/$(DEPLOYMENT)/$(APP_BUNDLE)
APP_NAME=$(BUILD_PATH)/$(DEPLOYMENT)/$(PRODUCT_NAME)
INFO_PLIST=Info.plist

VER_CMD=grep -A1 'CFBundleShortVersionString' $(INFO_PLIST) | tail -1 | tr -d "'\t</string>" 
VERSION=$(shell $(VER_CMD))

all:
	@echo do  nothig.
	@echo use target tagging 

tagging:
	@echo "Tagging the $(VERSION) (x) release of BSLinkConductor project."
	@echo ""
	echo svn copy $(HEAD) $(TAGS_DIR)/release-$(VERSION)

Localizable:
	genstrings -o English.lproj $^
	(cd English.lproj; ${MAKE} $@;)
	genstrings -o Japanese.lproj $^
	(cd Japanese.lproj; ${MAKE} $@;)

checkLocalizable:
	(cd English.lproj; ${MAKE} $@;)
	(cd Japanese.lproj; ${MAKE} $@;)

release: updateRevision
	xcodebuild -configuration $(DEPLOYMENT)
	$(MAKE) restorInfoPlist

package: release
	REV=`git show | head -1 | awk '{printf("%.7s\n", $$2)}'`;	\
	ditto -ck -rsrc --keepParent $(APP) $(APP_NAME)-$(VERSION)-$${REV}.zip

updateRevision:
	if [ ! -f $(INFO_PLIST).bak ] ; then cp $(INFO_PLIST) $(INFO_PLIST).bak ; fi ;	\
	REV=`git show | head -1 | awk '{printf("%.7s\n", $$2)}'` ;	\
	sed -e "s/%%%%REVISION%%%%/$${REV}/" $(INFO_PLIST) > $(INFO_PLIST).r ;	\
	mv -f $(INFO_PLIST).r $(INFO_PLIST) ;	\

restorInfoPlist:
	if [ -f $(INFO_PLIST).bak ] ; then mv -f $(INFO_PLIST).bak $(INFO_PLIST) ; fi


