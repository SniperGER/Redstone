#import "../Redstone.h"

@implementation RSAppListController

static RSAppListController* sharedInstance;

+ (id)sharedInstance {
	return sharedInstance;
}

- (id)init {
	if (self = [super init]) {
		sharedInstance = self;
	}
	
	return self;
}

- (void)loadView {
	self.view = [[RSAppListScrollView alloc] initWithFrame:CGRectMake(screenWidth, 70, screenWidth, screenHeight - 70)];
	
}

- (void)viewDidLoad {
	[super viewDidLoad];
	
	[(UIScrollView*)self.view setDelegate:self];
	
	self.searchBar = [[RSTextField alloc] initWithFrame:CGRectMake(screenWidth + 5, 24, screenWidth - 10, 40)];
	[self.searchBar setPlaceholder:[RSAesthetics localizedStringForKey:@"SEARCH"]];
	[self.searchBar addTarget:self action:@selector(showAppsFittingQuery) forControlEvents:UIControlEventEditingChanged];
	[[[RSHomeScreenController sharedInstance] scrollView] addSubview:self.searchBar];
	
	noResultsLabel = [[UILabel alloc] initWithFrame:CGRectMake(5, 10, self.view.frame.size.width-10, 30)];
	[noResultsLabel setTextColor:[UIColor colorWithWhite:0.5 alpha:1.0]];
	[noResultsLabel setFont:[UIFont fontWithName:@"SegoeUI" size:17]];
	[noResultsLabel setHidden:YES];
	[self.view addSubview:noResultsLabel];
	
	sectionBackgroundContainer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, 60)];
	[sectionBackgroundContainer setClipsToBounds:YES];
	
	sectionBackgroundImage = [[UIImageView alloc] initWithImage:[RSAesthetics homeScreenWallpaper]];
	[sectionBackgroundImage setContentMode:UIViewContentModeScaleAspectFill];
	[sectionBackgroundImage setFrame:CGRectMake(0, -70, screenWidth, screenHeight)];
	[sectionBackgroundImage setTransform:CGAffineTransformMakeScale(1.5, 1.5)];
	[sectionBackgroundContainer addSubview:sectionBackgroundImage];
	
	sectionBackgroundOverlay = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, 60)];
	[sectionBackgroundOverlay setBackgroundColor:[[RSAesthetics colorsForCurrentTheme][@"InvertedForegroundColor"] colorWithAlphaComponent:0.75]];
	[sectionBackgroundContainer addSubview:sectionBackgroundOverlay];
	
	dismissRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hidePinMenu)];
	[dismissRecognizer setEnabled:NO];
	[self.view addGestureRecognizer:dismissRecognizer];
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(wallpaperChanged) name:@"RedstoneWallpaperChanged" object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(accentColorChanged) name:@"RedstoneAccentColorChanged" object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deviceFinishedLock) name:@"RedstoneDeviceHasFinishedLock" object:nil];
	
	[self loadApps];
	
	self.pinMenu = [RSFlyoutMenu new];
	[self.pinMenu addActionWithTitle:[RSAesthetics localizedStringForKey:@"PIN_TO_START"] target:self action:@selector(pinSelectedApp)];
	[self.pinMenu addActionWithTitle:[RSAesthetics localizedStringForKey:@"UNINSTALL"] target:self action:@selector(uninstallSelectedApp)];
	
	self.jumpList = [[RSJumpList alloc] initWithFrame:CGRectMake(screenWidth, 0, screenWidth, screenHeight)];
	
}

- (void)wallpaperChanged {
	[sectionBackgroundImage setImage:[RSAesthetics homeScreenWallpaper]];
}

- (void)accentColorChanged {
	for (RSApp* app in apps) {
		[app setBackgroundColor:[RSAesthetics accentColorForTile:app.tileInfo]];
	}
}

- (void)deviceFinishedLock {
	[self hidePinMenu];
	[self hideJumpList];
	
	self.isUninstallingApp = NO;
	[self dismissViewControllerAnimated:NO completion:nil];
	
	[self.searchBar resignFirstResponder];
	[self.searchBar setText:@""];
	[self showAppsFittingQuery];
}

#pragma mark Delegate

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
	[self.searchBar resignFirstResponder];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
	[self updateSectionsWithOffset:[(UIScrollView*)self.view contentOffset].y];
}

