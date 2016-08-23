#import "RSRootView.h"
#import "RSAppListScrollView.h"


extern CFArrayRef CPBitmapCreateImagesFromData(CFDataRef cpbitmap, void*, int, void*);

@implementation RSRootView

-(id)initWithFrame:(CGRect)frame {
	self = [super initWithFrame:frame];

	[self setHomescreenWallpaper];

	//SBIconModel* iconModel = [[objc_getClass("SBIconController") sharedInstance] model];
	//NSLog(@"[Redstone] %@", [iconModel visibleIconIdentifiers]);

	/*UIView* testView = [[UIView alloc] initWithFrame:CGRectMake(100, 100, 280, 140)];
	[self addSubview:testView];

	RSTiltView* testTilt = [[RSTiltView alloc] initWithFrame:CGRectMake(0, 0, 280, 140)];
	testTilt.transformAngle = 5.0;
	[testView addSubview:testTilt];*/

	[UIFont registerFontFromURL:[NSURL fileURLWithPath:@"/var/mobile/Library/Redstone/Fonts/segoeui.ttf"]];
    [UIFont registerFontFromURL:[NSURL fileURLWithPath:@"/var/mobile/Library/Redstone/Fonts/segoeuil.ttf"]];
    [UIFont registerFontFromURL:[NSURL fileURLWithPath:@"/var/mobile/Library/Redstone/Fonts/segmdl2.ttf"]];

	rootScrollView = [[RSRootScrollView alloc] initWithFrame:self.frame];
	[self addSubview:rootScrollView];

	return self;
}

-(void)resetHomeScrollPosition {
	[rootScrollView resetScrollPosition];
	[rootScrollView->appListScrollView resetAppVisibility];
	[rootScrollView->tileScrollView resetTileVisibility];
	[rootScrollView->searchInput.layer removeAllAnimations];
}

-(void)setHomescreenWallpaper {
	NSMutableDictionary* defaults = [NSMutableDictionary dictionaryWithContentsOfFile:@"/var/mobile/Library/Preferences/ml.festival.redstone.plist"];

	// Get current Homescreen wallpaper (if exists)
	NSData *homeWallpaperData = [NSData dataWithContentsOfFile:@"/var/mobile/Library/SpringBoard/HomeBackground.cpbitmap"];

	// Homescreen wallpaper doesn't exist, use Lockscreen data instead
	// If the same wallpaper is used for both Homescreen and Lockscreen, only Lockscreen data is saved
	if (!homeWallpaperData) {
		homeWallpaperData = [NSData dataWithContentsOfFile:@"/var/mobile/Library/SpringBoard/LockBackground.cpbitmap"];;
	}

	CFDataRef homeWallpaperDataRef = (__bridge CFDataRef)homeWallpaperData;
	NSArray *imageArray = (__bridge NSArray *)CPBitmapCreateImagesFromData(homeWallpaperDataRef, NULL, 1, NULL);
	UIImage *homeWallpaper = [UIImage imageWithCGImage:(CGImageRef)imageArray[0]];

	[defaults setObject:[self hexStringFromColor:[homeWallpaper mergedColor]] forKey:@"autoAccentColor"];

	[self.homeWallpaperView removeFromSuperview];
	self.homeWallpaperView = [[UIImageView alloc] initWithImage:homeWallpaper];
	[self.homeWallpaperView setFrame:CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width, [[UIScreen mainScreen] bounds].size.height)];
	[self insertSubview:self.homeWallpaperView atIndex:0];

	[defaults writeToFile:@"/var/mobile/Library/Preferences/ml.festival.redstone.plist" atomically:YES];
}

-(NSString *)hexStringFromColor:(UIColor *)color {
    const CGFloat *components = CGColorGetComponents(color.CGColor);

    CGFloat r = components[0];
    CGFloat g = components[1];
    CGFloat b = components[2];

    return [NSString stringWithFormat:@"#%02lX%02lX%02lX",
            lroundf(r * 255),
            lroundf(g * 255),
            lroundf(b * 255)];
}

-(BOOL)handleMenuButtonPressed {
	RSAppListScrollView* appList = rootScrollView->appListScrollView;
	RSJumpListView* jumpList = rootScrollView->jumpListView;

	if (currentApplication != nil) {
		return false;
	}

	if (rootScrollView->tileScrollView->isEditing) {
		[rootScrollView->tileScrollView exitEditMode];
	}

	if (jumpList->isOpen) {
		[jumpList hide:nil];

		return true;
	}
	
	if (appList.pinMenuIsOpen) {
		[appList closePinMenu];
		return true;
	}

	if (rootScrollView.contentOffset.x != 0 || rootScrollView->tileScrollView.contentOffset.y != -24)   {
		[rootScrollView setContentOffset:CGPointMake(0,0)];
		[rootScrollView->tileScrollView setContentOffset:CGPointMake(0,-24)];
		return true;
	}

	return false;
}

-(void)applicationDidFinishLaunching {
	[rootScrollView->launchBG setHidden:YES];
	[rootScrollView->tileScrollView prepareForEntryAnimation];
}

-(void)setCurrentApplication:(id)arg1 {
	currentApplication = arg1;
}

@end