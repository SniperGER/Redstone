export GO_EASY_ON_ME=1
export DEBUG=0
include $(THEOS)/makefiles/common.mk

TWEAK_NAME = Redstone
Redstone_FILES = Tweak.xm RSRootScrollView.m RSStartScrollView.m RSAllAppsButton.m RSAppList.m RSAppListTable.m RSAppListSection.m RSApp.m RSTile.m CAKeyframeAnimation+AHEasing.m easing.c UIFont+WDCustomLoader.m RSTileDelegate.m

include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "killall -9 SpringBoard"
SUBPROJECTS += redstone_prefs
include $(THEOS_MAKE_PATH)/aggregate.mk
