#import "RSAppListScrollView.h"
#import "RSAppListItem.h"
#import "RSTiltView.h"

@implementation RSAppListScrollView

-(UITableView *)makeTableView {
    CGFloat x = [[UIScreen mainScreen] bounds].size.width;
    //CGFloat x = 0;
    CGFloat y = 80;
    CGFloat width = [[UIScreen mainScreen] bounds].size.width;
    CGFloat height = [[UIScreen mainScreen] bounds].size.height - 80;
    CGRect tableFrame = CGRectMake(x, y, width, height);
    
    UITableView* tableView = [[UITableView alloc] initWithFrame:tableFrame style:UITableViewStylePlain];
    
    tableView.backgroundColor = [UIColor colorWithWhite:0 alpha:0];
    tableView.contentInset = UIEdgeInsetsMake(0, 0, 80, 0);
    tableView.rowHeight = 54;
    tableView.sectionHeaderHeight = 60;
    tableView.showsVerticalScrollIndicator = NO;
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    tableView.delaysContentTouches = NO;
    
    tableView.delegate = self;
    
    return tableView;
}

-(void)viewDidLoad {
	[super viewDidLoad];

	appsInList = [RSApplicationDelegate listVisibleIcons];
	appSections = [[NSMutableDictionary alloc] init];
	sectionKeysWithApps = [[NSMutableArray alloc] init];

	[self addAppsAndSections];

	appSectionHeaders = [[NSMutableArray alloc] init];
	appSectionListItems = [[NSMutableArray alloc] init];

	self.tableView = [self makeTableView];

	[[NSNotificationCenter defaultCenter] addObserverForName:@"applicationPinned"
							object:nil
							 queue:[NSOperationQueue mainQueue]
						usingBlock:^(NSNotification *note){
		[self closePinMenu];

		dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.15 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
	    	[self.rootScrollView setContentOffset:CGPointMake(0,0) animated:YES];
	    });
	}];
}

- (BOOL)touchesShouldCancelInContentView:(UIView *)view {
    if ([view isKindOfClass:RSTiltView.class]) {
        return YES;
    }

    return NO;
}

- (void)openPinMenu:(RSAppListItem*)appListItem {
	if (!self.pinMenuIsOpen) {
		for (RSAppListItem* appListEntry in appSectionListItems) {
			[appListEntry setUserInteractionEnabled:NO];
		}

		CGPoint originInSuperview = [appListItem convertPoint:CGPointZero toView:self.tableView];
		CGFloat yPos = originInSuperview.y-54;
		BOOL pinMenuIsTop = (yPos+54 < ([[UIScreen mainScreen] bounds].size.height/2)-80);

		if (pinMenuIsTop) {
			yPos = originInSuperview.y+appListItem.frame.size.height;
		}

		applicationAboutToPin = appListItem->appBundleIdentifier;

		applicationPinMenu = [[RSPinMenu alloc] initWithFrame:CGRectMake([[UIScreen mainScreen] bounds].size.width/2-150,yPos,300,54)];
		[applicationPinMenu playOpeningAnimation:pinMenuIsTop];
		[applicationPinMenu setAppBundleIdentifier:applicationAboutToPin];
	    [self.view addSubview:applicationPinMenu];

	    self.pinMenuIsOpen = YES;
	    self.tableView.scrollEnabled = NO;

	    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
	    	[appListItem setHighlighted:YES]; 
	    });
	}
}

- (void)closePinMenu {
	[applicationPinMenu removeFromSuperview];
	self.tableView.scrollEnabled = YES;
	self.pinMenuIsOpen = NO;

	for (RSAppListItem* appListEntry in appSectionListItems) {
		[appListEntry setUserInteractionEnabled:YES];
		[appListEntry setHighlighted:NO];
	}
}

