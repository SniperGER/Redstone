include $(THEOS)/makefiles/common.mk

BUNDLE_NAME = Redstone
Redstone_FILES = RDSRootListController.m RDSAccentColorList.m PFHeaderCell.mm
Redstone_INSTALL_PATH = /Library/PreferenceBundles
Redstone_FRAMEWORKS = UIKit
Redstone_PRIVATE_FRAMEWORKS = Preferences

include $(THEOS_MAKE_PATH)/bundle.mk

internal-stage::
	$(ECHO_NOTHING)mkdir -p $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences$(ECHO_END)
	$(ECHO_NOTHING)cp entry.plist $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences/Redstone.plist$(ECHO_END)
