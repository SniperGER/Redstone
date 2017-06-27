# Redstone Live Tile Template

This template provides a very basic base to create a Live Tile for Redstone. Tiles are loaded using an app's bundle identifier (eg. `com.apple.weather`), so your live tile should be named `com.apple.weather.tile`, while the executable can have any name you want. Your live tile must conform to `RSLiveTileDelegate` to be loaded by Redstone, else it will crash SpringBoard.

If you implement more than one class, make sure you set the principle class in Info.plist to your main class (the class that adopts `RSLiveTileDelegate`).

You can use any framework that Xcode provides. To use private frameworks, use `dlopen` to load them into your binary at runtime. You can find headers for private frameworks at http://developer.limeos.net. To access classes within private frameworks, use `objc_getClass` Example:
```
#import <dlfcn.h>
#import <objc/runtime.h>
#import "WeatherPreferences.h"

- (id)initWithFrame:(CGRect)frame tile:(RSTile *)tile {
    if (self = [super initWithFrame:frame]) {
        self.tile = tile;
        
        // Load the Weather framework into the Live Tile
        dlopen("/System/Library/PrivateFrameworks/Weather.framework/Weather", RTLD_NOW);
        
        // Access weather preferencesAccess
        WeatherPreferences* preferences = [objc_getClass("WeatherPreferences") sharedPreferences];
    }

    return self;
}
```

Live Tiles are required to be signed. I don't exactly know why, but without signing, they won't get loaded. The signing process is already included in the build phases, but if you want to sign a binary manually, here's the code:
`codesign --force --sign - --timestamp=none $CODESIGNING_FOLDER_PATH/$PRODUCT_NAME`

To create a Live Tile from scratch, create a new Bundle Target (from the macOS tab), set its Base SDK to whatever you like (iOS 10.2 recommended), disable Bitcode (`ENABLE_BITCODE=NO`) and add a new "Run Script Phase" using the code above.

## Installation
### iOS Device

Copy the build output (`$(PRODUCT_NAME).tile`) to `/var/mobile/Library/FESTIVAL/Redstone/Live Tiles` on your device and restart SpringBoard.

## Using Swift to create a Live Tile

While it's technically possible to create a Live Tile using Swift, it is not recommended at this point. Swift-based Live Tiles require Swift Libraries to be installed on the device. No major repository (BigBoss, ModMyi) currently has these packages. Only the HASHBANG repo (https://cydia.hbang.ws) and our own FESTIVAL Development repo (https://festival.ml/repo) have such packages. To use your Swift Live Tile, you must not install more than one of these packages conforming to the Swift version you are using (libswift-3.0.2 is recommended as it has been confirmed working on iOS 10.2).

To create a Live Tile using Swift, create a Swift class and an Objective-C Bridging Header, in which you import ``RSLiveTileDelegate.h. Make sure the class conforms to `RSLiveTileDelegate`, just like its Objective-C counterpart. Do not ship the live tile with a mix of languages (unless a required library requires you to do so).
