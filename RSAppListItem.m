#import "RSAppListItem.h"

@implementation RSAppListItem

-(id)initWithFrame:(CGRect)frame withBundleIdentifier:(NSString*)bundleIdentifier {
	self = [super initWithFrame:frame];

	appBundleIdentifier = bundleIdentifier;
	application = [[objc_getClass("SBApplicationController") sharedInstance] applicationWithBundleIdentifier:appBundleIdentifier];
	model = (SBIconModel *)[[objc_getClass("SBIconController") sharedInstance] model];
    tileInfo = [NSDictionary dictionaryWithContentsOfFile:[NSString stringWithFormat:@"%@/Tiles/%@/Tile.plist", REDSTONE_LIBRARY_PATH, bundleIdentifier]];

    // innerView = [[RSTiltView alloc] initWithFrame:CGRectMake(0,0,frame.size.width, frame.size.height)];
    // [innerView setTransformOptions:@{
    //     @"transformAngle": @5.0,
    //     @"transformMultiplierX": @0.3,
    //     @"transformMultiplierY": @4,
    // }];
    // innerView.hasHighlight = YES;

    [self addSubview:innerView];

	appLabel = [[UILabel alloc] initWithFrame:CGRectMake(64, 2, self.frame.size.width-54, 50)];
	appLabel.text = [application displayName];
	appLabel.font = [UIFont fontWithName:@"SegoeUI" size:18];
    appLabel.textColor = [UIColor whiteColor];
    [self addSubview:appLabel];

    appImageTile = [[UIView alloc] initWithFrame:CGRectMake(2, 2, 50, 50)];
    [appImageTile setBackgroundColor:[RSAesthetics accentColorForApp:bundleIdentifier]];
    [self addSubview:appImageTile];

    appImage = [[UIImageView alloc] initWithImage:[RSAesthetics getTileImage:bundleIdentifier withSize:0]];
    if ([[tileInfo objectForKey:@"isFullsizeTile"] boolValue]) {
        [appImage setFrame:CGRectMake(0,0,50,50)];
    } else {
        [appImage setFrame:CGRectMake(9,9,32,32)];
    }
    [appImageTile addSubview:appImage];

    self.hasHighlight = YES;

    _transformAngle = 5;
    _transformMultiplierX = 0.3;
    _transformMultiplierY = 4;

	return self;
}

-(void)setTileBackgroundColor:(UIColor*)backgroundColor {
    [appImageTile setBackgroundColor:backgroundColor];
}

-(void)setParentScrollView:(RSAppListScrollView*)parent {
    parentScrollView = parent;
}

-(void)tapped:(UITapGestureRecognizer*)sender {
	[super tapped:sender];

	/*id app = [[objc_getClass("SBApplicationController") sharedInstance] applicationWithBundleIdentifier:appBundleIdentifier];
    [app setFlag:1 forActivationSetting:1];
    [[objc_getClass("SBUIController") sharedInstance] activateApplication:app];*/
    [parentScrollView triggerAppLaunch:appBundleIdentifier sender:self];
}

-(void)pressed:(UILongPressGestureRecognizer*)sender {
    if (sender.state == UIGestureRecognizerStateBegan) {
        [self untilt:YES overridesHighlight:YES];

        [parentScrollView openPinMenu:self];
    }
}

@end