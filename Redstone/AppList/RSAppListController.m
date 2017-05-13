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
		
		self.appList = [[RSAppList alloc] initWithFrame:CGRectMake(screenWidth, 70, screenWidth, screenHeight - 70)];
		[self.appList setDelegate:self];
		
		self->sectionBackgroundContainer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, 60)];
		[self->sectionBackgroundContainer setClipsToBounds:YES];
		
		self->sectionBackgroundImage = [[UIImageView alloc] initWithImage:[RSAesthetics getCurrentWallpaper]];
		[self->sectionBackgroundImage setFrame:CGRectMake(0, -70, screenWidth, screenHeight)];
		[self->sectionBackgroundContainer addSubview:self->sectionBackgroundImage];
		
		self->sectionBackgroundOverlay = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, 60)];
		[self->sectionBackgroundOverlay setBackgroundColor:[UIColor colorWithWhite:0.0 alpha:0.75]];
		[self->sectionBackgroundContainer addSubview:self->sectionBackgroundOverlay];
		
		[self addAppsAndSections];
	}
	
	return self;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
	[self updateSectionsWithOffset:self.appList.contentOffset.y];
}

- (void)addAppsAndSections {
	self->sections = [NSMutableArray new];
	self->appsBySection = [NSMutableDictionary new];
	
	NSString* alphabet = @"#ABCDEFGHIJKLMNOPQRSTUVWXYZ@";
	NSString* numbers = @"1234567890";
	
	for (int i=0; i<28; i++) {
		[appsBySection setObject:[@[] mutableCopy] forKey:[alphabet substringWithRange:NSMakeRange(i, 1)]];
	}
	
	NSArray* visibleIcons = [[[objc_getClass("SBIconController") sharedInstance] model] visibleIconIdentifiers];
	for (int i=0; i<[visibleIcons count]; i++) {
		RSApp* app = [[RSApp alloc] initWithFrame:CGRectMake(0, 0, screenWidth, 54) leafIdentifier:[visibleIcons objectAtIndex:i]];
		[self.appList addSubview:app];
		
		if (![[app.icon displayName] isEqualToString:@""]) {
			NSString* first = [[[app.icon displayName] substringWithRange:NSMakeRange(0,1)] uppercaseString];
			
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
					[self->sections addObject:section];
				}
			}
		}
	}
	
	NSArray* sortedSections = [self->sections sortedArrayUsingComparator:^NSComparisonResult(RSAppListSection* section1, RSAppListSection* section2) {
		return [section1.displayName compare:section2.displayName];
	}];
	self->sections = [sortedSections mutableCopy];
	
	for (int i=0; i<28; i++) {
		NSArray* arrayToSort = [self->appsBySection objectForKey:[alphabet substringWithRange:NSMakeRange(i,1)]];
		
		if ([arrayToSort count] > 0) {
			arrayToSort = [arrayToSort sortedArrayUsingComparator:^NSComparisonResult(RSApp* app1, RSApp* app2) {
				return [[app1.icon displayName] caseInsensitiveCompare:[app2.icon displayName]];
			}];
			
			[self->appsBySection setObject:arrayToSort forKey:[alphabet substringWithRange:NSMakeRange(i,1)]];
		}
	}
	
	[self layoutContentsWithSections:YES];
}