- (void)updateSectionsWithOffset:(CGFloat)offset {
	for (int i=0; i<[sections count]; i++) {
		RSAppListSection* section = [sections objectAtIndex:i];
		
		if (section.yPosition - offset < 0 && (i+1) < sections.count) {
			if ([sections objectAtIndex:i+1] && (offset + 60) < [[sections objectAtIndex:i+1] yPosition]) {
				[section setFrame:CGRectMake(0, offset, self.view.frame.size.width, 60)];
				[sectionBackgroundContainer setFrame:CGRectMake(0, offset, self.view.frame.size.width, 60)];
				[sectionBackgroundImage setCenter:CGPointMake(screenWidth/2 + (-screenWidth + [[RSHomeScreenController sharedInstance] contentOffset].x),
															  screenHeight/2 - 70 - [[RSHomeScreenController sharedInstance] parallaxPosition])];
			} else {
				[section setFrame:CGRectMake(0, [[sections objectAtIndex:i+1] yPosition] - 60, self.view.frame.size.width, 60)];
				[sectionBackgroundContainer setFrame:CGRectMake(0, [[sections objectAtIndex:i+1] yPosition] - 60, self.view.frame.size.width, 60)];
				[sectionBackgroundImage setCenter:CGPointMake(screenWidth/2  + (-screenWidth + [[RSHomeScreenController sharedInstance] contentOffset].x),
															  screenHeight/2 + (offset - [[sections objectAtIndex:i+1] yPosition] - 10)  - [[RSHomeScreenController sharedInstance] parallaxPosition])];
			}
		} else {
			[section setFrame:CGRectMake(0, [section yPosition], self.view.frame.size.width, 60)];
		}
	}
	
	if (offset <= 0) {
		[sectionBackgroundContainer setHidden:YES];
	} else {
		[sectionBackgroundContainer setHidden:NO];
	}
}

- (void)setSectionOverlayAlpha:(CGFloat)alpha {
	[sectionBackgroundOverlay setBackgroundColor:[[RSAesthetics colorsForCurrentTheme][@"InvertedForegroundColor"] colorWithAlphaComponent:alpha]];
}

- (void)updateSectionOverlayPosition {
	[self updateSectionsWithOffset:[(UIScrollView*)self.view contentOffset].y];
}

- (void)jumpToSectionWithLetter:(NSString*)letter {
	if ([self sectionWithLetter:letter]) {
		for (RSAppListSection* section in sections) {
			if ([section.displayName isEqualToString:letter]) {
				int sectionOffset = section.yPosition;
				int maxOffsetByScreen = [(UIScrollView*)[self view] contentSize].height - self.view.bounds.size.height + 80;
				
				[(UIScrollView*)self.view setContentOffset:CGPointMake(0, MIN(sectionOffset, maxOffsetByScreen))];
			}
		}
	}
}

#pragma mark App Management

