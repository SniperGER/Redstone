#import "CommonHeaders.h"
#import "RSStartScreenController.h"
#import "RSStartScrollView.h"
#import "Redstone.h"
#import "RSMetrics.h"
#import "RSTile.h"

@implementation RSStartScreenController

static RSStartScreenController* sharedInstance;

-(id)init {
	self = [super init];
	sharedInstance = self;

	if (self) {
		[self setIsEditing:NO];
		[self setIsPinningTile:NO];

		CGRect rootScrollViewFrame = [[[Redstone sharedInstance] rootScrollView] frame];
		self->_startScrollView = [[RSStartScrollView alloc] initWithFrame:rootScrollViewFrame];

		[[[Redstone sharedInstance] rootScrollView] addSubview:self->_startScrollView];

		NSMutableDictionary* preferences = [NSMutableDictionary dictionaryWithContentsOfFile:@"/var/mobile/Library/Preferences/ml.festival.redstone.plist"];
		if (![preferences objectForKey:[NSString stringWithFormat:@"%iColumnLayout", [RSMetrics columns]]]) {
			[preferences setObject:[NSArray arrayWithContentsOfFile:[NSString stringWithFormat:@"/var/mobile/Library/FESTIVAL/Redstone.bundle/%iColumnDefaultLayout.plist", [RSMetrics columns]]] forKey:[NSString stringWithFormat:@"%iColumnLayout", [RSMetrics columns]]];
			[preferences writeToFile:@"/var/mobile/Library/Preferences/ml.festival.redstone.plist" atomically:YES];
		}

		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadTiles:) name:@"ml.festival.redstone.resetHomeLayout" object:nil];

		pinnedLeafIds = [[NSMutableArray alloc] init];
		[self loadTiles];
	}

	return self;
}

+(id)sharedInstance {
	return sharedInstance;
}

-(void)setIsPinningTile:(BOOL)arg1 {
	self->_isPinningTile = arg1;
}

-(double)distanceBetweenPointOne:(CGPoint)arg1 pointTwo:(CGPoint)arg2 {
	float deltaX = arg2.x - arg1.x;
	float deltaY = arg2.y - arg1.x;

	return sqrt(pow(deltaX,2) + pow(deltaY,2));
}

-(void)updatePreferences {
	for (RSTile* view in [self->_startScrollView subviews]) {
		[view updateTileColor];
	}
}

-(void)loadTiles:(NSNotification *)notification {
	[self loadTiles];
}

