export TARGET=iphone:latest:9.3
export GO_EASY_ON_ME=1
export THEOS_DEVICE_IP=192.168.178.38

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = Redstone
Redstone_FILES = Tweak.xm RSApplicationDelegate.m UIFont+WDCustomLoader.m RSAesthetics.m CAKeyframeAnimation+AHEasing.m easing.c UIImageAverageColorAddition.m RSTileDelegate.m
Redstone_FILES += RSRootView.m RSTiltView.m RSRootScrollView.m RSAppListScrollView.m RSAppListSection.m RSAppListItem.m RSSearchBar.m RSAppListItemContainer.m RSJumpListView.m RSPinMenu.m RSTileScrollView.m RSTile.m
Redstone_PRIVATE_FRAMEWORKS = AppSupport
Redstone_FRAMEWORKS = AudioToolbox

include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "killall -9 SpringBoard"