- (void)loadApps {
	if (sections && appsBySection) {
		[sections makeObjectsPerformSelector:@selector(removeFromSuperview)];
		for (id key in appsBySection) {
			[[appsBySection objectForKey:key] makeObjectsPerformSelector:@selector(removeFromSuperview)];
		}
	}
	
	sections = [NSMutableArray new];
	apps = [NSMutableArray new];
	appsBySection = [NSMutableDictionary new];
	
	NSString* alphabet = @"#ABCDEFGHIJKLMNOPQRSTUVWXYZ@";
	NSString* numbers = @"1234567890";
	
	for (int i=0; i<28; i++) {
		[appsBySection setObject:[NSMutableArray new] forKey:[alphabet substringWithRange:NSMakeRange(i, 1)]];
	}
	
	NSArray* visibleApps = [[[(SBIconController*)[objc_getClass("SBIconController") sharedInstance] model] visibleIconIdentifiers] allObjects];
	
	for (int i=0; i<[visibleApps count]; i++) {
		SBLeafIcon* icon = [[(SBIconController*)[objc_getClass("SBIconController") sharedInstance] model] leafIconForIdentifier:[visibleApps objectAtIndex:i]];
		
		if (![icon isKindOfClass:NSClassFromString(@"SBDownloadingIcon")]) {
			if (icon && [icon applicationBundleID] != nil && ![[icon applicationBundleID] isEqualToString:@""]) {
				RSApp* application = [[RSApp alloc] initWithFrame:CGRectMake(0, 0, screenWidth, 50) leafIdentifier:[visibleApps objectAtIndex:i]];
				
				[self.view addSubview:application];
				[apps addObject:application];
				
				NSString* first;
				if (application.tileInfo.localizedDisplayName) {
					first = [[application.tileInfo.localizedDisplayName substringWithRange:NSMakeRange(0,1)] uppercaseString];
				} else if (application.tileInfo.displayName) {
					first = [[application.tileInfo.displayName substringWithRange:NSMakeRange(0,1)] uppercaseString];
				} else {
					first = [[[application.icon displayName] substringWithRange:NSMakeRange(0,1)] uppercaseString];
				}
				
				if (first != nil) {
					BOOL isString = [alphabet rangeOfString:first].location != NSNotFound;
					BOOL isNumeric = [numbers rangeOfString:first].location != NSNotFound;
					
					NSString* supposedSectionLetter = @"";
					
					if (isString) {
						[[appsBySection objectForKey:first] addObject:application];
						supposedSectionLetter = first;
					} else if (isNumeric) {
						[[appsBySection objectForKey:@"#"] addObject:application];
						supposedSectionLetter = @"#";
					} else {
						[[appsBySection objectForKey:@"@"] addObject:application];
						supposedSectionLetter = @"@";
					}
					
					if ([self sectionWithLetter:supposedSectionLetter] == nil) {
						RSAppListSection* section = [[RSAppListSection alloc] initWithFrame:CGRectMake(0, 0, screenWidth, 60) letter:supposedSectionLetter];
						[sections addObject:section];
					}
				}
			}
		}
	}
	
	for (int i=0; i<28; i++) {
		NSArray* arrayToSort = [appsBySection objectForKey:[alphabet substringWithRange:NSMakeRange(i,1)]];
		
		if ([arrayToSort count] > 0) {
			arrayToSort = [arrayToSort sortedArrayUsingComparator:^NSComparisonResult(RSApp* app1, RSApp* app2) {
				return [[app1.icon displayName] caseInsensitiveCompare:[app2.icon displayName]];
			}];
			
			[appsBySection setObject:[arrayToSort mutableCopy] forKey:[alphabet substringWithRange:NSMakeRange(i,1)]];
		}
	}
	
	[self layoutContentsWithSections:YES];
}

- (void)layoutContentsWithSections:(BOOL)addSections {
	NSMutableArray* _sections = [[NSMutableArray alloc] init];
	
	for (UIView* subview in self.view.subviews) {
		if ([subview isKindOfClass:[RSApp class]]) {
			[_sections addObject:subview];
		} else if ([subview isKindOfClass:[RSAppListSection class]]) {
			if (addSections) {
				[_sections addObject:subview];
				[subview setHidden:NO];
			} else {
				[subview setHidden:YES];
			}
		}
	}
	
	[self sortAppsAndLayout:sections];
}

- (void)sortAppsAndLayout:(NSArray*)_sections {
	NSString* alphabet = @"#ABCDEFGHIJKLMNOPQRSTUVWXYZ@";
	
	int yPos = 0;
	id previousSection = nil;
	for (int i=0; i<28; i++) {
		NSArray* currentSection = [appsBySection objectForKey:[alphabet substringWithRange:NSMakeRange(i,1)]];
		
		if ([currentSection count] > 0) {
			previousSection = [alphabet substringWithRange:NSMakeRange(i,1)];
			
			RSAppListSection* section = [self sectionWithLetter:previousSection];
			
			[section setFrame:CGRectMake(0, yPos, screenWidth, 60)];
			[section setOriginalCenter:section.center];
			[section setYPosition:yPos];
			
			yPos += 60;
			
			for (RSApp* app in currentSection) {
				[app setFrame:CGRectMake(0, yPos, screenWidth, 56)];
				[app setOriginalCenter:app.center];
				[app setHidden:NO];
				
				yPos += 56;
			}
		}
	}
	
	NSArray* sortedSections = [sections sortedArrayUsingComparator:^NSComparisonResult(RSAppListSection* app1, RSAppListSection* app2) {
		return [[NSNumber numberWithFloat:app1.yPosition] compare:[NSNumber numberWithFloat:app2.yPosition]];
	}];
	sections = [sortedSections mutableCopy];
	
	[self.view addSubview:sectionBackgroundContainer];
	for (int i=0; i<sections.count; i++) {
		[self.view addSubview:[sections objectAtIndex:i]];
	}
	
	CGRect contentRect = CGRectZero;
	for (UIView *view in self.view.subviews) {
		contentRect = CGRectUnion(contentRect, view.frame);
	}
	[(UIScrollView*)self.view setContentSize:contentRect.size];
	
	[self updateSectionOverlayPosition];
}