-(void)loadTiles {
	[[self->_startScrollView subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];

	NSDictionary* preferences = [NSDictionary dictionaryWithContentsOfFile:@"/var/mobile/Library/Preferences/ml.festival.redstone.plist"];
	NSArray* tilesToLoad = [preferences objectForKey:[NSString stringWithFormat:@"%iColumnLayout", [RSMetrics columns]]];

	//NSArray* tilesToLoad = [NSArray arrayWithContentsOfFile:[NSString stringWithFormat:@"/var/mobile/Library/FESTIVAL/Redstone.bundle/%iColumnDefaultLayout.plist", [RSMetrics columns]]];

	for (NSDictionary* tile in tilesToLoad) {
		int size = [[tile objectForKey:@"size"] intValue];
		int row = [[tile objectForKey:@"row"] intValue];
		int column = [[tile objectForKey:@"column"] intValue];
		NSString* bundleIdentifier = [tile objectForKey:@"bundleIdentifier"];

		if ([[[objc_getClass("SBIconController") sharedInstance] model] leafIconForIdentifier:bundleIdentifier] == nil) {
			return;
		}

		CGSize tilePositionSize = [RSMetrics tileDimensionsForSize:1];
		CGSize tileSize = [RSMetrics tileDimensionsForSize:size];
		RSTile* tileToAdd = [[RSTile alloc] initWithFrame:CGRectMake((tilePositionSize.width*column)+((column+1)*[RSMetrics tileBorderSpacing]), (tilePositionSize.width*row)+(row*[RSMetrics tileBorderSpacing]),tileSize.width, tileSize.height) leafId:bundleIdentifier size:size];
		tileToAdd.tileX = column;
		tileToAdd.tileY = row;

		[pinnedLeafIds addObject:bundleIdentifier];
		[self->_startScrollView addSubview:tileToAdd];
	}

	if ([pinnedLeafIds count] < 1) {
		[[[Redstone sharedInstance] rootScrollView] setScrollEnabled:NO];
		[[[Redstone sharedInstance] rootScrollView] setContentOffset:CGPointMake([[UIScreen mainScreen] bounds].size.width, 0)];
	}

	[self updateStartContentSize];
}

-(void)saveTiles {
	NSMutableArray* tilesToSave = [[NSMutableArray alloc] init];

	for (UIView* subview in [self->_startScrollView subviews]) {
		if ([subview isKindOfClass:[RSTile class]]) {
			NSMutableDictionary* tile = [[NSMutableDictionary alloc] init];

			[tile setValue:[NSNumber numberWithInteger:[(RSTile*)subview size]] forKey:@"size"];
			[tile setValue:[NSNumber numberWithInteger:[(RSTile*)subview tileY]] forKey:@"row"];
			[tile setValue:[NSNumber numberWithInteger:[(RSTile*)subview tileX]] forKey:@"column"];
			[tile setValue:[(RSTile*)subview leafId] forKey:@"bundleIdentifier"];

			[tilesToSave addObject:tile];
		}
	}

	NSMutableDictionary* defaults = [NSMutableDictionary dictionaryWithContentsOfFile:@"/var/mobile/Library/Preferences/ml.festival.redstone.plist"];
	[defaults setObject:tilesToSave forKey:[NSString stringWithFormat:@"%iColumnLayout", [RSMetrics columns]]];
	[defaults writeToFile:@"/var/mobile/Library/Preferences/ml.festival.redstone.plist" atomically:YES];
}

/*-(void)updateStartContentSize {
	CGRect contentRect = CGRectZero;
	for (UIView *view in self->_startScrollView.subviews) {
		contentRect = CGRectUnion(contentRect, view.frame);
	}
	contentRect.size.width = self->_startScrollView.frame.size.width-2;
	contentRect.size.height = MAX(contentRect.size.height, self->_startScrollView.frame.size.height-80);

	self->_startScrollView.contentSize = contentRect.size;
}*/

-(void)updateStartContentSize {
	UIView* lastTile = [[UIView alloc] initWithFrame:CGRectZero];
	CGSize baseSize = [RSMetrics tileDimensionsForSize:1];

	for (UIView* tile in [self->_startScrollView subviews]) {
		if (tile.frame.origin.y > lastTile.frame.origin.y || (tile.frame.origin.y == lastTile.frame.origin.y && tile.frame.size.height > lastTile.frame.size.height)) {
			lastTile = tile;
		}
	}

	//NSLog(@"[Redstone] %f %d", lastTile.frame.origin.y, [lastTile size]);
	CGSize tileSize = [RSMetrics tileDimensionsForSize:[(RSTile*)lastTile size]];

	CGSize contentSize = CGSizeZero;
	contentSize.width = self->_startScrollView.frame.size.width-2;
	contentSize.height = ([(RSTile*)lastTile tileY]*baseSize.height) + tileSize.height + ([(RSTile*)lastTile tileY]+1)*[RSMetrics tileBorderSpacing];

	self->_startScrollView.contentSize = contentSize;
}

-(void)pinTileWithId:(NSString*)leafId {
	if ([pinnedLeafIds indexOfObject:leafId] != NSNotFound) {
		return;
	}

	int maxTileX = 0, maxTileY = 0;
	CGSize baseSize = [RSMetrics tileDimensionsForSize:1];
	CGSize tileSize = [RSMetrics tileDimensionsForSize:2];

	for (RSTile* subview in [self->_startScrollView subviews]) {
		if (subview.tileY > maxTileY) {
			maxTileX = 0;
		}
		maxTileY = MAX(maxTileY, subview.tileY);
		maxTileX = MAX(maxTileX, subview.tileX);
	}

	BOOL tileHasBeenPinned = NO;

	for (int i=0; i<6; i++) {
		CGRect tileRect = CGRectMake(i*baseSize.width+((i+1)*[RSMetrics tileBorderSpacing]), maxTileY*baseSize.height+(maxTileY*[RSMetrics tileBorderSpacing]), tileSize.width, tileSize.height);

		if ([self viewIntersectsWithAnotherView:tileRect] == nil && (tileRect.origin.x+tileRect.size.width) < self->_startScrollView.frame.size.width) {
			RSTile* tileToAdd = [[RSTile alloc] initWithFrame:tileRect leafId:leafId size:2];
			tileToAdd.tileX = i;
			tileToAdd.tileY = maxTileY;

			[self->_startScrollView addSubview:tileToAdd];
			[pinnedLeafIds addObject:leafId];

			tileHasBeenPinned = YES;

			break;
		}
	}

	if (!tileHasBeenPinned) {
		for (int i=0; i<6; i++) {
			CGRect tileRectPlusOne = CGRectMake(i*baseSize.width+((i+1)*[RSMetrics tileBorderSpacing]), (maxTileY+1)*baseSize.height+((maxTileY+1)*[RSMetrics tileBorderSpacing]), tileSize.width, tileSize.height);

			if ([self viewIntersectsWithAnotherView:tileRectPlusOne] == nil && (tileRectPlusOne.origin.x+tileRectPlusOne.size.width) < self->_startScrollView.frame.size.width) {
				RSTile* tileToAdd = [[RSTile alloc] initWithFrame:tileRectPlusOne leafId:leafId size:2];
				tileToAdd.tileX = i;
				tileToAdd.tileY = maxTileY+1;

				[self->_startScrollView addSubview:tileToAdd];
				[pinnedLeafIds addObject:leafId];

				tileHasBeenPinned = YES;

				break;
			}
		}
	}

	if (!tileHasBeenPinned) {
		CGRect tileRectPlusTwo = CGRectMake([RSMetrics tileBorderSpacing], (maxTileY+2)*baseSize.height+((maxTileY+2)*[RSMetrics tileBorderSpacing]), tileSize.width, tileSize.height);

			RSTile* tileToAdd = [[RSTile alloc] initWithFrame:tileRectPlusTwo leafId:leafId size:2];
			tileToAdd.tileX = 0;
			tileToAdd.tileY = maxTileY+2;

			[self->_startScrollView addSubview:tileToAdd];
			[pinnedLeafIds addObject:leafId];
	}

	[self updateStartContentSize];

	[[[Redstone sharedInstance] rootScrollView] setScrollEnabled:YES];
	[[[Redstone sharedInstance] rootScrollView] setContentOffset:CGPointMake(0,0) animated:YES];
	[self->_startScrollView setContentOffset:CGPointMake(0, MAX(-24,(self->_startScrollView.contentSize.height - self->_startScrollView.bounds.size.height) + 60)) animated:YES];

	[self saveTiles];
}

-(void)unpinTile:(RSTile*)tile {
	[tile removeFromSuperview];
	if ([pinnedLeafIds containsObject:[tile leafId]]) {
    	[pinnedLeafIds removeObject:[tile leafId]];
	}

	if ([pinnedLeafIds count] < 1) {
		[self setIsEditing:NO];
		[[[Redstone sharedInstance] rootScrollView] setScrollEnabled:NO];
		[[[Redstone sharedInstance] rootScrollView] setContentOffset:CGPointMake([[UIScreen mainScreen] bounds].size.width, 0) animated:YES];
	}

	[self updateStartContentSize];

	[self saveTiles];
}

-(id)viewIntersectsWithAnotherView:(CGRect)rect{
	for (UIView *view in [self->_startScrollView subviews]) {
		if (CGRectIntersectsRect(view.frame, rect)) {
			return view;
		}
	}
	return nil;
}

-(void)returnToHomescreen {
	[[Redstone sharedInstance].rootScrollView setUserInteractionEnabled:NO];
	[self->_startScrollView setContentOffset:CGPointMake(0, -24)];

	NSMutableArray* appsInView = [[NSMutableArray alloc] init];
	NSMutableArray* appsNotInView = [[NSMutableArray alloc] init];

	for (RSTile* subview in [self->_startScrollView subviews]) {
		[subview updateTileColor];
		if (CGRectIntersectsRect(self->_startScrollView.bounds, subview.frame)) {
			[appsInView addObject:subview];
		} else {
			[appsNotInView addObject:subview];
		}
	}

	CAAnimation *opacity = [CAKeyframeAnimation animationWithKeyPath:@"opacity"
															function:CubicEaseOut
														   fromValue:0.0
															 toValue:1.0];
	opacity.duration = 0.3;
	opacity.removedOnCompletion = NO;
	opacity.fillMode = kCAFillModeForwards;
	
	CAAnimation *scale = [CAKeyframeAnimation animationWithKeyPath:@"transform.scale"
														  function:CubicEaseOut
														 fromValue:0.9
														   toValue:1.0];
	scale.duration = 0.4;
	scale.removedOnCompletion = NO;
	scale.fillMode = kCAFillModeForwards;

	for (UIView* view in appsNotInView) {
		[view setHidden:YES];
	}

	int minX = INT_MAX, minY = INT_MAX, maxX = INT_MIN, maxY = INT_MIN;

	for (UIView* view in appsInView) {
		if ([view isKindOfClass:[RSTile class]]) {
			minX = MIN([(RSTile*)view tileX], minX);
			maxX = MAX([(RSTile*)view tileX], maxX);
			minY = MIN([(RSTile*)view tileY], minY);
			maxY = MAX([(RSTile*)view tileY], maxY);
		}
	}

	float maxDelay = ((maxY-minY)*0.01)+(maxX*0.01);

	for (UIView* view in appsInView) {
		[view.layer setShouldRasterize:YES];
		view.layer.rasterizationScale = [[UIScreen mainScreen] scale];
		view.layer.contentsScale = [[UIScreen mainScreen] scale];
		
		if ([view isKindOfClass:[RSTile class]]) {
			[view.layer setOpacity:0];
			[view setHidden:NO];

			CGPoint basePoint = [view convertPoint:[view bounds].origin toView:self->_startScrollView];
			
			float layerX = -(basePoint.x-CGRectGetMidX(self->_startScrollView.bounds))/view.frame.size.width;
			float layerY = -(basePoint.y-CGRectGetMidY(self->_startScrollView.bounds))/view.frame.size.height;
			
			//float delay = (((int)[appsInView count]-1) - (int)[appsInView indexOfObject:view]) * 0.01;
			float delay = maxDelay - (([(RSTile*)view tileX]*0.01)+([(RSTile*)view tileY] - minY)*0.01);

			view.center = CGPointMake(CGRectGetMidX(self->_startScrollView.bounds), CGRectGetMidY(self->_startScrollView.bounds));
			view.layer.anchorPoint = CGPointMake(layerX, layerY);
			
			scale.beginTime = CACurrentMediaTime()+delay;
			opacity.beginTime = CACurrentMediaTime()+delay;
			
			[view.layer addAnimation:scale forKey:@"scale"];
			[view.layer addAnimation:opacity forKey:@"opacity"];
		}
	}

	dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(maxDelay + 0.6 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
		for (RSTile* view in [self->_startScrollView subviews]) {
			[view.layer setOpacity:1];
			[view setAlpha:1.0];
			[view setHidden:NO];
			view.layer.anchorPoint = CGPointMake(0.5,0.5);
			view.center = [view originalCenter];
		}

		[[Redstone sharedInstance].rootScrollView setUserInteractionEnabled:YES];
	});
}

