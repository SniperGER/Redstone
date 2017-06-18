#import "../Redstone.h"

@implementation RSAppListController

static RSAppListController* sharedInstance;

+ (id)sharedInstance {
	return sharedInstance;
}

- (id)init {
	self = [super init];
	
	if (self) {
		sharedInstance = self;
		
		self.searchBar = [[RSSearchBar alloc] initWithFrame:CGRectMake(screenWidth + 5, 24, screenWidth - 10, 40)];
		[[[RSCore sharedInstance] rootScrollView] addSubview:self.searchBar];
		
		self.appList = [[RSAppList alloc] initWithFrame:CGRectMake(screenWidth, 70, screenWidth, screenHeight - 70)];
		[self.appList setDelegate:self];
		
		sectionBackgroundContainer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, 60)];
		[sectionBackgroundContainer setClipsToBounds:YES];
		
		sectionBackgroundImage = [[UIImageView alloc] initWithImage:[RSAesthetics homeScreenWallpaper]];
		[sectionBackgroundImage setFrame:CGRectMake(0, -70, screenWidth, screenHeight)];
		[sectionBackgroundContainer addSubview:sectionBackgroundImage];
		
		sectionBackgroundOverlay = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, 60)];
		[sectionBackgroundOverlay setBackgroundColor:[UIColor colorWithWhite:0.0 alpha:0.75]];
		[sectionBackgroundContainer addSubview:sectionBackgroundOverlay];
		
		noResultsLabel = [[UILabel alloc] initWithFrame:CGRectMake(5, 10, self.appList.frame.size.width-10, 30)];
		[noResultsLabel setTextColor:[UIColor colorWithWhite:0.5 alpha:1.0]];
		[noResultsLabel setFont:[UIFont fontWithName:@"SegoeUI" size:17]];
		[noResultsLabel setHidden:YES];
		[self.appList addSubview:noResultsLabel];
		
		[self addAppsAndSections];
		
		pinMenu = [[RSPinMenu alloc] initWithFrame:CGRectMake(0, 0, 364, 94)];
		self.jumpList = [[RSJumpList alloc] initWithFrame:CGRectMake(screenWidth, 0, screenWidth, screenHeight)];
	}
	
	return self;
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
	[self.searchBar resignFirstResponder];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
	[self updateSectionsWithOffset:self.appList.contentOffset.y];
}

