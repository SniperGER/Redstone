# Redstone
A Windows 10 Mobile experience for iOS 9 and 10

Redstone is a home screen replacement for your iPhone and iPod touch. Based on the idea of Paragon, bringing the tile based UI of Windows Phone 8.1 to your iOS device, Redstone delivers a more modern approach using the modern UI of Windows 10 Mobile.

You can customize your start screen by pinning the tiles you need while unpinning those you don't need, resizing and rearranging them however you like. Choose an accent color you like that fits your current mood. Uninstall apps directly from the app list without leaving Redstone at all. These are just a few features of many to come.

**Current features:**

* Pin, unpin, resize and rearrange tiles
* Launch apps from App List and quickly navigate using Jump List
* Tile badges (eg. Notification count, updates etc)
* Uninstall apps from within Redstone
* Per-app Launch Screen
* Extendable with tile icons and per-tile accent colors
* Lock screen replacement (with media and passcode support)
* Notifications
* Live tiles (another extension part)
* System-wide volume control

**Planned features:**

* App Switcher
* 3D Touch support for tiles and App List

Redstone is based on Windows 10 Mobile (Build 10.0.15063.0). Please note that this is a pre-release preview with features that are subject to change at any time.


## Build Instructions
Please note that this Internal version currently only supports iOS 10

### Requirements

* Xcode 8.2.1 (or later)
* [Theos](https://github.com/theos/theos)
* iOS 10.1 SDK with private frameworks (for compiling for ARM)
* libobjcipc.dylib in `$(THEOS)/lib/`, headers in `$(THEOS)/include/objcipc`
* SSH configured for your device (`ssh-copy-id`)
* [simject](https://github.com/angelxwind/simject) (optional, injects dylibs into Simulator)

Please note that Redstone is currently using a custom made library that I haven't released the source code of yet, as it's currently only working on iOS 10. To compile Redstone without this library, remove `WeatherManager` from `Redstone2_LIBRARIES` and remove the Weather Live Tile from Target Dependecies.

### Build for devices

* Change `THEOS_DEVICE_IP` to your device IP
	* If using `iproxy`, change `THEOS_DEVICE_IP` to `localhost` and `THEOS_DEVICE_PORT` to 2222
* Select the "Install" target in Xcode, and select either "Generic iOS Device" or your own device (if connected to your Mac)

If everything works correctly, your device should respring within a minute and Redstone should be installed
