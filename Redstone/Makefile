# MAKEFILE 2

# Configure your device details here
export THEOS_DEVICE_IP=192.168.178.38
export THEOS_DEVICE_PORT=22

# Set the package version
export PACKAGE_VERSION = $(shell date +%y)w$(shell date +%V)a

# DO NOT EDIT ANYTHING BEYOND THIS POINT
export GO_EASY_ON_ME = 1

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = Redstone
Redstone_FRAMEWORKS = MediaPlayer
Redstone_PRIVATE_FRAMEWORKS = AppSupport MediaRemote
Redstone_FILES = Redstone_Core.xm Redstone_StartScreen.xm Redstone_LockScreen.xm Redstone_Notifications.xm

# Core
Redstone_FILES += Core/RSCore.m Core/RSAesthetics.m Core/RSMetrics.m Core/RSRootScrollView.m Core/RSPreferences.m Core/RSModalAlert.m Core/RSTiltView.m Core/RSNotificationView.m

# Lib
Redstone_FILES += Lib/UIView+Easing.m Lib/easing.c Lib/CAKeyframeAnimation+AHEasing.m Lib/UIFont+WDCustomLoader.m Lib/UIImageAverageColorAddition.m

# Start Screen
Redstone_FILES += Start/RSStartScreenController.m Start/RSStartScrollView.m Start/RSTile.m Start/RSTileInfo.m

# Launch Screen
Redstone_FILES += Launch/RSLaunchScreenController.m Launch/RSLaunchScreen.m

# App List
Redstone_FILES += AppList/RSAppListController.m AppList/RSAppList.m AppList/RSApp.m AppList/RSAppListSection.m AppList/RSPinMenu.m AppList/RSSearchBar.m AppList/RSJumpList.m

# Lock Screen
Redstone_FILES += LockScreen/RSLockScreenController.m LockScreen/RSLockScreenView.m LockScreen/RSLockScreenMediaControlsView.m LockScreen/RSLockScreenPasscodeEntryController.m LockScreen/RSLockScreenPasscodeEntryView.m LockScreen/RSLockScreenPasscodeEntryButton.m LockScreen/RSLockScreenPasscodeEntryTextField.m

include $(THEOS)/makefiles/tweak.mk

# Copy the compiled dylib to simject's directory
# You don't need to comment this when building for a device,
# only when you don't use simject at all
ifeq ($(THEOS_TARGET_NAME),iphone_simulator)
after-all::
	@echo Copying .dylib to /opt/simject
	@cp $(THEOS_OBJ_DIR)/$(PROJECT_NAME).dylib /opt/simject
	@cp $(PROJECT_NAME).plist /opt/simject
	@~/Documents/Xcode/simject/bin/respring_simulator
endif

after-install::
	install.exec "killall -9 SpringBoard"
SUBPROJECTS += redstone_prefs
include $(THEOS_MAKE_PATH)/aggregate.mk
