#import "RSRootScrollView.h"
#import "Redstone.h"
#import "RSSearchBar.h"
#import "RSLaunchScreenController.h"
#import "RSAppListController.h"

@implementation RSRootScrollView

RSRootScrollView* sharedInstance;

+(id)sharedInstance {
	return sharedInstance;
}

-(id)initWithFrame:(CGRect)frame {
	NSUserDefaults* defaults = [[NSUserDefaults alloc] initWithSuiteName:@"ml.festival.redstone"];
	self = [super initWithFrame:frame];
	sharedInstance = self;

	if (self) {
		[self setContentSize:CGSizeMake(self.frame.size.width*2, self.frame.size.height)];
		[self setPagingEnabled:YES];
		[self setBounces:NO];
		[self setShowsVerticalScrollIndicator:NO];
		[self setShowsHorizontalScrollIndicator:NO];
		[self setDelaysContentTouches:NO];
		[self setMultipleTouchEnabled:NO];
		[self setDelegate:self];

		// Background
		if ([[defaults objectForKey:@"showWallpaper"] boolValue]) {
			transparentView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width, [[UIScreen mainScreen] bounds].size.height)];
			[transparentView setBackgroundColor:[UIColor colorWithWhite:0.0 alpha:0.75]];
			[transparentView setAlpha:0];
			[self addSubview:transparentView];
		}
	}
	return self;
}

-(void)scrollViewDidScroll:(UIScrollView*)sender {
	if ([[RSAppListController sharedInstance] isSearching]) {
		[[RSAppListController sharedInstance] setIsSearching:NO];
	}

	CGFloat width = sender.frame.size.width;
	CGFloat page = (sender.contentOffset.x / width);
	
	[[[RSLaunchScreenController sharedInstance] launchScreen] setFrame:CGRectMake(sender.contentOffset.x,0, [[UIScreen mainScreen] bounds].size.width, [[UIScreen mainScreen] bounds].size.height)];
	
	if (transparentView) {
		[transparentView setFrame:CGRectMake(sender.contentOffset.x,0, [[UIScreen mainScreen] bounds].size.width, [[UIScreen mainScreen] bounds].size.height)];
		[transparentView setAlpha:page];
	}
}

-(void)updatePreferences {
	NSUserDefaults* defaults = [[NSUserDefaults alloc] initWithSuiteName:@"ml.festival.redstone"];

	// Background
	if (transparentView) {
		[transparentView removeFromSuperview];
	}

	if ([[defaults objectForKey:@"showWallpaper"] boolValue]) {
		transparentView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width, [[UIScreen mainScreen] bounds].size.height)];
		[transparentView setBackgroundColor:[UIColor colorWithWhite:0.0 alpha:0.75]];
		[transparentView setAlpha:0];
		[self insertSubview:transparentView atIndex:0];
	}
}

@end