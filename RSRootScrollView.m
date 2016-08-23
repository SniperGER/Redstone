#import "RSRootScrollView.h"

@implementation RSRootScrollView

-(id)initWithFrame:(CGRect)frame {
	self = [super initWithFrame:frame];

	self.delegate = self;
    [self setPagingEnabled:YES];
    [self setShowsHorizontalScrollIndicator:NO];
    [self setDelaysContentTouches:NO];

	[self setContentSize:CGSizeMake([[UIScreen mainScreen] bounds].size.width*2, [[UIScreen mainScreen] bounds].size.height)];

	// Background
    transparentBG = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width, [[UIScreen mainScreen] bounds].size.height)];
    [transparentBG setBackgroundColor:[UIColor colorWithWhite:0.0 alpha:0.6]];
    [transparentBG setAlpha:0];
    [self addSubview:transparentBG];

    tileScrollView = [[RSTileScrollView alloc] initWithFrame:CGRectMake(2, 0, [[UIScreen mainScreen] bounds].size.width-4, [[UIScreen mainScreen] bounds].size.height)];
    tileScrollView.parentRootScrollView = self;
    [self addSubview:tileScrollView];

	searchInput = [[RSSearchBar alloc] initWithFrame:CGRectMake([[UIScreen mainScreen] bounds].size.width+2, 24, self.frame.size.width-4, 40)];
	//[searchInput textRectForBounds:CGRectMake(6, 5, searchInput.frame.size.width-12, searchInput.frame.size.height-5)];
	//[searchInput editingRectForBounds:CGRectMake(6, 5, searchInput.frame.size.width-12, searchInput.frame.size.height-5)];
	
	[self addSubview:searchInput];

	appListScrollView = [[RSAppListScrollView alloc] init];
	appListScrollView.rootScrollView = self;
	[self addSubview:appListScrollView.tableView];

	jumpListView = [[RSJumpListView alloc] initWithFrame:CGRectMake([[UIScreen mainScreen] bounds].size.width,0,self.frame.size.width, self.frame.size.height)];
	jumpListView.rootScrollView = self;
	[self addSubview:jumpListView];

    // Application Launch Image
    launchBG = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width, [[UIScreen mainScreen] bounds].size.height)];
    [launchBG setBackgroundColor:[UIColor colorWithWhite:0.2 alpha:1.0]];
    [launchBG setHidden:YES];
    [self addSubview:launchBG];

	return self;
}

-(void)showLaunchImage:(NSString*)bundleIdentifier {
    CAAnimation *opacity = [CAKeyframeAnimation animationWithKeyPath:@"opacity"
                                                            function:CubicEaseOut
                                                           fromValue:0.0
                                                             toValue:1.0];
    opacity.duration = 0.3;
    opacity.removedOnCompletion = NO;
    opacity.fillMode = kCAFillModeForwards;
    
    CAAnimation *scale = [CAKeyframeAnimation animationWithKeyPath:@"transform.scale"
                                                          function:CubicEaseOut
                                                         fromValue:0.8
                                                           toValue:1.0];
    scale.duration = 0.5;
    scale.removedOnCompletion = NO;
    scale.fillMode = kCAFillModeForwards;
    
    [[launchBG subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
    UIImageView* launchBGImage = [[UIImageView alloc] initWithImage:[RSAesthetics getTileImage:bundleIdentifier withSize:10]];
    [launchBGImage setFrame:CGRectMake(CGRectGetMidX(launchBG.bounds)-34, CGRectGetMidY(launchBG.bounds)-34, 68 , 68)];
    [launchBG addSubview:launchBGImage];
    
    [launchBG setBackgroundColor:[RSAesthetics accentColorForLaunchScreen:bundleIdentifier]];
    [launchBG setHidden:NO];
    //[[[launchBG subviews] objectAtIndex:0].layer addAnimation:scale forKey:@"scale"];
    [launchBG.layer addAnimation:opacity forKey:@"opacity"];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        id app = [[objc_getClass("SBApplicationController") sharedInstance] applicationWithBundleIdentifier:bundleIdentifier];
        [app setFlag:1 forActivationSetting:1];
        [[objc_getClass("SBUIController") sharedInstance] activateApplication:app];
    });
}

-(void)resetScrollPosition {
    [self setContentOffset:CGPointMake(0,0)];
    [tileScrollView setContentOffset:CGPointMake(0,-24)];
    [self setScrollEnabled:YES];
    [jumpListView hide:nil];
    [appListScrollView.tableView setContentOffset:CGPointMake(0,0)];
}

-(void)scrollViewDidScroll:(UIScrollView*)sender {
    CGFloat width = sender.frame.size.width;
    CGFloat page = (sender.contentOffset.x / width);
    
    [transparentBG setFrame:CGRectMake(sender.contentOffset.x,0, [[UIScreen mainScreen] bounds].size.width, [[UIScreen mainScreen] bounds].size.height)];
    [launchBG setFrame:CGRectMake(sender.contentOffset.x,0, [[UIScreen mainScreen] bounds].size.width, [[UIScreen mainScreen] bounds].size.height)];
    
    [transparentBG setAlpha:page];
}

- (BOOL)touchesShouldCancelInContentView:(UIView *)view {
    if ([view isKindOfClass:RSTiltView.class]) {
        return YES;
    }

    return [super touchesShouldCancelInContentView:view];
}

@end