-(void)triggerAppLaunch:(NSString*)applicationIdentifier sender:(RSAppListItem*)sender {
    CAAnimation *opacity = [CAKeyframeAnimation animationWithKeyPath:@"opacity"
                                                            function:CubicEaseIn
                                                           fromValue:1.0
                                                             toValue:0.0];
    opacity.duration = 0.25;
    opacity.removedOnCompletion = NO;
    opacity.fillMode = kCAFillModeForwards;
    
    CAAnimation *scale = [CAKeyframeAnimation animationWithKeyPath:@"transform.scale"
                                                          function:CubicEaseIn
                                                         fromValue:1.0
                                                           toValue:4.0];
    scale.duration = 0.3;
    scale.removedOnCompletion = NO;
    scale.fillMode = kCAFillModeForwards;
    
    NSMutableArray* animatableRows = [[NSMutableArray alloc] init];
    for (NSIndexPath* i in [self.tableView indexPathsForVisibleRows])
    {
        RSAppListItemContainer* app = (RSAppListItemContainer*)[self.tableView cellForRowAtIndexPath:i];
        if (app != nil && (int)[animatableRows indexOfObject:app] == -1) {
            [animatableRows addObject:app];
        }
    }
    
    for (RSAppListSection* section in appSectionHeaders) {
        scale.duration = 0.15;
        [section.layer addAnimation:opacity forKey:@"opacity"];
    }

    [self.rootScrollView->searchInput.layer addAnimation:opacity forKey:@"opacity"];
    
    for (UIView* view in animatableRows) {
        scale.duration = 0.30;
        [view.layer removeAllAnimations];
        
        CGPoint basePoint = [view convertPoint:[view bounds].origin toView:self.view];
        
        float layerX = -(basePoint.x-CGRectGetMidX(self.view.bounds))/view.frame.size.width;
        float layerY = -(basePoint.y-CGRectGetMidY(self.view.bounds))/view.frame.size.height;
        
        view.center = CGPointMake(CGRectGetMidX(self.view.bounds), CGRectGetMidY(self.view.bounds));
        view.layer.anchorPoint = CGPointMake(layerX, layerY);
        
        float delay = 0.01*(int)[animatableRows indexOfObject:view];
        
        scale.beginTime = CACurrentMediaTime()+delay;
        opacity.beginTime = CACurrentMediaTime()+delay;
        
        if (view == sender.superview) {
            scale.beginTime = CACurrentMediaTime()+delay+0.05;
            opacity.beginTime = CACurrentMediaTime()+delay+0.04;
        }
        [view.layer setShouldRasterize:YES];
		view.layer.rasterizationScale = [[UIScreen mainScreen] scale];
		view.layer.contentsScale = [[UIScreen mainScreen] scale];
        
        [view.layer addAnimation:scale forKey:@"scale"];
        [view.layer addAnimation:opacity forKey:@"opacity"];
    }
    
    float delayInSeconds = 0.01*(int)[animatableRows count] + 0.3;
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.rootScrollView showLaunchImage:sender->appBundleIdentifier];
    });
}

-(void)resetAppVisibility {
    for (UIView* view in appSectionListItems) {
        [view setHidden:NO];
        [view.layer setOpacity:1];
        [view.layer removeAllAnimations];
    }
    
    for (UIView* view in appSectionHeaders) {
        [view setHidden:NO];
        [view.layer setOpacity:1];
        [view.layer removeAllAnimations];
    }
    
    for (int i=0; i<[appSections count]; i++) {
        for (int j=0; j<(int)[self.tableView numberOfRowsInSection:i]; j++) {
            RSAppListItemContainer* cell = (RSAppListItemContainer*)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:j inSection:i]];
            [cell setHidden:NO];
            [cell.layer setOpacity:1];
            [cell.layer removeAllAnimations];
        }
    }
}