- (void)addAppsAndSections {
	if (sections && appsBySection) {
		[sections makeObjectsPerformSelector:@selector(removeFromSuperview)];
		for (id key in appsBySection) {
			[[appsBySection objectForKey:key] makeObjectsPerformSelector:@selector(removeFromSuperview)];
		}
	}
	
	sections = [NSMutableArray new];
	appsBySection = [NSMutableDictionary new];
	
	NSString* alphabet = @"#ABCDEFGHIJKLMNOPQRSTUVWXYZ@";
	NSString* numbers = @"1234567890";
	
	for (int i=0; i<28; i++) {
		[appsBySection setObject:[@[] mutableCopy] forKey:[alphabet substringWithRange:NSMakeRange(i, 1)]];
	}
	
	NSArray* visibleIcons = [[[[objc_getClass("SBIconController") sharedInstance] model] visibleIconIdentifiers] allObjects];
	
	for (int i=0; i<[visibleIcons count]; i++) {
		SBLeafIcon* icon = [[[objc_getClass("SBIconController") sharedInstance] model] leafIconForIdentifier:[visibleIcons objectAtIndex:i]];
		
		if (icon && [icon applicationBundleID] != nil && ![[icon applicationBundleID] isEqualToString:@""]) {
			RSApp* app = [[RSApp alloc] initWithFrame:CGRectMake(0, 0, screenWidth, 54) leafIdentifier:[visibleIcons objectAtIndex:i]];
			[self.appList addSubview:app];
			
			NSString* first;
			if (app.tileInfo.localizedDisplayName) {
				first = [[app.tileInfo.localizedDisplayName substringWithRange:NSMakeRange(0,1)] uppercaseString];
			} else if (app.tileInfo.displayName) {
				first = [[app.tileInfo.displayName substringWithRange:NSMakeRange(0,1)] uppercaseString];
			} else {
				first = [[[app.icon displayName] substringWithRange:NSMakeRange(0,1)] uppercaseString];
			}
			
			if (first != nil) {
				BOOL isString = [alphabet rangeOfString:first].location != NSNotFound;
				BOOL isNumeric = [numbers rangeOfString:first].location != NSNotFound;
				
				NSString* supposedSectionLetter = @"";
				
				if (isString) {
					[[appsBySection objectForKey:first] addObject:app];
					supposedSectionLetter = first;
				} else if (isNumeric) {
					[[appsBySection objectForKey:@"#"] addObject:app];
					supposedSectionLetter = @"#";
				} else {
					[[appsBySection objectForKey:@"@"] addObject:app];
					supposedSectionLetter = @"@";
				}
				
				if ([self sectionWithLetter:supposedSectionLetter] == nil) {
					RSAppListSection* section = [[RSAppListSection alloc] initWithFrame:CGRectMake(0, 0, screenWidth, 60) letter:supposedSectionLetter];
					[sections addObject:section];
				}
			}
		}
	}
	
	NSArray* sortedSections = [sections sortedArrayUsingComparator:^NSComparisonResult(RSAppListSection* section1, RSAppListSection* section2) {
		return [section1.displayName compare:section2.displayName];
	}];
	sections = [sortedSections mutableCopy];
	
	for (int i=0; i<28; i++) {
		NSArray* arrayToSort = [appsBySection objectForKey:[alphabet substringWithRange:NSMakeRange(i,1)]];
		
		if ([arrayToSort count] > 0) {
			arrayToSort = [arrayToSort sortedArrayUsingComparator:^NSComparisonResult(RSApp* app1, RSApp* app2) {
				return [[app1.icon displayName] caseInsensitiveCompare:[app2.icon displayName]];
			}];
			
			[appsBySection setObject:arrayToSort forKey:[alphabet substringWithRange:NSMakeRange(i,1)]];
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

- (void)layoutContentsWithSections:(BOOL)arg1 {
	NSMutableArray* _sections = [[NSMutableArray alloc] init];
	
	for (UIView* subview in self.appList.subviews) {
		if ([subview isKindOfClass:[RSApp class]]) {
			[_sections addObject:subview];
		} else if ([subview isKindOfClass:[RSAppListSection class]]) {
			if (arg1) {
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
			[section setYCoordinate:yPos];
			
			yPos += 60;
			[self.appList addSubview:section];
			
			for (RSApp* app in currentSection) {
				[app setFrame:CGRectMake(0, yPos, screenWidth, 56)];
				[app setHidden:NO];
				
				yPos += 56;
			}
		}
	}
	
	CGRect contentRect = CGRectZero;
	for (UIView *view in self.appList.subviews) {
		contentRect = CGRectUnion(contentRect, view.frame);
	}
	self.appList.contentSize = contentRect.size;
	
	[sectionBackgroundContainer setFrame:CGRectMake(0, 0, screenWidth, 60)];
	[self.appList insertSubview:sectionBackgroundContainer belowSubview:[_sections objectAtIndex:0]];
}

- (void)updateSectionsWithOffset:(float)offset {
	for (int i=0; i<[sections count]; i++) {
		RSAppListSection* section = [sections objectAtIndex:i];
		
		if (section.yCoordinate - offset < 0  && (i+1) < [sections count]) {
			if ([sections objectAtIndex:i+1] && (offset + 60) < [[sections objectAtIndex:i+1] yCoordinate]) {
				[section setFrame:CGRectMake(0,
											 offset,
											 self.appList.frame.size.width,
											 60)];
				[sectionBackgroundContainer setFrame:CGRectMake(0,
																	  offset,
																	  self.appList.frame.size.width,
																	  60)];
				[sectionBackgroundImage setFrame:CGRectMake(-screenWidth + [[RSCore sharedInstance] rootScrollView].contentOffset.x,
																  -70,
																  screenWidth,
																  screenHeight)];
			} else {
				[section setFrame:CGRectMake(0,
											 [[sections objectAtIndex:i+1] yCoordinate] - 60,
											 self.appList.frame.size.width,
											 60)];
				[sectionBackgroundContainer setFrame:CGRectMake(0,
																	  [[sections objectAtIndex:i+1] yCoordinate] - 60,
																	  self.appList.frame.size.width,
																	  60)];
				[sectionBackgroundImage setFrame:CGRectMake(-screenWidth + [[RSCore sharedInstance] rootScrollView].contentOffset.x,
																  (offset - [[sections objectAtIndex:i+1] yCoordinate] - 10),
																  screenWidth,
																  screenHeight)];
				
			}
		} else {
			[section setFrame:CGRectMake(0, [section yCoordinate], self.appList.frame.size.width, 60)];
		}
	}
	
	if (offset <= 0) {
		[sectionBackgroundContainer setHidden:YES];
	} else {
		[sectionBackgroundContainer setHidden:NO];
	}
}

- (void)prepareForAppLaunch:(RSApp *)sender {
	[[[RSCore sharedInstance] rootScrollView] setUserInteractionEnabled:NO];
	[[RSLaunchScreenController sharedInstance] setLaunchScreenForLeafIdentifier:[[sender.icon application] bundleIdentifier] tileInfo:sender.tileInfo];
	[self.searchBar resignFirstResponder];
	
	NSMutableArray* viewsInView = [NSMutableArray new];
	NSMutableArray* viewsNotInView = [NSMutableArray new];
	
	for (UIView* view in self.appList.subviews) {
		if (view != sectionBackgroundContainer && !view.hidden) {
			if ( CGRectIntersectsRect(self.appList.bounds, view.frame)) {
				[viewsInView addObject:view];
			} else {
				[viewsNotInView addObject:view];
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
		
		CGPoint basePoint = [view convertPoint:view.bounds.origin toView:self.appList];
		
		CGFloat layerX = -(basePoint.x - CGRectGetMidX(self.appList.bounds))/view.frame.size.width;
		CGFloat layerY = -(basePoint.y - CGRectGetMidY(self.appList.bounds))/view.frame.size.height;
		
		CGFloat delay = [viewsInView indexOfObject:view] * 0.01;
		
		[view setCenter:CGPointMake(CGRectGetMidX(self.appList.bounds),
									CGRectGetMidY(self.appList.bounds))];
		[view.layer setAnchorPoint:CGPointMake(layerX, layerY)];
		
		if (view == sender) {
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
		for (UIView* view in self.appList.subviews) {
			[view.layer setOpacity:0];
		}
		
		
		[[RSLaunchScreenController sharedInstance] show];
		
		dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.4 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
			for (UIView* view in self.appList.subviews) {
				[view setHidden:NO];
				[view.layer setOpacity:1];
				[view.layer removeAllAnimations];
			}
			[self.searchBar.layer removeAllAnimations];
			[self setIsSearching:NO];
			
			[[objc_getClass("SBIconController") sharedInstance] _launchIcon:sender.icon];
			[[[RSCore sharedInstance] rootScrollView] setUserInteractionEnabled:YES];
		});
	});
}

- (void)returnToHomescreen {
	[[[RSCore sharedInstance] rootScrollView] setUserInteractionEnabled:NO];
	
	NSMutableArray* viewsInView = [NSMutableArray new];
	NSMutableArray* viewsNotInView = [NSMutableArray new];
	
	for (UIView* view in self.appList.subviews) {
		if (view != sectionBackgroundContainer && !view.hidden) {
			[view.layer removeAllAnimations];
			if ( CGRectIntersectsRect(self.appList.bounds, view.frame)) {
				[viewsInView addObject:view];
				
				[view.layer setOpacity:0];
				[view setHidden:NO];
			} else {
				[viewsNotInView addObject:view];
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
		
		CGPoint basePoint = [view convertPoint:view.bounds.origin toView:self.appList];
		
		CGFloat layerX = -(basePoint.x - CGRectGetMidX(self.appList.bounds))/view.frame.size.width;
		CGFloat layerY = -(basePoint.y - CGRectGetMidY(self.appList.bounds))/view.frame.size.height;
		
		CGFloat delay = [viewsInView indexOfObject:view] * 0.01;
		
		[view setCenter:CGPointMake(CGRectGetMidX(self.appList.bounds),
									CGRectGetMidY(self.appList.bounds))];
		[view.layer setAnchorPoint:CGPointMake(layerX, layerY)];
		
		[scale setBeginTime:CACurrentMediaTime() + delay];
		[opacity setBeginTime:CACurrentMediaTime() + delay];
		
		[view.layer addAnimation:scale forKey:@"scale"];
		[view.layer addAnimation:opacity forKey:@"opacity"];
	}
	
	dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(maxDelay + 0.4 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
		for (UIView* subview in self.appList.subviews) {
			[subview.layer removeAllAnimations];
			[subview.layer setOpacity:1];
			[subview setAlpha:1.0];
			[subview setHidden:NO];
			//[subview.layer setAnchorPoint:CGPointMake(0.5,0.5)];
			//[tile setCenter:[tile originalCenter]];
		}
		
		[[[RSCore sharedInstance] rootScrollView] setUserInteractionEnabled:YES];
	});
}

- (void)updateSectionOverlayPosition {
	[self updateSectionsWithOffset:self.appList.contentOffset.y];
}


- (void)setSectionOverlayAlpha:(CGFloat)alpha {
	[sectionBackgroundOverlay setBackgroundColor:[UIColor colorWithWhite:0.0 alpha:alpha]];
}

- (void)showPinMenuForApp:(RSApp *)app {
	AudioServicesPlaySystemSound(1520);
	self.showsPinMenu = YES;
	[pinMenu setHandlingApp:app];
	
	CGRect globalFrame = [self.appList convertRect:app.frame toView:[[RSCore sharedInstance] rootScrollView]];
	BOOL isBelowHalfScreen = (globalFrame.origin.y + (globalFrame.size.height/2) > screenHeight/2);
	CGFloat frameHeight = [app.icon isUninstallSupported] ? 160.0 : 94.0;
	
	CGRect pinMenuFrame = CGRectMake(
									 screenWidth + (screenWidth/2 - MIN(screenWidth, 364)/2),
									 (isBelowHalfScreen) ? globalFrame.origin.y - frameHeight : globalFrame.origin.y + globalFrame.size.height,
									 MIN(screenWidth, 364),
									 frameHeight);
	[pinMenu setFrame:pinMenuFrame];
	
	for (UIView* view in self.appList.subviews) {
		[view setUserInteractionEnabled:NO];
	}
	
	[self.appList setScrollEnabled:NO];
	[[[RSCore sharedInstance] rootScrollView] setScrollEnabled:NO];
	[[[RSCore sharedInstance] rootScrollView] addSubview:pinMenu];
	
	CAAnimation *opacity = [CAKeyframeAnimation animationWithKeyPath:@"opacity"
															function:ExponentialEaseOut
														   fromValue:0.0
															 toValue:1.0];
	opacity.duration = 0.2;
	opacity.removedOnCompletion = NO;
	opacity.fillMode = kCAFillModeForwards;
	
	CAAnimation *scale;
	if (isBelowHalfScreen) {
		scale = [CAKeyframeAnimation animationWithKeyPath:@"transform.translation.y"
												 function:ExponentialEaseOut
												fromValue:50
												  toValue:0.0];
	} else {
		
		scale = [CAKeyframeAnimation animationWithKeyPath:@"transform.translation.y"
												 function:ExponentialEaseOut
												fromValue:-50
												  toValue:0.0];
	}
	
	scale.duration = 0.225;
	scale.removedOnCompletion = NO;
	scale.fillMode = kCAFillModeForwards;
	
	[pinMenu.layer addAnimation:opacity forKey:@"opacity"];
	[pinMenu.layer addAnimation:scale forKey:@"scale"];
	
	[self.appList.tapGestureRecognizer setEnabled:YES];
}

- (void)hidePinMenu {
	if (!self.showsPinMenu) {
		return;
	}
	
	[pinMenu.layer removeAllAnimations];
	[pinMenu setHandlingApp:nil];
	
	for (UIView* view in self.appList.subviews) {
		[view setUserInteractionEnabled:YES];
	}
	
	[self.appList setScrollEnabled:YES];
	[self.appList.tapGestureRecognizer setEnabled:NO];
	[[[RSCore sharedInstance] rootScrollView] setScrollEnabled:YES];
	
	self.showsPinMenu = NO;
	[pinMenu removeFromSuperview];
}

- (void)setIsSearching:(BOOL)isSearching {
	_isSearching = isSearching;
	
	if (!isSearching) {
		[self.searchBar resignFirstResponder];
		[self.searchBar setText:@""];
		[self showAppsFittingQuery:nil];
	}
}

- (void)showAppsFittingQuery:(NSString*)query {
	NSMutableArray* newSubviews = [NSMutableArray new];
	
	for (UIView* view in self.appList.subviews) {
		if (query != nil && ![query isEqualToString:@""] && [query length] > 0) {
			if ([view isKindOfClass:[RSApp class]]) {
				NSArray* displayName = [[[[(RSApp*)view icon] displayName] lowercaseString] componentsSeparatedByString:@" "];
				
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
		for (UIView* view in self.appList.subviews) {
			[view setHidden:YES];
		}
		
		newSubviews = [[newSubviews sortedArrayUsingComparator:^NSComparisonResult(RSApp* app1, RSApp* app2) {
			return [[[app1 icon] displayName] caseInsensitiveCompare:[[app2 icon] displayName]];
		}] mutableCopy];
		
		for (int i=0; i<[newSubviews count]; i++) {
			RSApp* app = [newSubviews objectAtIndex:i];
			[app setHidden:NO];
			
			CGRect frame = app.frame;
			frame.origin.y = i * frame.size.height;
			[app setFrame:frame];
		}
		
		CGRect contentRect = CGRectZero;
		for (UIView *view in self.appList.subviews) {
			if (!view.hidden) {
				contentRect = CGRectUnion(contentRect, view.frame);
			}
		}
		
		self.appList.contentSize = contentRect.size;
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
		[string addAttribute:NSForegroundColorAttributeName value:[UIColor whiteColor] range:range];
		[noResultsLabel setAttributedText:string];
	}
}

- (void)jumpToSectionWithLetter:(NSString*)letter {
	if ([self sectionWithLetter:letter]) {
		for (RSAppListSection* section in sections) {
			if ([section.displayName isEqualToString:letter]) {
				int sectionOffset = section.yCoordinate;
				int maxOffsetByScreen = self.appList.contentSize.height - self.appList.bounds.size.height + 80;
				
				[self.appList setContentOffset:CGPointMake(0, MIN(sectionOffset, maxOffsetByScreen))];
			}
		}
	}
}

- (void)showJumpList {
	[self.searchBar resignFirstResponder];
	[self.jumpList animateIn];
}
- (void)hideJumpList {
	[self.jumpList animateOut];
}

- (void)uninstallApplication:(RSApp*)app {
	if ([[app.icon application] isUninstallSupported]) {
		[app.icon setUninstalled];
		[app.icon completeUninstall];
		[[objc_getClass("SBApplicationController") sharedInstance] uninstallApplication:[app.icon application]];
		[[[objc_getClass("SBIconController") sharedInstance] model] removeIconForIdentifier:[[app.icon application] bundleIdentifier]];
		
		if ([[[RSStartScreenController sharedInstance] pinnedLeafIdentifiers] containsObject:[[app.icon application] bundleIdentifier]]) {
			RSTile* tileToUnpin = [[[RSStartScreenController sharedInstance] pinnedTiles] objectAtIndex:[[[RSStartScreenController sharedInstance] pinnedLeafIdentifiers] indexOfObject:[[app.icon application] bundleIdentifier]]];
			[[RSStartScreenController sharedInstance] unpinTile:tileToUnpin];
		}
		
		[UIView animateWithDuration:.2 animations:^{
			[app setEasingFunction:easeOutQuint forKeyPath:@"frame"];
			
			[app setTransform:CGAffineTransformMakeScale(0.5, 0.5)];
			[app.layer setOpacity:0.0];
		} completion:^(BOOL finished) {
			[app removeEasingFunctionForKeyPath:@"frame"];
			[app removeFromSuperview];
			
			[self addAppsAndSections];
		}];
	}
}

@end
