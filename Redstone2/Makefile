# Makefile 3

export THEOS_DEVICE_IP=192.168.178.38
export THEOS_DEVICE_PORT=22

export PACKAGE_VERSION = $(shell date +%y)w$(shell date +%V)a-Internal
#export ADDITIONAL_CFLAGS = -I$(THEOS_PROJECT_DIR)/headers

include $(THEOS)/makefiles/common.mk

TWEAK_NAME=Redstone2
Redstone2_CFLAGS = -fobjc-arc
Redstone2_LIBRARIES = objcipc
Redstone2_PRIVATE_FRAMEWORKS = AppSupport
Redstone2_FILES = Redstone2_Core.xm Redstone2_HomeScreen.xm

# Libraries
Redstone2_FILES += Libraries/UIView+Easing.m Libraries/UIFont+WDCustomLoader.m Libraries/CAKeyframeAnimation+AHEasing.m Libraries/easing.c Libraries/UIImageAverageColorAddition.m

# Core
Redstone2_FILES += Core/RSCore.m Core/RSPreferences.m Core/RSMetrics.m Core/RSAesthetics.m

# UI
Redstone2_FILES += UI/RSTiltView.m UI/RSFlyoutMenu.m UI/RSProgressBar.m UI/RSAlertController.m UI/RSAlertAction.m UI/RSTextField.m

# Home Screen
Redstone2_FILES += HomeScreen/RSHomeScreenController.m HomeScreen/RSHomeScreenScrollView.m

# App Switcher
# Redstone2_FILES +=

# Start Screen
Redstone2_FILES += StartScreen/RSStartScreenController.m StartScreen/RSStartScreenScrollView.m StartScreen/RSTile.m StartScreen/RSTileInfo.m

# App List
Redstone2_FILES += AppList/RSAppListController.m AppList/RSAppListScrollView.m AppList/RSAppListSection.m AppList/RSApp.m AppList/RSDownloadingApp.m AppList/RSJumpList.m

# Launch Screen
Redstone2_FILES += LaunchScreen/RSLaunchScreenController.m

include $(THEOS)/makefiles/tweak.mk

ifeq ($(THEOS_TARGET_NAME),iphone_simulator)
after-all::
	@echo Copying .dylib to /opt/simject
	@cp $(THEOS_OBJ_DIR)/$(PROJECT_NAME).dylib /opt/simject
	@cp $(PROJECT_NAME).plist /opt/simject
#	@~/Documents/Xcode/simject/bin/respring_simulator
endif

ifeq ($(THEOS_TARGET_NAME),iphone)
after-install::
	install.exec "killall -9 SpringBoard"
endif

SUBPROJECTS += Redstone2_UIKit Redstone2_Prefs
include $(THEOS_MAKE_PATH)/aggregate.mk
