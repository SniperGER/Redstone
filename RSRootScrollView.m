//
//  RSRootScrollView.m
//  
//
//  Created by Janik Schmidt on 06.08.16.
//
//

#import "Headers.h"

@implementation RSRootScrollView

-(id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    self.delegate = self;
    [self setPagingEnabled:YES];
    [self setShowsHorizontalScrollIndicator:NO];
    
#if !TARGET_IPHONE_SIMULATOR
    [UIFont registerFontFromURL:[NSURL fileURLWithPath:@"/var/mobile/Library/Redstone/Fonts/segoeui.ttf"]];
    [UIFont registerFontFromURL:[NSURL fileURLWithPath:@"/var/mobile/Library/Redstone/Fonts/segoeuil.ttf"]];
    [UIFont registerFontFromURL:[NSURL fileURLWithPath:@"/var/mobile/Library/Redstone/Fonts/segmdl2.ttf"]];
#endif
    
    [self setContentSize:CGSizeMake([[UIScreen mainScreen] bounds].size.width*2, [[UIScreen mainScreen] bounds].size.height)];
    
    // Background
    self.transparentBG = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width, [[UIScreen mainScreen] bounds].size.height)];
    [self.transparentBG setBackgroundColor:[UIColor colorWithWhite:0.0 alpha:0.6]];
    [self.transparentBG setAlpha:0];
    
    // Tiles
    self.startScrollView = [[RSTileScrollView alloc] initWithFrame:CGRectMake(2, 0, [[UIScreen mainScreen] bounds].size.width-4, [[UIScreen mainScreen] bounds].size.height)];
    self.startScrollView.parentRootScrollView = self;
    
    // App List
    self.appListScrollView = [[RSAppList alloc] init];
    self.appListScrollView.parentRootScrollView = self;
    
    // Jump List
    self.jumpListView = [[RSJumpListView alloc] initWithFrame:CGRectMake([[UIScreen mainScreen] bounds].size.width, 0, [[UIScreen mainScreen] bounds].size.width, [[UIScreen mainScreen] bounds].size.height) withAppList:self.appListScrollView];
    [self.jumpListView setHidden:YES];
    
    // Application Launch Image
    self.launchBG = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width, [[UIScreen mainScreen] bounds].size.height)];
    [self.launchBG setBackgroundColor:[UIColor blackColor]];
    [self.launchBG setHidden:YES];
    
    
    [self addSubview:self.transparentBG];
    [self addSubview:self.startScrollView];
    
    //RSTiltButton* testTiltButton = [[RSTiltButton alloc] initWithFrame:CGRectMake(80,80,140,140)];
    //[self addSubview:testTiltButton];
    
    [self addSubview:self.appListScrollView.tableView];
    [self addSubview:self.jumpListView];
    [self addSubview:self.launchBG];
    
    return self;
}

-(void)scrollViewDidScroll:(UIScrollView*)sender {
    CGFloat width = sender.frame.size.width;
    CGFloat page = (sender.contentOffset.x / width);
    
    [self.transparentBG setFrame:CGRectMake(sender.contentOffset.x,0, [[UIScreen mainScreen] bounds].size.width, [[UIScreen mainScreen] bounds].size.height)];
    [self.launchBG setFrame:CGRectMake(sender.contentOffset.x,0, [[UIScreen mainScreen] bounds].size.width, [[UIScreen mainScreen] bounds].size.height)];
    
    [self.transparentBG setAlpha:page];
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
    
    [[self.launchBG subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
    UIImageView* launchBGImage = [[UIImageView alloc] initWithImage:[RSTileDelegate getTileImage:bundleIdentifier withSize:@"large"]];
    [launchBGImage setFrame:CGRectMake(CGRectGetMidX(self.launchBG.bounds)-34, CGRectGetMidY(self.launchBG.bounds)-34, 68 , 68)];
    [self.launchBG addSubview:launchBGImage];
    
    [self.launchBG setBackgroundColor:[RSTileDelegate getIndividualTileColor:bundleIdentifier]];
    
    [self.launchBG setHidden:NO];
    [[[self.launchBG subviews] objectAtIndex:0].layer addAnimation:scale forKey:@"scale"];
    [self.launchBG.layer addAnimation:opacity forKey:@"opacity"];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        id app = [[objc_getClass("SBApplicationController") sharedInstance] applicationWithBundleIdentifier:bundleIdentifier];
        [app setFlag:1 forActivationSetting:1];
        [[objc_getClass("SBUIController") sharedInstance] activateApplication:app];
    });
}

-(void)showJumpList {
    [self.jumpListView show];
}

-(void)willAnimateDeactivation {
    [self setHidden:NO];
    [self.launchBG setHidden:YES];
    [self setContentOffset:CGPointMake(0, 0)];
    [self.startScrollView tileEntryAnimation];
    [self.appListScrollView resetAppVisibility];
}

-(void)deckSwitcherDidAppear {
    [self setHidden:NO];
    [self.startScrollView resetTileVisibility];
    [self.appListScrollView resetAppVisibility];
}

-(void)applicationDidFinishLaunching {
    [self setHidden:YES];
    [self.launchBG setHidden:YES];
    [self setContentOffset:CGPointMake(0, 0)];
    [self.appListScrollView resetAppVisibility];
}

-(void)handleHomeButtonPress {
    
}

@end
