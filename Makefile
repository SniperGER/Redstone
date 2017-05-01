export THEOS_DEVICE_IP=192.168.178.38
#export THEOS_DEVICE_IP=localhost
#export THEOS_DEVICE_PORT=2222

#export TARGET=iphone:latest:7.0
ARCHS=x86_64 i386
TARGET=simulator:clang
export PACKAGE_VERSION="$(shell date +%y)w$(shell date +%V)a"

include /opt/theos/makefiles/common.mk

TWEAK_NAME = Redstone

# Redstone Core Files
Redstone_FILES = Tweak.xm core/Redstone.m core/RSAesthetics.m core/RSAnimation.m core/RSMetrics.m core/RSPreferences.m core/RSRootScrollView.m core/RSTiltView.m
Redstone_FILES += lib/CAKeyframeAnimation+AHEasing.m lib/easing.c lib/UIFont+WDCustomLoader.m lib/UIImageAverageColorAddition.m

# Redstone Start Screen Files
Redstone_FILES += start/RSStartScreenController.m start/RSStartScrollView.m start/RSTile.m

# Redstone App List Files
# Redstone_FILES +=

# Redstone Jump List Files
# Redstone_FILES +=

# Redstone Launch Screen Files
Redstone_FILES += launch/RSLaunchScreen.m launch/RSLaunchScreenController.m

Redstone_FRAMEWORKS = UIKit
Redstone_PRIVATE_FRAMEWORKS = AppSupport

include /opt/theos/makefiles/tweak.mk

#after-install::
#	install.exec "killall -9 SpringBoard"
SUBPROJECTS += redstone_prefs
include /opt/theos/makefiles/aggregate.mk