- (void)addAppForIcon:(SBLeafIcon*)icon {
	if ([self appForLeafIdentifier:[icon applicationBundleID]]) {
		return;
	}
	
	NSString* alphabet = @"#ABCDEFGHIJKLMNOPQRSTUVWXYZ@";
	NSString* numbers = @"1234567890";
	
	if (icon && [icon applicationBundleID] != nil && ![[icon applicationBundleID] isEqualToString:@""]) {
		if ([icon isKindOfClass:NSClassFromString(@"SBDownloadingIcon")]) {
			
			NSMutableString* actualLeafIdentifier = [[NSMutableString alloc] initWithString:[icon applicationBundleID]];
			[actualLeafIdentifier replaceOccurrencesOfString:@"com.apple.downloadingicon-" withString:@"" options:NSLiteralSearch range:NSMakeRange(0, [icon applicationBundleID].length)];
			
			RSDownloadingApp* downloadingApp = [[RSDownloadingApp alloc] initWithFrame:CGRectMake(0, 0, screenWidth, 50) leafIdentifier:actualLeafIdentifier];
			
			[downloadingApp setIcon:icon];
			[downloadingApp setDisplayName:[icon realDisplayName]];
			
			[self.view addSubview:downloadingApp];
			[apps addObject:downloadingApp];
			
			NSString* first = [[[downloadingApp displayName] substringWithRange:NSMakeRange(0, 1)] uppercaseString];
			
			if (first != nil) {
				BOOL isString = [alphabet rangeOfString:first].location != NSNotFound;
				BOOL isNumeric = [numbers rangeOfString:first].location != NSNotFound;
				
				NSString* supposedSectionLetter = @"";
				
				if (isString) {
					[[appsBySection objectForKey:first] addObject:downloadingApp];
					supposedSectionLetter = first;
				} else if (isNumeric) {
					[[appsBySection objectForKey:@"#"] addObject:downloadingApp];
					supposedSectionLetter = @"#";
				} else {
					[[appsBySection objectForKey:@"@"] addObject:downloadingApp];
					supposedSectionLetter = @"@";
				}
				
				if ([self sectionWithLetter:supposedSectionLetter] == nil) {
					RSAppListSection* section = [[RSAppListSection alloc] initWithFrame:CGRectMake(0, 0, screenWidth, 60) letter:supposedSectionLetter];
					[sections addObject:section];
				}
			}
		} else {
			[self loadApps];
		}
	}
	
	for (int i=0; i<28; i++) {
		NSArray* arrayToSort = [appsBySection objectForKey:[alphabet substringWithRange:NSMakeRange(i,1)]];
		
		if ([arrayToSort count] > 0) {
			arrayToSort = [arrayToSort sortedArrayUsingComparator:^NSComparisonResult(RSApp* app1, RSApp* app2) {
				return [[app1 displayName] caseInsensitiveCompare:[app2 displayName]];
			}];
			
			[appsBySection setObject:[arrayToSort mutableCopy] forKey:[alphabet substringWithRange:NSMakeRange(i,1)]];
		}
	}
	
	[self layoutContentsWithSections:YES];
}

- (RSAppListSection*)sectionWithLetter:(NSString*)letter {
	if (letter != nil) {
		for (RSAppListSection* section in sections) {
			if ([[section displayName] isEqualToString:letter]) {
				return section;
				break;
			}
		}
	}
	
	return nil;
}

- (RSApp*)appForLeafIdentifier:(NSString*)leafIdentifier {
	for (RSApp* app in apps) {
		if ([[app.icon applicationBundleID] isEqualToString:leafIdentifier]) {
			return app;
			break;
		}
	}
	
	return nil;
}

