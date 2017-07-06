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
	[(UIScrollView*)self.view setDelegate:self];
	
	sectionBackgroundContainer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, 60)];
	[sectionBackgroundContainer setClipsToBounds:YES];
	
	sectionBackgroundImage = [[UIImageView alloc] initWithImage:[RSAesthetics homeScreenWallpaper]];
	[sectionBackgroundImage setFrame:CGRectMake(0, -70, screenWidth, screenHeight)];
	[sectionBackgroundImage setTransform:CGAffineTransformMakeScale(1.5, 1.5)];
	[sectionBackgroundContainer addSubview:sectionBackgroundImage];
	
	sectionBackgroundOverlay = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, 60)];
	[sectionBackgroundOverlay setBackgroundColor:[UIColor colorWithWhite:0.0 alpha:0.75]];
	[sectionBackgroundContainer addSubview:sectionBackgroundOverlay];
}
	
- (void)viewDidLoad {
	[super viewDidLoad];
	
	[self loadApps];
}
	
#pragma mark Delegate
	
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
	
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
	[sectionBackgroundOverlay setBackgroundColor:[UIColor colorWithWhite:0.0 alpha:alpha]];
}

- (void)updateSectionOverlayPosition {
	[self updateSectionsWithOffset:[(UIScrollView*)self.view contentOffset].y];
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
		[appsBySection setObject:[@[] mutableCopy] forKey:[alphabet substringWithRange:NSMakeRange(i, 1)]];
	}
	
	NSArray* visibleApps = [[[(SBIconController*)[objc_getClass("SBIconController") sharedInstance] model] visibleIconIdentifiers] allObjects];
	
	for (int i=0; i<[visibleApps count]; i++) {
		SBLeafIcon* icon = [[(SBIconController*)[objc_getClass("SBIconController") sharedInstance] model] leafIconForIdentifier:[visibleApps objectAtIndex:i]];
		
		if (icon && [icon applicationBundleID] != nil && ![[icon applicationBundleID] isEqualToString:@""]) {
			RSApp* application = [[RSApp alloc] initWithFrame:CGRectMake(0, i*50, screenWidth, 50) leafIdentifier:[visibleApps objectAtIndex:i]];
			
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
			[section setYPosition:yPos];
			
			yPos += 60;
			
			for (RSApp* app in currentSection) {
				[app setFrame:CGRectMake(0, yPos, screenWidth, 56)];
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
	
	[sectionBackgroundContainer setFrame:CGRectMake(0, 0, screenWidth, 60)];
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
	
	for (RSApp* view in self.view.subviews) {
		if (view != sectionBackgroundContainer && ![view isKindOfClass:[UIImageView class]] && !view.hidden) {
			[view setTiltEnabled:NO];
			[view.layer removeAllAnimations];
			[view setTransform:CGAffineTransformIdentity];
			
			if ( CGRectIntersectsRect(self.view.bounds, view.frame)) {
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
	
	float maxDelay = [viewsInView count] * 0.01;
	
	for (UIView* view in viewsInView) {
		[view.layer setShouldRasterize:YES];
		[view.layer setRasterizationScale:[[UIScreen mainScreen] scale]];
		[view.layer setContentsScale:[[UIScreen mainScreen] scale]];
		
		CGPoint basePoint = [view convertPoint:view.bounds.origin toView:self.view];
		
		CGFloat layerX = -(basePoint.x - CGRectGetMidX(self.view.bounds))/view.frame.size.width;
		CGFloat layerY = -(basePoint.y - CGRectGetMidY(self.view.bounds))/view.frame.size.height;
		
		CGFloat delay = [viewsInView indexOfObject:view] * 0.01;
		
		[view setCenter:CGPointMake(CGRectGetMidX(self.view.bounds),
									CGRectGetMidY(self.view.bounds))];
		[view.layer setAnchorPoint:CGPointMake(layerX, layerY)];
		
		[scale setBeginTime:CACurrentMediaTime() + delay];
		[opacity setBeginTime:CACurrentMediaTime() + delay];
		
		[view.layer addAnimation:scale forKey:@"scale"];
		[view.layer addAnimation:opacity forKey:@"opacity"];
	}
	
	dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(maxDelay + 0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
		[self.view setUserInteractionEnabled:YES];
		
		for (UIView* view in self.view.subviews) {
			[view setUserInteractionEnabled:YES];
			[view.layer removeAllAnimations];
			[view.layer setOpacity:1];
			[view setAlpha:1.0];
			[view setHidden:NO];
			
			if ([view isKindOfClass:[RSApp class]] || [view isKindOfClass:[RSAppListSection class]]) {
				[(RSApp*)view setTiltEnabled:YES];
			}
		}
	});
}
	
- (void)animateOut {
	RSApp* sender = [self appForLeafIdentifier:[[RSLaunchScreenController sharedInstance] launchIdentifier]];
	
	NSMutableArray* viewsInView = [NSMutableArray new];
	NSMutableArray* viewsNotInView = [NSMutableArray new];
	
	for (RSApp* view in self.view.subviews) {
		if (view != sectionBackgroundContainer && ![view isKindOfClass:[UIImageView class]] && !view.hidden) {
			[view setTiltEnabled:NO];
			[view.layer removeAllAnimations];
			[view setTransform:CGAffineTransformIdentity];
			
			if ( CGRectIntersectsRect(self.view.bounds, view.frame)) {
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
		
		CGPoint basePoint = [view convertPoint:view.bounds.origin toView:self.view];
		
		CGFloat layerX = -(basePoint.x - CGRectGetMidX(self.view.bounds))/view.frame.size.width;
		CGFloat layerY = -(basePoint.y - CGRectGetMidY(self.view.bounds))/view.frame.size.height;
		
		CGFloat delay = [viewsInView indexOfObject:view] * 0.01;
		
		[view setCenter:CGPointMake(CGRectGetMidX(self.view.bounds),
									CGRectGetMidY(self.view.bounds))];
		[view.layer setAnchorPoint:CGPointMake(layerX, layerY)];
		
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
		for (UIView* view in self.view.subviews) {
			[view.layer setOpacity:0];
			[view.layer removeAllAnimations];
		}
		
		dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
			for (UIView* view in self.view.subviews) {
				[view setHidden:NO];
				[view.layer setOpacity:1];
				[view.layer removeAllAnimations];
				
				if ([view isKindOfClass:[RSApp class]] || [view isKindOfClass:[RSAppListSection class]]) {
					[(RSApp*)view setTiltEnabled:YES];
				}
			}
		});
		
	});
}
	
	@end
