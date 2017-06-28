# Makefile 3

export THEOS_DEVICE_IP=192.168.178.38
export THEOS_DEVICE_PORT=22

export PACKAGE_VERSION = $(shell date +%y)w$(shell date +%V)a-Internal
#export ADDITIONAL_CFLAGS = -I$(THEOS_PROJECT_DIR)/headers

include $(THEOS)/makefiles/common.mk

TWEAK_NAME=Redstone2
Redstone2_CFLAGS = -fobjc-arc
Redstone2_FILES = Redstone2_Core.xm Redstone2_HomeScreen.xm

# Core
Redstone2_FILES += Core/RSCore.m Core/RSPreferences.m Core/RSMetrics.m Core/RSAesthetics.m

# Home Screen
Redstone2_FILES += HomeScreen/RSHomeScreenController.m HomeScreen/RSHomeScreenScrollView.m

# App Switcher
# Redstone2_FILES +=

# Start Screen
Redstone2_FILES += StartScreen/RSStartScreenController.m

include $(THEOS)/makefiles/tweak.mk

ifeq ($(THEOS_TARGET_NAME),iphone_simulator)
after-all::
	@echo Copying .dylib to /opt/simject
	@cp $(THEOS_OBJ_DIR)/$(PROJECT_NAME).dylib /opt/simject
	@cp $(PROJECT_NAME).plist /opt/simject
#	@~/Documents/Xcode/simject/bin/respring_simulator
endif
