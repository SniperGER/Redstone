export GO_EASY_ON_ME=1

include $(THEOS)/makefiles/common.mk

BUNDLE_NAME = redstone_prefs
redstone_prefs_FILES = RDSRootListController.xm RDSAccentColorList.m
redstone_prefs_INSTALL_PATH = /Library/PreferenceBundles
redstone_prefs_FRAMEWORKS = UIKit
redstone_prefs_PRIVATE_FRAMEWORKS = Preferences

include $(THEOS_MAKE_PATH)/bundle.mk

internal-stage::
	$(ECHO_NOTHING)mkdir -p $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences$(ECHO_END)
	$(ECHO_NOTHING)cp entry.plist $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences/redstone_prefs.plist$(ECHO_END)
