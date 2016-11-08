#export THEOS_DEVICE_IP=192.168.178.103
#export THEOS_DEVICE_IP=192.168.178.38
export THEOS_DEVICE_IP=10.60.17.114

#export THEOS_DEVICE_IP=localhost
#export THEOS_DEVICE_PORT=2222

export TARGET=iphone:latest:6.1
export GO_EASY_ON_ME=1
export PACKAGE_VERSION="$(shell date +%y)w$(shell date +%V)a"

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = Redstone
Redstone_FILES = Tweak.xm UIImageAverageColorAddition.m UIFont+WDCustomLoader.m
Redstone_FILES +=  Redstone.m RSRootScrollView.m RSStartScreenController.m RSStartScrollView.m RSMetrics.m RSTile.m RSAesthetics.m RSTiltView.m RSAppListController.m RSAppList.m RSAppListSection.m RSApp.m RSSearchBar.m RSPinMenu.m RSJumpList.m CAKeyframeAnimation+AHEasing.m easing.c RSLaunchScreenController.m RSLaunchScreen.m
Redstone_FRAMEWORKS = UIKit
Redstone_PRIVATE_FRAMEWORKS = AppSupport

include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "killall -9 SpringBoard"
SUBPROJECTS += redstone_prefs
include $(THEOS_MAKE_PATH)/aggregate.mk