-(void)prepareForAppLaunch:(id)sender {
	[[Redstone sharedInstance].rootScrollView setUserInteractionEnabled:NO];
	NSMutableArray* appsInView = [[NSMutableArray alloc] init];
	NSMutableArray* appsNotInView = [[NSMutableArray alloc] init];

	for (UIView* subview in [self->_startScrollView subviews]) {
		if (CGRectIntersectsRect(self->_startScrollView.bounds, subview.frame)) {
			[appsInView addObject:subview];
		} else {
			[appsNotInView addObject:subview];
		}
	}
	
	CAAnimation *opacity = [CAKeyframeAnimation animationWithKeyPath:@"opacity"
															function:CubicEaseIn
														   fromValue:1.0
															 toValue:0.0];
	opacity.duration = ANIM_ALPHA_DURATION;
	opacity.removedOnCompletion = NO;
	opacity.fillMode = kCAFillModeForwards;
	
	CAAnimation *scale = [CAKeyframeAnimation animationWithKeyPath:@"transform.scale"
														  function:CubicEaseIn
														 fromValue:1.0
														   toValue:4.0];
	scale.duration = ANIM_SCALE_DURATION;
	scale.removedOnCompletion = NO;
	scale.fillMode = kCAFillModeForwards;

	
	for (UIView* view in appsNotInView) {
		[view setHidden:YES];
	}

	int minX = INT_MAX, minY = INT_MAX, maxX = INT_MIN, maxY = INT_MIN;

	for (UIView* view in appsInView) {
		if ([view isKindOfClass:[RSTile class]]) {
			minX = MIN([(RSTile*)view tileX], minX);
			maxX = MAX([(RSTile*)view tileX], maxX);
			minY = MIN([(RSTile*)view tileY], minY);
			maxY = MAX([(RSTile*)view tileY], maxY);
		}
	}

	float maxDelay = ((maxY-minY)*ANIM_DELAY)+(maxX*ANIM_DELAY);

	for (UIView* view in appsInView) {
		[view.layer setShouldRasterize:YES];
		view.layer.rasterizationScale = [[UIScreen mainScreen] scale];
		view.layer.contentsScale = [[UIScreen mainScreen] scale];

		if ([view isKindOfClass:[RSTile class]]) {

			CGPoint basePoint = [view convertPoint:[view bounds].origin toView:self->_startScrollView];
			
			float layerX = -(basePoint.x-CGRectGetMidX(self->_startScrollView.bounds))/view.frame.size.width;
			float layerY = -(basePoint.y-CGRectGetMidY(self->_startScrollView.bounds))/view.frame.size.height;
			
			float delay = maxDelay - (([(RSTile*)view tileX]*ANIM_DELAY)+([(RSTile*)view tileY] - minY)*ANIM_DELAY);

			view.center = CGPointMake(CGRectGetMidX(self->_startScrollView.bounds), CGRectGetMidY(self->_startScrollView.bounds));
			view.layer.anchorPoint = CGPointMake(layerX, layerY);

			scale.beginTime = CACurrentMediaTime()+delay;
			opacity.beginTime = CACurrentMediaTime()+delay;
			
			if (view == sender) {
				scale.beginTime = CACurrentMediaTime()+delay+0.1;
				opacity.beginTime = CACurrentMediaTime()+delay+0.1;
			}
			
			[view.layer addAnimation:scale forKey:@"scale"];
			[view.layer addAnimation:opacity forKey:@"opacity"];
		}
	}

	dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(maxDelay + 0.6 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
		for (RSTile* view in appsInView) {
			[view.layer setOpacity:0];
		}
		[[Redstone sharedInstance].launchScreenController show];
		
		dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.6 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
			[[objc_getClass("SBIconController") sharedInstance] _launchIcon:[sender icon]];
		});
	});
}

