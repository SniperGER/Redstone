# MAKEFILE 2

# Configure your device details here
export THEOS_DEVICE_IP=192.168.178.38
export THEOS_DEVICE_PORT=22

# Set the package version
export PACKAGE_VERSION = $(shell date +%y)w$(shell date +%V)a

# Configure the target here
TARGET = iphone:latest		# Phyiscal devices
TARGET = simulator:clang	# Simulator


# DO NOT EDIT ANYTHING BEYOND THIS POINT
export GO_EASY_ON_ME = 1

include /opt/theos/makefiles/common.mk

TWEAK_NAME = Redstone

# Core
Redstone_FILES = Redstone.xm RSCore.m RSMetrics.m RSRootScrollView.m

# Lib
Redstone_FILES += UIView+Easing.m

# Start Screen
Redstone_FILES += RSStartScreenController.m RSStartScrollView.m RSTile.m

include /opt/theos/makefiles/tweak.mk

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