- (RSAppListSection*)sectionWithLetter:(NSString*)letter {
	if (letter != nil) {
		for (RSAppListSection* section in self->sections) {
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
	
	[self sortAppsAndLayout:self->sections];
}

- (void)sortAppsAndLayout:(NSArray*)sections {
	NSString* alphabet = @"#ABCDEFGHIJKLMNOPQRSTUVWXYZ@";
	
	int yPos = 0;
	id previousSection = nil;
	for (int i=0; i<28; i++) {
		NSArray* currentSection = [self->appsBySection objectForKey:[alphabet substringWithRange:NSMakeRange(i,1)]];
		
		if ([currentSection count] > 0) {
			previousSection = [alphabet substringWithRange:NSMakeRange(i,1)];
			
			RSAppListSection* section = [self sectionWithLetter:previousSection];
			[section setFrame:CGRectMake(0, yPos, screenWidth, 60)];
			[section setYCoordinate:yPos];
			[section updateBackgroundPosition];
			
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
	
	[self.appList insertSubview:self->sectionBackgroundContainer belowSubview:[self->sections objectAtIndex:0]];
}

- (void)updateSectionsWithOffset:(float)offset {
	for (int i=0; i<[self->sections count]; i++) {
		RSAppListSection* section = [self->sections objectAtIndex:i];
		
		if (section.yCoordinate - offset < 0  && (i+1) < [self->sections count]) {
			if ([self->sections objectAtIndex:i+1] && (offset + 60) < [[self->sections objectAtIndex:i+1] yCoordinate]) {
				[section setFrame:CGRectMake(0,
											 offset,
											 self.appList.frame.size.width,
											 60)];
				[self->sectionBackgroundContainer setFrame:CGRectMake(0,
																	  offset,
																	  self.appList.frame.size.width,
																	  60)];
				[self->sectionBackgroundImage setFrame:CGRectMake(0, -70, screenWidth, screenHeight)];
			} else {
				[section setFrame:CGRectMake(0,
											 [[self->sections objectAtIndex:i+1] yCoordinate] - 60,
											 self.appList.frame.size.width,
											 60)];
				[self->sectionBackgroundContainer setFrame:CGRectMake(0,
																	  [[self->sections objectAtIndex:i+1] yCoordinate] - 60,
																	  self.appList.frame.size.width,
																	  60)];
				[self->sectionBackgroundImage setFrame:CGRectMake(0, (offset - [[self->sections objectAtIndex:i+1] yCoordinate] - 10), screenWidth, screenHeight)];
				
			}
		} else {
			[section setFrame:CGRectMake(0, [section yCoordinate], self.appList.frame.size.width, 60)];
		}
	}
	
	if (offset <= 0) {
		[self->sectionBackgroundContainer setHidden:YES];
	} else {
		[self->sectionBackgroundContainer setHidden:NO];
	}
}

- (void)prepareForAppLaunch:(RSApp *)sender {
	[[[RSCore sharedInstance] rootScrollView] setUserInteractionEnabled:NO];
	[[RSLaunchScreenController sharedInstance] setLaunchScreenForLeafIdentifier:[[sender.icon application] bundleIdentifier]];
	
	NSMutableArray* viewsInView = [NSMutableArray new];
	NSMutableArray* viewsNotInView = [NSMutableArray new];
	
	for (UIView* view in self.appList.subviews) {
		if (view != self->sectionBackgroundContainer) {
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
	
	dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(maxDelay + 0.6 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
		for (UIView* view in self.appList.subviews) {
			[view.layer setOpacity:0];
		}
		
		[[RSLaunchScreenController sharedInstance] show];
		
		dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.6 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
			for (UIView* view in self.appList.subviews) {
				[view setHidden:NO];
				[view.layer setOpacity:1];
				[view.layer removeAllAnimations];
			}
			
			[[objc_getClass("SBIconController") sharedInstance] _launchIcon:sender.icon];
			[[[RSCore sharedInstance] rootScrollView] setUserInteractionEnabled:YES];
		});
	});
}

- (void)updateSectionOverlayPosition {
	[self->sectionBackgroundImage setFrame:CGRectMake(-screenWidth + [[RSCore sharedInstance] rootScrollView].contentOffset.x,
													  self->sectionBackgroundImage.frame.origin.y,
													  screenWidth,
													  screenHeight)];
}


- (void)setSectionOverlayAlpha:(CGFloat)alpha {
	[self->sectionBackgroundOverlay setBackgroundColor:[UIColor colorWithWhite:0.0 alpha:alpha]];
}

@end