-(void)resetTileVisibility {
	for (RSTile* view in [self->_startScrollView subviews]) {
		[view updateTileColor];
		[view setHidden:NO];
		[view.layer setOpacity:1];
		[view.layer removeAllAnimations];
	}
}

-(float)getTransitionDelayForItemAtIndex:(int)itemIndex forBaseItem:(int)baseItemIndex forItems:(NSArray*)items {
    int baseIndex = abs(baseItemIndex-itemIndex);
    
    
    int maxIndex = MAX((int)[items count]-(baseItemIndex+1), baseItemIndex);
    int calculatedIndex = maxIndex-baseIndex;
    
    float delay = calculatedIndex*0.02;
    return delay;
}

-(id)affectedTilesForAttemptingSnapForTile:(RSTile*)tile {
	// empty mutable array

	// for all tiles

}

-(RSStartScrollView*)startScrollView {
	return self->_startScrollView;
}

-(void)setIsEditing:(BOOL)isEditing {
	if (!self->_isEditing && isEditing) {
		AudioServicesPlaySystemSound(1520);
	}

	self->_isEditing = isEditing;
	[[[Redstone sharedInstance] rootScrollView] setScrollEnabled:!isEditing];

	if (!isEditing) {
		[self setSelectedTile:nil];
	}
}

-(BOOL)isEditing {
	return self->_isEditing;
}

-(void)setSelectedTile:(RSTile*)tile {
	self->selectedTile = tile;

	for (UIView* subview in [self->_startScrollView subviews]) {
		if ([subview isKindOfClass:[RSTile class]]) {
			[(RSTile*)subview setIsSelectedTile:NO];
		}

		if (subview == tile) {
			[tile setIsSelectedTile:YES];
		}
	}

	/*if (tile != nil) {
		[self setIsEditing:YES];
		[tile setIsSelectedTile:YES];
	}*/
}

-(RSTile*)selectedTile {
	return self->selectedTile;
}

-(NSArray*)pinnedLeafIdentifiers {
	return pinnedLeafIds;
}

@end