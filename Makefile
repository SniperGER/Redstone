export TARGET=iphone:latest:9.3
export GO_EASY_ON_ME=1
export DEBUG=0

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = Redstone
Redstone_FILES = Tweak.xm RSTileDelegate.m UIFont+WDCustomLoader.m easing.c CAKeyframeAnimation+AHEasing.m
Redstone_FILES += RSRootScrollView.m RSTileScrollView.m RSTileView.m RSAppList.m RSAppListApp.m RSAppListSection.m RSJumpListView.m RSTiltButton.m RSAllAppsButton.m

include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "killall -9 SpringBoard"
SUBPROJECTS += redstone_prefs
include $(THEOS_MAKE_PATH)/aggregate.mk