- (void)showPinMenuForApp:(RSApp*)app withPoint:(CGPoint)point {
	[self.view sendSubviewToBack:app];
	self.selectedApp = app;
	
	if ([[RSStartScreenController sharedInstance] tileForLeafIdentifier:[[self.selectedApp icon] applicationBundleID]]) {
		[self.pinMenu setActionDisabled:YES atIndex:0];
	} else {
		[self.pinMenu setActionDisabled:NO atIndex:0];
	}
	
	[self.pinMenu setActionHidden:![[self.selectedApp icon] isUninstallSupported] atIndex:1];
	
	[[RSHomeScreenController sharedInstance] setScrollEnabled:NO];
	[(UIScrollView*)self.view setScrollEnabled:NO];
	[dismissRecognizer setEnabled:YES];
	
	for (UIView* view in self.view.subviews) {
		[view setUserInteractionEnabled:NO];
	}
	
	CGRect globalFrame = [self.view convertRect:app.frame toView:[[RSHomeScreenController sharedInstance] window]];
	
	[self.pinMenu appearAtPosition:CGPointMake(point.x, globalFrame.origin.y)];
}

- (void)hidePinMenu {
	[self.pinMenu disappear];
	
	for (UIView* view in self.view.subviews) {
		[view setUserInteractionEnabled:YES];
	}
	
	[dismissRecognizer setEnabled:NO];
	[[RSHomeScreenController sharedInstance] setScrollEnabled:YES];
	[(UIScrollView*)self.view setScrollEnabled:YES];
}

- (void)pinSelectedApp {
	[self hidePinMenu];
	
	if ([[RSStartScreenController sharedInstance] tileForLeafIdentifier:[[self.selectedApp icon] applicationBundleID]]) {
		return;
	}
	
	[[RSHomeScreenController sharedInstance] setContentOffset:CGPointZero animated:YES];
	
	dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
		[[RSStartScreenController sharedInstance] pinTileWithIdentifier:[[self.selectedApp icon] applicationBundleID]];
		self.selectedApp = nil;
	});
}

- (void)uninstallSelectedApp {
	self.isUninstallingApp = YES;
	[self hidePinMenu];
	
	RSAlertController* alertController = [RSAlertController alertControllerWithTitle:[self.selectedApp.icon uninstallAlertTitle] message:[self.selectedApp.icon uninstallAlertBody]];
	[alertController show];
	
	RSAlertAction* uninstallAction = [RSAlertAction actionWithTitle:[self.selectedApp.icon uninstallAlertConfirmTitle] handler:^{
		if ([self.selectedApp.icon isUninstallSupported]) {
			[self.selectedApp.icon setUninstalled];
			[self.selectedApp.icon completeUninstall];
			
			[[(SBIconController*)[objc_getClass("SBIconController") sharedInstance] model] removeIconForIdentifier:[self.selectedApp.icon applicationBundleID]];
			
			[UIView animateWithDuration:0.2 animations:^{
				[self.selectedApp setEasingFunction:easeOutQuint forKeyPath:@"frame"];
				
				[self.selectedApp setTransform:CGAffineTransformMakeScale(0.9, 0.9)];
				[self.selectedApp.layer setOpacity:0.0];
			} completion:^(BOOL finished) {
				self.selectedApp = nil;
				self.isUninstallingApp = NO;
				
				[self loadApps];
			}];
		}
	}];
	
	RSAlertAction* cancelAction = [RSAlertAction actionWithTitle:[self.selectedApp.icon uninstallAlertCancelTitle] handler:^{
		self.selectedApp = nil;
		self.isUninstallingApp = NO;
	}];
	
	[alertController addAction:uninstallAction];
	[alertController addAction:cancelAction];
	
}

- (void)setDownloadProgressForIcon:(NSString*)leafIdentifier progress:(float)progress state:(int)state {
	if (![self appForLeafIdentifier:leafIdentifier]) {
		return;
	}
	
	if ([[self appForLeafIdentifier:leafIdentifier] isKindOfClass:[RSDownloadingApp class]]) {
		[(RSDownloadingApp*)[self appForLeafIdentifier:leafIdentifier] setDownloadProgress:progress forState:state];
	}
}

