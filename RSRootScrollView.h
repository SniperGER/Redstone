/*
  Redstone
  A Windows 10 Mobile experience for iOS
  Compatible with iOS 9 (tested with iOS 9.3.3)

  Licensed under GNU GPLv3

  © 2016 Sniper_GER, FESTIVAL Development
  All rights reserved.
*/

#import <UIKit/UIKit.h>
#import <objc/runtime.h>

@class RSSearchBar;

@interface RSRootScrollView : UIScrollView <UIScrollViewDelegate> {
	UIView* transparentView;
	RSSearchBar* searchBar;
}

+(id)sharedInstance;
-(void)updatePreferences;

@end