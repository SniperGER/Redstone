#import "RSAppListController.h"
#import "RSAppList.h"
#import "Redstone.h"
#import "RSPinMenu.h"
#import "RSApp.h"
#import "RSJumpList.h"
#import "RSSearchBar.h"
#import "RSAppListSection.h"
#import "RSAesthetics.h"

@implementation RSAppListController

static RSAppListController* sharedInstance;

+(id)sharedInstance {
	return sharedInstance;
}

-(id)init {
	self = [super init];
	sharedInstance = self;
	
	if (self) {
		self->appList = [[RSAppList alloc] initWithFrame:CGRectMake([[UIScreen mainScreen] bounds].size.width, 70, [[UIScreen mainScreen] bounds].size.width, [[UIScreen mainScreen] bounds].size.height-70)];
		[self->appList setDelegate:self];
		[[Redstone sharedInstance].rootScrollView addSubview:appList];

		self->searchBar = [[RSSearchBar alloc] initWithFrame:CGRectMake([[UIScreen mainScreen] bounds].size.width+2, 24, [[UIScreen mainScreen] bounds].size.width-4, 40)];
		//[self->searchBar setDelegate:self];
		[self->searchBar addTarget:self action:@selector(searchBarTextChanged) forControlEvents:UIControlEventEditingChanged];
		[[Redstone sharedInstance].rootScrollView addSubview:self->searchBar];

		self->noResultsLabel = [[UILabel alloc] initWithFrame:CGRectMake(5,20,[[UIScreen mainScreen] bounds].size.width-10, 30)];
		[self->noResultsLabel setTextColor:[UIColor colorWithWhite:0.5 alpha:1.0]];
		self->noResultsLabel.font = [UIFont fontWithName:@"SegoeUI" size:17];
		[self->noResultsLabel setHidden:YES];
		[self->appList addSubview:self->noResultsLabel];

		self->jumpList = [[RSJumpList alloc] initWithFrame:CGRectMake([[UIScreen mainScreen] bounds].size.width, 0, [[UIScreen mainScreen] bounds].size.width, [[UIScreen mainScreen] bounds].size.height)];
		[[Redstone sharedInstance].rootScrollView addSubview:self->jumpList];
	}
	
	return self;
}

-(RSAppList*)appList {
	return self->appList;
}

-(void)showNoResultsLabel:(BOOL)visible forQuery:(NSString*)query {
	[self->noResultsLabel setHidden:!visible];

	if (query != nil && ![query isEqualToString:@""]) {
		NSString* baseString = [NSString stringWithFormat:[RSAesthetics localizedStringForKey:@"NO_RESULTS_FOUND"], query];
		NSRange range = [baseString rangeOfString:query];
		NSMutableAttributedString * string = [[NSMutableAttributedString alloc] initWithString:baseString];
		[string addAttribute:NSForegroundColorAttributeName value:[UIColor whiteColor] range:range];
		[self->noResultsLabel setAttributedText:string];
	}
}

-(void)showPinMenuForApp:(RSApp*)app {
	[self->searchBar resignFirstResponder];

	CGFloat pinMenuHeight = 54;
	if ([[app appIcon] isUninstallSupported]) {
		pinMenuHeight = 54*2;
	}
	if (app.frame.origin.y - self->appList.contentOffset.y > self->appList.frame.size.height*0.25) {
		self->pinMenu = [[RSPinMenu alloc] initWithFrame:CGRectMake([[UIScreen mainScreen] bounds].size.width/2-150,app.frame.origin.y-pinMenuHeight,300,pinMenuHeight) app:app];
		[self->pinMenu playOpeningAnimation:NO];
	} else {
		self->pinMenu = [[RSPinMenu alloc] initWithFrame:CGRectMake([[UIScreen mainScreen] bounds].size.width/2-150,app.frame.origin.y+54,300,pinMenuHeight) app:app];
		[self->pinMenu playOpeningAnimation:YES];
	}
	
	for (UIView* subview in [self->appList subviews]) {
		[subview setUserInteractionEnabled:NO];
	}
	[self->appList setScrollEnabled:NO];
	[[Redstone sharedInstance].rootScrollView setScrollEnabled:NO];

	[self->appList addSubview:self->pinMenu];
}

-(void)hidePinMenu {
	[self->pinMenu removeFromSuperview];
	
	for (UIView* subview in [self->appList subviews]) {
		[subview setUserInteractionEnabled:YES];
		
		if ([subview isKindOfClass:[RSApp class]]) {
			[(RSApp*)subview setHighlighted:NO];
		}
	}
	[self->appList setScrollEnabled:YES];
	[[Redstone sharedInstance].rootScrollView setScrollEnabled:YES];

	self->pinMenu = nil;
}

-(RSPinMenu*)pinMenu {
	return self->pinMenu;
}

-(void)showJumpList {
	[self->searchBar resignFirstResponder];
	[self->jumpList animateIn];
}

-(void)hideJumpList {
	[self->jumpList animateOut];
}

-(RSJumpList*)jumpList {
	return self->jumpList;
}

-(BOOL)isSearching {
	if (![self->searchBar.text isEqualToString:@""]) {
		return YES;
	}

	return self->isSearching;
}

