#import "RSJumpListView.h"
#import "RSRootScrollView.h"

@implementation RSJumpListView

-(id)initWithFrame:(CGRect)frame {
	self = [super initWithFrame:frame];

	[self setBackgroundColor:[UIColor colorWithWhite:0.0 alpha:0.8]];

	float deviceOffsetWidth = ([[UIScreen mainScreen] bounds].size.width-320)/2;
    self.contentInset = UIEdgeInsetsMake(88, deviceOffsetWidth, 88, deviceOffsetWidth);

    [self setShowsHorizontalScrollIndicator:NO];
    [self setDelaysContentTouches:NO];

	appsInList = [RSApplicationDelegate listVisibleIcons];
	appSections = [[NSMutableDictionary alloc] init];
	sectionKeysWithApps = [[NSMutableArray alloc] init];
	[self addAppsAndSections];

	int sectionTag = 0;

	for (int i=0; i<7; i++) {
		for (int j=0; j<4; j++) {
			int index = ((i*4)+(j+1))-1;

			NSString* letter = [sectionKeysWithApps objectAtIndex:index];

			RSTiltView* jumpListLetter = [[RSTiltView alloc] initWithFrame:CGRectMake(j*80, i*80, 80, 80)];
			jumpListLetter.hasHighlight = YES;
			[jumpListLetter setTransformOptions:@{
				@"transformAngle": @10
			}];
			[jumpListLetter setActionForTapped:@selector(hide:) forTarget:self];

			UILabel* jumpListLetterLabel = [[UILabel alloc] initWithFrame:CGRectMake(0,0,80,80)];
			jumpListLetterLabel.textColor = [UIColor whiteColor];
			jumpListLetterLabel.textAlignment = NSTextAlignmentCenter;
			jumpListLetterLabel.font = [UIFont fontWithName:@"SegoeUI-Light" size:48];

			if (![appSections objectForKey:letter]) {
				jumpListLetter.userInteractionEnabled = NO;
				jumpListLetterLabel.textColor = [UIColor colorWithWhite:0.3 alpha:1];
			} else {
				jumpListLetter.tag = sectionTag;
				sectionTag++;
			}

			if ([letter isEqualToString:@"numeric"]) {
				letter = @"#";
			} else if ([letter isEqualToString:@"specialChars"]) {
				letter = @"\uE12B";
				jumpListLetterLabel.font = [UIFont fontWithName:@"SegoeMDL2Assets" size:30];
			}
			jumpListLetterLabel.text = letter;
			[jumpListLetter addSubview:jumpListLetterLabel];

			[self addSubview:jumpListLetter];

			[self setHidden:YES];
		}
	}

	isOpen = NO;

	return self;
}

/*-(void)moveAppListToSection:(UITapGestureRecognizer*)sender {
    [self hide];
    [self.parentAppListView.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:sender.view.tag] atScrollPosition:UITableViewScrollPositionTop animated:NO];
}*/

-(void)show {
	[self setHidden:NO];
	[self.rootScrollView setScrollEnabled:NO];
    CAAnimation *opacity = [CAKeyframeAnimation animationWithKeyPath:@"opacity"
                                                            function:CubicEaseOut
                                                           fromValue:0.0
                                                             toValue:1.0];
    opacity.duration = 0.25;
    opacity.removedOnCompletion = NO;
    opacity.fillMode = kCAFillModeForwards;
    
    CAAnimation *scale = [CAKeyframeAnimation animationWithKeyPath:@"transform.scale"
                                                          function:CubicEaseOut
                                                         fromValue:1.2
                                                           toValue:1.0];
    scale.duration = 0.4;
    scale.removedOnCompletion = NO;
    scale.fillMode = kCAFillModeForwards;
    
    [self.layer addAnimation:opacity forKey:@"opacity"];
    [self.layer addAnimation:scale forKey:@"scale"];

    isOpen = YES;
}

-(void)hide:(UIView*)sender {
	[self.rootScrollView setScrollEnabled:YES];
	if (sender) {
		RSAppListScrollView* appList = self.rootScrollView->appListScrollView;
		[appList.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:sender.tag] atScrollPosition:UITableViewScrollPositionTop animated:NO];
	}

	[self.layer removeAllAnimations];
    CAAnimation *opacity = [CAKeyframeAnimation animationWithKeyPath:@"opacity"
                                                            function:CubicEaseOut
                                                           fromValue:1.0
                                                             toValue:0.0];
    opacity.duration = 0.25;
    opacity.removedOnCompletion = NO;
    opacity.fillMode = kCAFillModeForwards;
    
    CAAnimation *scale = [CAKeyframeAnimation animationWithKeyPath:@"transform.scale"
                                                          function:CubicEaseOut
                                                         fromValue:1.0
                                                           toValue:1.2];
    scale.duration = 0.2;
    scale.removedOnCompletion = NO;
    scale.fillMode = kCAFillModeForwards;
    
    [self.layer addAnimation:opacity forKey:@"opacity"];
    [self.layer addAnimation:scale forKey:@"scale"];
    
    isOpen = NO;
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self setHidden:YES];
    });
}

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
		//[sectionKeysWithApps addObject:@"numeric"];
	}
	[sectionKeysWithApps addObject:@"numeric"];

	for (int i=0; i<26; i++) {
		NSString* letter = [alphabet substringWithRange:NSMakeRange(i, 1)];
		if ([[sectionsForLetters objectForKey:letter] count] > 0) {
			[appSections setObject:[sectionsForLetters objectForKey:letter] forKey:letter];
			//[sectionKeysWithApps addObject:letter];
		}
		[sectionKeysWithApps addObject:letter];
	}
	if ([sectionsForSpecialChars count] > 0) {
		[appSections setObject:sectionsForSpecialChars forKey:@"specialChars"];
		//[sectionKeysWithApps addObject:@"specialChars"];
	}
	[sectionKeysWithApps addObject:@"specialChars"];
}

- (BOOL)touchesShouldCancelInContentView:(UIView *)view {
    if ([view isKindOfClass:RSTiltView.class]) {
        return YES;
    }

    return [super touchesShouldCancelInContentView:view];
}

@end