- (void)showAppsFittingQuery {
	NSString* query = [self.searchBar text];
	NSMutableArray* newSubviews = [NSMutableArray new];
	
	for (UIView* view in self.view.subviews) {
		if (query != nil && ![query isEqualToString:@""] && [query length] > 0) {
			if ([view isKindOfClass:[RSApp class]]) {
				NSArray* displayName = [[[(RSApp*)view displayName] lowercaseString] componentsSeparatedByString:@" "];
				
				for (int i=0; i<[displayName count]; i++) {
					if ([[displayName objectAtIndex:i] hasPrefix:[query lowercaseString]]) {
						[newSubviews addObject:view];
						break;
					} else {
						[view setHidden:YES];
					}
				}
			} else {
				[view setHidden:YES];
			}
		} else {
			[view setHidden:NO];
		}
	}
	
	if ([newSubviews count] > 0 && (query != nil || ![query isEqualToString:@""])) {
		for (UIView* view in self.view.subviews) {
			[view setHidden:YES];
		}
		
		newSubviews = [[newSubviews sortedArrayUsingComparator:^NSComparisonResult(RSApp* app1, RSApp* app2) {
			return [[app1 displayName] caseInsensitiveCompare:[app2 displayName]];
		}] mutableCopy];
		
		for (int i=0; i<[newSubviews count]; i++) {
			RSApp* app = [newSubviews objectAtIndex:i];
			[app setHidden:NO];
			
			CGRect frame = app.frame;
			frame.origin.y = i * frame.size.height;
			[app setFrame:frame];
		}
		
		CGRect contentRect = CGRectZero;
		for (UIView *view in self.view.subviews) {
			if (!view.hidden) {
				contentRect = CGRectUnion(contentRect, view.frame);
			}
		}
		
		[(UIScrollView*)self.view setContentSize:contentRect.size];
	} else if ([newSubviews count] == 0 && query != nil && ![query isEqualToString:@""]) {
		[self showNoResultsLabel:YES forQuery:query];
	} else {
		[self showNoResultsLabel:NO forQuery:nil];
		[self sortAppsAndLayout:sections];
	}
}

- (void)showNoResultsLabel:(BOOL)visible forQuery:(NSString*)query {
	[noResultsLabel setHidden:!visible];
	
	if (query != nil && ![query isEqualToString:@""]) {
		NSString* baseString = [NSString stringWithFormat:[RSAesthetics localizedStringForKey:@"NO_RESULTS_FOUND"], query];
		NSRange range = [baseString rangeOfString:query options:NSBackwardsSearch];
		NSMutableAttributedString * string = [[NSMutableAttributedString alloc] initWithString:baseString];
		[string addAttribute:NSForegroundColorAttributeName value:[RSAesthetics colorsForCurrentTheme][@"ForegroundColor"] range:range];
		[noResultsLabel setAttributedText:string];
	}
}

# pragma mark Animations

- (CGFloat)getMaxDelayForAnimation {
	NSMutableArray* viewsInView = [NSMutableArray new];
	
	for (UIView* view in self.view.subviews) {
		if (![view isKindOfClass:[UIImageView class]] && !view.hidden) {
			if ( CGRectIntersectsRect(self.view.bounds, view.frame)) {
				[viewsInView addObject:view];
			}
		}
	}
	
	return viewsInView.count * 0.01;
}