-(void)setIsSearching:(BOOL)searching {
	 self->isSearching = searching;

	 if (!searching) {
		[self->searchBar resignFirstResponder];
		[self->searchBar setText:@""];
		[self->appList showAppsFittingQuery:nil];
		[self showNoResultsLabel:NO forQuery:nil];
	 }
}

-(void)prepareForAppLaunch:(id)sender {
	//[Redstone sharedInstance].rootScrollView setUserInteractionEnabled:NO];
	NSMutableArray* appsInView = [[NSMutableArray alloc] init];
	NSMutableArray* appsNotInView = [[NSMutableArray alloc] init];

	for (UIView* subview in [self->appList subviews]) {
		if (CGRectIntersectsRect(self->appList.bounds, subview.frame) && !subview.hidden) {
			[appsInView addObject:subview];
		} else {
			[appsNotInView addObject:subview];
		}
	}

	appsInView = [[appsInView sortedArrayUsingComparator: ^(UIView *obj1, UIView *obj2) {
		if ([obj1 frame].origin.y > [obj2 frame].origin.y) {
			return (NSComparisonResult)NSOrderedDescending;
		}
		else if ([obj1 frame].origin.y < [obj2 frame].origin.y) {
			return (NSComparisonResult)NSOrderedAscending;
		}
		else {
			return (NSComparisonResult)NSOrderedSame;
		}
	}] mutableCopy];

	CAAnimation *opacity = [CAKeyframeAnimation animationWithKeyPath:@"opacity"
															function:CubicEaseIn
														   fromValue:1.0
															 toValue:0.0];
	opacity.duration = 0.2;
	opacity.removedOnCompletion = NO;
	opacity.fillMode = kCAFillModeForwards;
	
	CAAnimation *scale = [CAKeyframeAnimation animationWithKeyPath:@"transform.scale"
														  function:CubicEaseIn
														 fromValue:1.0
														   toValue:4.0];
	scale.duration = 0.225;
	scale.removedOnCompletion = NO;
	scale.fillMode = kCAFillModeForwards;

	[self->searchBar.layer removeAllAnimations];
	[self->searchBar.layer addAnimation:opacity forKey:@"opacity"];

	for (UIView* view in appsInView) {
		[view.layer removeAllAnimations];
		[view.layer setTransform:CATransform3DIdentity];
		
		CGPoint basePoint = [view convertPoint:[view bounds].origin toView:self->appList];
		
		float layerX = -(basePoint.x-CGRectGetMidX(self->appList.bounds))/view.frame.size.width;
		float layerY = -(basePoint.y-CGRectGetMidY(self->appList.bounds))/view.frame.size.height;
		
		view.center = CGPointMake(CGRectGetMidX(self->appList.bounds), CGRectGetMidY(self->appList.bounds));
		view.layer.anchorPoint = CGPointMake(layerX, layerY);
		
		float delay = 0.01*(int)[appsInView indexOfObject:view];
		
		scale.beginTime = CACurrentMediaTime()+delay;
		opacity.beginTime = CACurrentMediaTime()+delay;
		
		if (view == sender) {
			scale.beginTime = CACurrentMediaTime()+delay+0.05;
			opacity.beginTime = CACurrentMediaTime()+delay+0.04;
		}
		[view.layer setShouldRasterize:YES];
		view.layer.rasterizationScale = [[UIScreen mainScreen] scale];
		view.layer.contentsScale = [[UIScreen mainScreen] scale];
		
		[view.layer addAnimation:scale forKey:@"scale"];
		[view.layer addAnimation:opacity forKey:@"opacity"];
	}

	float delayInSeconds = 0.01*(int)[appsInView count] + 0.3;

	dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
		[self->searchBar.layer setOpacity:0.0];
		for (UIView* view in appsInView) {
			[view.layer setOpacity:0];
		}
		[[Redstone sharedInstance].launchScreenController show];
		
		dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.6 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
			[[objc_getClass("SBIconController") sharedInstance] _launchIcon:[sender appIcon]];
			[self->appList sortAppsAndLayout:[self->appList sections]];
		});
	});
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

-(void)resetAppVisibility {
	[self->searchBar.layer removeAllAnimations];
	[self->searchBar.layer setOpacity:1.0];

	for (UIView* view in [self->appList subviews]) {
		[view setHidden:NO];
		[view.layer setOpacity:1];
		[view.layer removeAllAnimations];
	}
}

-(void)updateTileColors {
	for (UIView* view in [self->appList subviews]) {
		if ([view isKindOfClass:[RSApp class]]) {
			[(RSApp*)view updateTileColor];
		}
	}
}

-(void)updatePreferences {
	for (UIView* view in [self->appList subviews]) {
		if ([view isKindOfClass:[RSAppListSection class]]) {
			[(RSAppListSection*)view updatePreferences];
		}
	}

	[self updateTileColors];
}

//// DELEGATE METHODS

-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
	[self->searchBar resignFirstResponder];
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView {
	[self->appList updateSectionsWithOffset:self->appList.contentOffset.y];
}

/*-(void)textFieldDidBeginEditing:(UITextField *)textField {
	self->isSearching = YES;
}

-(void)textFieldDidEndEditing:(UITextField *)textField {
	self->isSearching = NO;
}*/

-(void)searchBarTextChanged {
	//NSLog(@"[Redstone] %@", [self->searchBar text]);
	[self->appList showAppsFittingQuery:[self->searchBar text]];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
	[self->searchBar resignFirstResponder];
	return YES;
}

@end