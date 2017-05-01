/*
 * Redstone
 * A Windows 10 Mobile experience for iOS
 * Compatible with iOS 9 (tested with iOS 9.3.3);
 *
 * Licensed under GNU GPLv3
 *
 * © 2016 Sniper_GER, FESTIVAL Development
 * All rights reserved.
 */

// This class acts like the default ViewController in a UIKit app. It initializes all components of Redstone and pushes the views to SpringBoard's UIWindow.

@class RSPreferences, RSRootScrollView, RSStartScreenController;

@interface Redstone : NSObject {
	UIWindow* window;
	RSPreferences* preferences;
	RSRootScrollView* rootScrollView;
	RSStartScreenController* startScreenController;
}

+ (id)sharedInstance;
+ (void)hideAllExcept:(id)objectToShow;
+ (void)showAllExcept:(id)objectToHide;

- (id)initWithWindow:(id)_window;
- (void)setWindow:(UIWindow*)_window;
- (UIWindow*)window;
- (RSRootScrollView*)rootScrollView;
- (UIImageView*)wallpaperView;
- (BOOL)handleMenuButtonEvent;
- (void)frontDisplayDidChange:(id)activeApplication;
- (void)finishUIUnlockFromSource;
- (void)loadFonts;
- (void)updatePreferences;

@end