- (void)animateIn {
	NSMutableArray* viewsInView = [NSMutableArray new];
	NSMutableArray* viewsNotInView = [NSMutableArray new];
	
	for (RSApp* app in apps) {
		if (!app.hidden) {
			[app setTiltEnabled:NO];
			[app.layer removeAllAnimations];
			[app setTransform:CGAffineTransformIdentity];
			
			if (CGRectIntersectsRect(self.view.bounds, app.frame)) {
				[viewsInView addObject:app];
				
				[app.layer setOpacity:0];
				[app setHidden:NO];
			} else {
				[viewsNotInView addObject:app];
			}
		}
	}
	
	for (RSAppListSection* section in sections) {
		if (!section.hidden) {
			[section setTiltEnabled:NO];
			[section.layer removeAllAnimations];
			[section setTransform:CGAffineTransformIdentity];
			
			if (CGRectIntersectsRect(self.view.bounds, section.frame)) {
				[viewsInView addObject:section];
				
				[section.layer setOpacity:0];
				[section setHidden:NO];
			} else {
				[viewsNotInView addObject:section];
			}
		}
	}
	
	viewsInView = [[viewsInView sortedArrayUsingComparator:^NSComparisonResult(UIView* view1, UIView* view2) {
		return [[NSNumber numberWithFloat:view1.frame.origin.y] compare:[NSNumber numberWithFloat:view2.frame.origin.y]];
	}] mutableCopy];
	
	for (UIView* view in viewsNotInView) {
		[view setHidden:YES];
	}
	
	CAAnimation* scale = [CAKeyframeAnimation animationWithKeyPath:@"transform.scale"
														  function:CubicEaseOut
														 fromValue:0.8
														   toValue:1.0];
	[scale setDuration:0.4];
	[scale setRemovedOnCompletion:NO];
	[scale setFillMode:kCAFillModeForwards];
	
	CAAnimation* opacity = [CAKeyframeAnimation animationWithKeyPath:@"opacity"
															function:CubicEaseIn
														   fromValue:0.0
															 toValue:1.0];
	[opacity setDuration:0.3];
	[opacity setRemovedOnCompletion:NO];
	[opacity setFillMode:kCAFillModeForwards];
	
	[self.searchBar.layer addAnimation:opacity forKey:@"opacity"];
	
	float maxDelay = [viewsInView count] * 0.01;
	
	for (UIView* view in viewsInView) {
		[view.layer setShouldRasterize:YES];
		[view.layer setRasterizationScale:[[UIScreen mainScreen] scale]];
		[view.layer setContentsScale:[[UIScreen mainScreen] scale]];
		
		float width = view.bounds.size.width;
		float height = view.bounds.size.height;
		
		CGRect basePosition = CGRectMake(view.layer.position.x - (width/2),
										 view.layer.position.y - (height/2),
										 width,
										 height);
		
		CGFloat layerX = -(basePosition.origin.x - CGRectGetMidX(self.view.bounds))/basePosition.size.width;
		CGFloat layerY = -(basePosition.origin.y - CGRectGetMidY(self.view.bounds))/basePosition.size.height;
		
		[view setCenter:CGPointMake(CGRectGetMidX(self.view.bounds),
									CGRectGetMidY(self.view.bounds))];
		[view.layer setAnchorPoint:CGPointMake(layerX, layerY)];
		
		CGFloat delay = [viewsInView indexOfObject:view] * 0.01;
		
		[scale setBeginTime:CACurrentMediaTime() + delay];
		[opacity setBeginTime:CACurrentMediaTime() + delay];
		
		[view.layer addAnimation:scale forKey:@"scale"];
		[view.layer addAnimation:opacity forKey:@"opacity"];
	}
	
	dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(maxDelay + 0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
		[self.view setUserInteractionEnabled:YES];
		
		[self.searchBar.layer setOpacity:1];
		[self.searchBar.layer removeAllAnimations];
		
		for (RSApp* app in apps) {
			[app setUserInteractionEnabled:YES];
			[app.layer removeAllAnimations];
			[app.layer setOpacity:1];
			[app setAlpha:1.0];
			[app setHidden:NO];
			[app setTiltEnabled:YES];
			[app.layer setAnchorPoint:CGPointMake(0.5,0.5)];
			[app setCenter:app.originalCenter];
		}
			 
		for (RSAppListSection* section in sections) {
			[section setUserInteractionEnabled:YES];
			[section.layer removeAllAnimations];
			[section.layer setOpacity:1];
			[section setAlpha:1.0];
			[section setHidden:NO];
			[section setTiltEnabled:YES];
			[section.layer setAnchorPoint:CGPointMake(0.5,0.5)];
			[section setCenter:section.originalCenter];
		}
		
	});
}

