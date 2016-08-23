# Redstone
## A Windows 10 Mobile Experience for iOS 9

**NOTE: This is the internal version of Redstone. THERE WILL BE BUGS! Compiling and installing is done at your own risk. There will be no support for using Redstone Internal!**

Back in the days of iOS 5, a developer named EndFinity released a DreamBoard theme called Strife that brought us a Windows Phone 7 experience on iPhone. When iOS 6 was finally jailbroken, he released Paragon, another DreamBoard theme, which brought a Windows Phone 8.1 experience. This DreamBoard theme was updated when iOS 8 was jailbroken to become a native tweak that removed the need for DreamBoard. But since then, nothing.

In early August 2016, I've started a new project called Redstone, which should pick up the idea of having Windows Phone running on your iPhone. But a little bit more modern.

When the project actually started, the Windows 10 Anniversary update had yet to be released, so this project was called Threshold at that time. These names refer to the internal names of the latest Windows 10 versions, 1511 and 1607, called Threshold (2) and Redstone respectively. Because I don't own any Windows Phones, I had to use Microsoft's XDE emulator for references.

The feature set of Redstone is almost identical to Paragon:

- [x] Tile-based Homescreen
- [ ] Tile Pinning
- [ ] Layout Customization (partially implemented)
- [ ] Live Tiles
- [x] App List (including Jump List)
- [ ] App Searching
- [x] Custom App Opening and Closing animations
- [ ] Custom Volume HUD
- [ ] Custom Notifications
- [ ] Custom Lockscreen
- [x] Accent Color based personalization
- [x] NEW: Accent Colors based on your wallpaper
- [x] NEW: Status Bar themes for Anemone (WiFi, Cellular) and Alkaline (Battery)

## Availability

Redstone is currently available as Early Access (current Build: 22) and as an unfinished Internal version at https://festival.ml/repo

It will be completely free (unlike Strife and Paragon) and, as you can see, open source.

## How to contribute

You can contribute to Redstone in two ways:

1: You can submit your own application tiles following the guide [here](http://stories.festival.ml/be-a-part-of-project-redstone-and-submit-your-own-tile-icons-99f260334c11)

2: You can help me finding solutions for the problems in the list(s) below by forking this repo, adding your solution and submit a pull request.

General:

- [ ] Tweak.xm: Find better solutions for initializing, showing and hiding Redstone when needed

Start Screen:

- [ ] The Tile layout engine needs to have a grid where tiles can be cross referenced
- [ ] Tiles need to know where other tiles are, so they can snap automatically
- [ ] If a tile is hovering over another tile (or more), the lower tile(s) should move down to make space for the new tile
- [ ] Tiles need to respect a) other tiles sizes and b) start screen bounds (no overlapping)
- [ ] When resizing a tile to "wide", the tile should not leave the start screen bounds