-(void)setAnchorPoint:(CGPoint)anchorPoint forView:(UIView *)view {
    CGPoint newPoint = CGPointMake(view.bounds.size.width * anchorPoint.x,
                                   view.bounds.size.height * anchorPoint.y);
    CGPoint oldPoint = CGPointMake(view.bounds.size.width * view.layer.anchorPoint.x,
                                   view.bounds.size.height * view.layer.anchorPoint.y);
    
    newPoint = CGPointApplyAffineTransform(newPoint, view.transform);
    oldPoint = CGPointApplyAffineTransform(oldPoint, view.transform);
    
    CGPoint position = view.layer.position;
    
    position.x -= oldPoint.x;
    position.x += newPoint.x;
    
    position.y -= oldPoint.y;
    position.y += newPoint.y;
    
    view.layer.position = position;
    view.layer.anchorPoint = anchorPoint;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return [sectionKeysWithApps count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return [[appSections objectForKey:[sectionKeysWithApps objectAtIndex:section]] count];
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
	NSString* sectionTitleText = [sectionKeysWithApps objectAtIndex:section];
	if ([sectionTitleText isEqualToString:@"numeric"]) {
		sectionTitleText = @"#";
	} else if ([sectionTitleText isEqualToString:@"specialChars"]) {
		sectionTitleText = @"\uE12B";
	}

    RSAppListSection* sectionTitle = [[RSAppListSection alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, 60) withSectionTitle:sectionTitleText];
    sectionTitle.rootScrollView = self.rootScrollView;
    [appSectionHeaders addObject:sectionTitle];
    
    return sectionTitle;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	NSArray* activeSection = [appSections objectForKey:[sectionKeysWithApps objectAtIndex:[indexPath section]]];

	RSAppListItemContainer *cell = [[RSAppListItemContainer alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, 54) withBundleIdentifier:[activeSection objectAtIndex:indexPath.row]];
	//RSAppListItem* listItem = [[RSAppListItem alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, 54) withBundleIdentifier:[activeSection objectAtIndex:indexPath.row]];
	//[cell addSubview:listItem];
	[[cell getAppListItem] setParentScrollView:self];

	[appSectionListItems addObject:[cell getAppListItem]];

	cell.backgroundColor = [UIColor clearColor];
    cell.backgroundView = nil;

    UIView *bgColorView = [[UIView alloc] init];
    bgColorView.backgroundColor = [UIColor clearColor];
    [cell setSelectedBackgroundView:bgColorView];

	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}

// - (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
// 	NSString* title = [sectionKeysWithApps objectAtIndex:section];

// 	if ([title isEqualToString:@"numeric"]) {
// 		return @"#";
// 	} else if ([title isEqualToString:@"specialChars"]) {
// 		return @""
// 	}

//     NSArray* sectionsWithApps = [self getSectionsWithApps];
//     return [sectionsWithApps objectAtIndex:section];
// }

/*-(id)initWithFrame:(CGRect)frame {
	self = [super initWithFrame:frame];

	appsInList = [RSApplicationDelegate listVisibleIcons];
	appSections = [[NSMutableDictionary alloc] init];

	[self addAppsAndSections];

	appSectionHeaders = [[NSMutableArray alloc] init];
	appSectionListItems = [[NSMutableArray alloc] init];

	if ([[appSections objectForKey:@"numeric"] count] > 0) {
		RSAppListSection* sectionHeaderForNumeric = [[RSAppListSection alloc] initWithFrame:CGRectMake(0, ([appSectionHeaders count]*60)+([appSectionListItems count]*54), self.frame.size.width, 60) withSectionTitle:@"#"];
		[self addSubview:sectionHeaderForNumeric];
		[appSectionHeaders addObject:sectionHeaderForNumeric];

		for (NSString* iconIdentifier in [appSections objectForKey:@"numeric"]) {
			RSAppListItem* itemForAppList = [[RSAppListItem alloc] initWithFrame:CGRectMake(0, ([appSectionHeaders count]*60)+([appSectionListItems count]*54), self.frame.size.width, 54) withBundleIdentifier:iconIdentifier];
			[self addSubview:itemForAppList];
			[appSectionListItems addObject:itemForAppList];
		}
	}

	NSString* alphabet = @"ABCDEFGHIJKLMNOPQRSTUVWXYZ";
	for (int i=0; i<26; i++) {
		NSString* letter = [alphabet substringWithRange:NSMakeRange(i, 1)];
		
		if ([[appSections objectForKey:letter] count] > 0) {
			RSAppListSection* sectionHeaderForLetter = [[RSAppListSection alloc] initWithFrame:CGRectMake(0, ([appSectionHeaders count]*60)+([appSectionListItems count]*54), self.frame.size.width, 60) withSectionTitle:letter];
			[self addSubview:sectionHeaderForLetter];
			[appSectionHeaders addObject:sectionHeaderForLetter];

			for (NSString* iconIdentifier in [appSections objectForKey:letter]) {
				RSAppListItem* itemForAppList = [[RSAppListItem alloc] initWithFrame:CGRectMake(0, ([appSectionHeaders count]*60)+([appSectionListItems count]*54), self.frame.size.width, 54) withBundleIdentifier:iconIdentifier];
				[self addSubview:itemForAppList];
				[appSectionListItems addObject:itemForAppList];
			}
		}
	}

	[self setContentSize:CGSizeMake(self.frame.size.width, ([appSectionHeaders count]*60)+([appSectionListItems count]*54))];
	[self setContentInset:UIEdgeInsetsMake(0, 0, 80, 0)];

	return self;
}*/

-(void)addAppsAndSections {
	NSString* alphabet = @"ABCDEFGHIJKLMNOPQRSTUVWXYZ";
	NSString* numbers = @"1234567890";

	NSMutableArray* sectionsForNumbers = [[NSMutableArray alloc] init];
	NSMutableDictionary* sectionsForLetters = [[NSMutableDictionary alloc] init];
	NSMutableArray* sectionsForSpecialChars = [[NSMutableArray alloc] init];

	for (int i=0; i<26; i++) {
		NSString* letter = [alphabet substringWithRange:NSMakeRange(i, 1)];
		[sectionsForLetters setObject:[NSMutableArray array] forKey:letter];
	}

	for (NSString* iconIdentifier in appsInList) {
		SBApplication* currentApp = [[objc_getClass("SBApplicationController") sharedInstance] applicationWithBundleIdentifier:iconIdentifier];
		NSString* first = [[[currentApp displayName] substringToIndex:1] uppercaseString];

		if (first) {
			BOOL titleIsString = ([alphabet rangeOfString:first].location != NSNotFound);
			BOOL titleIsNumeric = ([numbers rangeOfString:first].location != NSNotFound);

			if (titleIsString) {
				[[sectionsForLetters objectForKey:first] addObject:iconIdentifier];
			} else if (titleIsNumeric) {
				[sectionsForNumbers addObject:iconIdentifier];
			} else {
				[sectionsForSpecialChars addObject:iconIdentifier];
			}
		}
	}
	/*[sectionsForLetters sortUsingComparator: ^(NSString* a, NSString* b) {
	    return [a caseInsensitiveCompare:b];
	}];*/

	if ([sectionsForNumbers count] > 0) {
		[appSections setObject:sectionsForNumbers forKey:@"numeric"];
		[sectionKeysWithApps addObject:@"numeric"];
	}
	for (int i=0; i<26; i++) {
		NSString* letter = [alphabet substringWithRange:NSMakeRange(i, 1)];
		if ([[sectionsForLetters objectForKey:letter] count] > 0) {
			[appSections setObject:[sectionsForLetters objectForKey:letter] forKey:letter];
			[sectionKeysWithApps addObject:letter];
		}
	}
	if ([sectionsForSpecialChars count] > 0) {
		[appSections setObject:sectionsForSpecialChars forKey:@"specialChars"];
		[sectionKeysWithApps addObject:@"specialChars"];
	}
}

@end