- (void)animateOut {
	[self.searchBar resignFirstResponder];
	[self.view setUserInteractionEnabled:NO];
	RSApp* sender = [self appForLeafIdentifier:[[RSLaunchScreenController sharedInstance] launchIdentifier]];
	
	NSMutableArray* viewsInView = [NSMutableArray new];
	NSMutableArray* viewsNotInView = [NSMutableArray new];
	
	for (RSApp* app in apps) {
		[app setTiltEnabled:NO];
		[app.layer removeAllAnimations];
		[app setTransform:CGAffineTransformIdentity];
		
		if (CGRectIntersectsRect(self.view.bounds, app.frame)) {
			[viewsInView addObject:app];
		} else {
			[viewsNotInView addObject:app];
		}
	}
	
	for (RSApp* section in sections) {
		[section setTiltEnabled:NO];
		[section.layer removeAllAnimations];
		[section setTransform:CGAffineTransformIdentity];
		
		if (CGRectIntersectsRect(self.view.bounds, section.frame)) {
			[viewsInView addObject:section];
		} else {
			[viewsNotInView addObject:section];
		}
	}
	
	viewsInView = [[viewsInView sortedArrayUsingComparator:^NSComparisonResult(UIView* view1, UIView* view2) {
		return [[NSNumber numberWithFloat:view1.frame.origin.y] compare:[NSNumber numberWithFloat:view2.frame.origin.y]];
	}] mutableCopy];
	
	for (UIView* view in viewsNotInView) {
		[view setHidden:YES];
	}
	
	CAAnimation* scale = [CAKeyframeAnimation animationWithKeyPath:@"transform.scale"
														  function:CubicEaseIn
														 fromValue:1.0
														   toValue:4.0];
	[scale setDuration:0.225];
	[scale setRemovedOnCompletion:NO];
	[scale setFillMode:kCAFillModeForwards];
	
	CAAnimation* opacity = [CAKeyframeAnimation animationWithKeyPath:@"opacity"
															function:CubicEaseIn
														   fromValue:1.0
															 toValue:0.0];
	[opacity setDuration:0.2];
	[opacity setRemovedOnCompletion:NO];
	[opacity setFillMode:kCAFillModeForwards];
	
	[self.searchBar.layer addAnimation:opacity forKey:@"opacity"];
	
	float maxDelay = [viewsInView count] * 0.01;
	
	for (UIView* view in viewsInView) {
		[view.layer setShouldRasterize:YES];
		[view.layer setRasterizationScale:[[UIScreen mainScreen] scale]];
		[view.layer setContentsScale:[[UIScreen mainScreen] scale]];
		
		float width = view.bounds.size.width;
		float height = view.bounds.size.height;
		
		CGRect basePosition = CGRectMake(view.layer.position.x - (width/2),
										 view.layer.position.y - (height/2),
										 width,
										 height);
		
		CGFloat layerX = -(basePosition.origin.x - CGRectGetMidX(self.view.bounds))/basePosition.size.width;
		CGFloat layerY = -(basePosition.origin.y - CGRectGetMidY(self.view.bounds))/basePosition.size.height;
		
		[view setCenter:CGPointMake(CGRectGetMidX(self.view.bounds),
									CGRectGetMidY(self.view.bounds))];
		[view.layer setAnchorPoint:CGPointMake(layerX, layerY)];
		
		CGFloat delay = [viewsInView indexOfObject:view] * 0.01;
		
		if (view == sender) {
			[self.view sendSubviewToBack:view];
			[scale setBeginTime:CACurrentMediaTime() + delay + 0.1];
			[opacity setBeginTime:CACurrentMediaTime() + delay + 0.1];
		} else if ([view isKindOfClass:NSClassFromString(@"RSAppListSection")]) {
			[opacity setDuration:0.1];
		} else {
			[scale setBeginTime:CACurrentMediaTime() + delay];
			[opacity setBeginTime:CACurrentMediaTime() + delay];
		}
		
		[view.layer addAnimation:scale forKey:@"scale"];
		[view.layer addAnimation:opacity forKey:@"opacity"];
	}
	
	dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(maxDelay + 0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
		[self.searchBar.layer setOpacity:0];
		[self.searchBar.layer removeAllAnimations];
		
		for (UIView* view in self.view.subviews) {
			if (view != sectionBackgroundContainer) {
				[view.layer setOpacity:0];
				[view.layer removeAllAnimations];
				[view.layer setAnchorPoint:CGPointMake(0.5, 0.5)];
				
				if ([view isKindOfClass:[RSApp class]] || [view isKindOfClass:[RSAppListSection class]]) {
					[view setCenter:[(RSApp*)view originalCenter]];
				}
			}
		}
		
		dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
			[self.searchBar setText:@""];
			[self showAppsFittingQuery];
		});
		
		/*dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
			for (UIView* view in self.view.subviews) {
				[view setHidden:NO];
				[view.layer setOpacity:1];
				[view.layer removeAllAnimations];
			}
			
			for (RSApp* app in apps) {
				[app setTiltEnabled:YES];
			}
			for (RSAppListSection* section in sections) {
				[section setTiltEnabled:YES];
			}
			
			[self.searchBar setText:@""];
			[self showAppsFittingQuery];
		});*/
		
	});
}

#pragma mark Jump List

- (void)showJumpList {
	[self.searchBar resignFirstResponder];
	[self.jumpList animateIn];
}

- (void)hideJumpList {
	[self.jumpList animateOut];
	[[RSHomeScreenController sharedInstance] setScrollEnabled:YES];
}

@end
