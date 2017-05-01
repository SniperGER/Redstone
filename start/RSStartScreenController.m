#import "../RedstoneHeaders.h"

@implementation RSStartScreenController

static RSStartScreenController* sharedInstance;

+ (id)sharedInstance {
	return sharedInstance;
}

- (RSStartScrollView*)startScrollView {
	return self->startScrollView;
}

- (id)init {
	self = [super init];

	if (self) {
		sharedInstance = self;

		self->startScrollView = [[RSStartScrollView alloc] initWithFrame:CGRectMake(0,0,screenW,screenH)];
		
		[self loadTiles];
	}

	return self;
}

- (void)loadTiles {
	[[self->startScrollView subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
	pinnedLeafIds = [[NSMutableArray alloc] init];

	NSArray* tilesToLoad = [[RSPreferences preferences] objectForKey:[NSString stringWithFormat:@"%iColumnLayout", [RSMetrics columns]]];
	NSLog(@"[Redstone] tilesToLoad: %d", (int)[tilesToLoad count]);

	for (NSDictionary* tile in tilesToLoad) {
		int size = [[tile objectForKey:@"size"] intValue];
		int row = [[tile objectForKey:@"row"] intValue];
		int column = [[tile objectForKey:@"column"] intValue];
		NSString* bundleIdentifier = [tile objectForKey:@"bundleIdentifier"];

		if ([[[objc_getClass("SBIconController") sharedInstance] model] leafIconForIdentifier:bundleIdentifier] == nil) {
			//return;
		}
		
		NSLog(@"[Redstone] Adding tile %@", bundleIdentifier);

		CGSize tilePositionSize = [RSMetrics tileDimensionsForSize:1];
		CGSize tileSize = [RSMetrics tileDimensionsForSize:size];

		RSTile* tileToAdd = [[RSTile alloc] initWithFrame:CGRectMake((tilePositionSize.width*column)+((column+1)*[RSMetrics tileBorderSpacing]), (tilePositionSize.width*row)+(row*[RSMetrics tileBorderSpacing]),tileSize.width, tileSize.height) leafId:bundleIdentifier size:size];
		tileToAdd.tileX = column;
		tileToAdd.tileY = row;

		[self->pinnedLeafIds addObject:bundleIdentifier];
		[self->startScrollView addSubview:tileToAdd];
	}

	[self updateStartContentSize];
}

- (void)saveTiles {

}

- (void)pinTileWithId:(NSString*)leafId {

}

- (void)unpinTile:(id)tile {

}

- (void)updateStartContentSize {
	RSTile* lastTile = [[RSTile alloc] initWithFrame:CGRectZero];
	CGSize baseSize = [RSMetrics tileDimensionsForSize:1];

	for (UIView* tile in [self->startScrollView subviews]) {
		if ([tile isKindOfClass:[RSTile class]]) {
			if (tile.frame.origin.y > lastTile.frame.origin.y || (tile.frame.origin.y == lastTile.frame.origin.y && tile.frame.size.height > lastTile.frame.size.height)) {
				lastTile = (RSTile*)tile;
			}
		}
	}

	CGSize tileSize = [RSMetrics tileDimensionsForSize:[(RSTile*)lastTile size]];

	CGSize contentSize = CGSizeZero;
	contentSize.width = self->startScrollView.frame.size.width-2;
	contentSize.height = ([(RSTile*)lastTile tileY]*baseSize.height) + tileSize.height + ([(RSTile*)lastTile tileY]+1)*[RSMetrics tileBorderSpacing];

	self->startScrollView.contentSize = contentSize;
}

// Animations
- (void)prepareForAppLaunch:(id)sender {
	NSMutableArray* appsInView = [[NSMutableArray alloc] init];
	NSMutableArray* appsNotInView = [[NSMutableArray alloc] init];

	for (UIView* subview in [self->startScrollView subviews]) {
		if (CGRectIntersectsRect(self->startScrollView.bounds, subview.frame)) {
			[appsInView addObject:subview];
		} else {
			[appsNotInView addObject:subview];
		}
	}

	for (UIView* view in appsInView) {
		[view setHidden:NO];
	}
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
			[view.layer removeAllAnimations];
			CGPoint basePoint = [view convertPoint:[view bounds].origin toView:self->startScrollView];
			
			float layerX = -(basePoint.x-CGRectGetMidX(self->startScrollView.bounds))/view.frame.size.width;
			float layerY = -(basePoint.y-CGRectGetMidY(self->startScrollView.bounds))/view.frame.size.height;
			
			float delay = maxDelay - (([(RSTile*)view tileX]*ANIM_DELAY)+([(RSTile*)view tileY] - minY)*ANIM_DELAY);

			view.center = CGPointMake(CGRectGetMidX(self->startScrollView.bounds), CGRectGetMidY(self->startScrollView.bounds));
			view.layer.anchorPoint = CGPointMake(layerX, layerY);
			
			if (view == sender) {
				delay += 0.1;
			}

			NSArray* animations = [RSAnimation tileSlideOutAnimationWithDuration:ANIM_SCALE_DURATION delay:delay];
			[view.layer addAnimation:[animations objectAtIndex:0] forKey:@"scale"];
			[view.layer addAnimation:[animations objectAtIndex:1] forKey:@"opacity"];
		}
	}

	dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(maxDelay + 0.6 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
		for (RSTile* view in appsInView) {
			[view.layer setOpacity:0];
		}
		//[[Redstone sharedInstance].launchScreenController show];
		
		dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.6 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
			[[objc_getClass("SBIconController") sharedInstance] _launchIcon:[sender icon]];
		});
	});
}

- (void)returnToHomescreen {
	[self->startScrollView setContentOffset:CGPointMake(0, -24)];

	NSMutableArray* appsInView = [[NSMutableArray alloc] init];
	NSMutableArray* appsNotInView = [[NSMutableArray alloc] init];

	for (UIView* subview in [self->startScrollView subviews]) {
		if (CGRectIntersectsRect(self->startScrollView.bounds, subview.frame)) {
			[appsInView addObject:subview];
		} else {
			[appsNotInView addObject:subview];
		}
	}

	for (UIView* view in appsInView) {
		[view setHidden:NO];
	}
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
			[view.layer removeAllAnimations];
			[view.layer setOpacity:0];
			[view setHidden:NO];

			CGPoint basePoint = [view convertPoint:[view bounds].origin toView:self->startScrollView];
			
			float layerX = -(basePoint.x-CGRectGetMidX(self->startScrollView.bounds))/view.frame.size.width;
			float layerY = -(basePoint.y-CGRectGetMidY(self->startScrollView.bounds))/view.frame.size.height;
			
			float delay = maxDelay - (([(RSTile*)view tileX]*ANIM_DELAY)+([(RSTile*)view tileY] - minY)*ANIM_DELAY);

			view.center = CGPointMake(CGRectGetMidX(self->startScrollView.bounds), CGRectGetMidY(self->startScrollView.bounds));
			view.layer.anchorPoint = CGPointMake(layerX, layerY);
			

			NSArray* animations = [RSAnimation tileSlideInAnimationWithDuration:ANIM_SCALE_DURATION delay:delay];
			[view.layer addAnimation:[animations objectAtIndex:0] forKey:@"scale"];
			[view.layer addAnimation:[animations objectAtIndex:1] forKey:@"opacity"];
		}
	}

	dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(maxDelay + 0.6 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
		for (RSTile* view in [self->startScrollView subviews]) {
			[view.layer setOpacity:1];
			[view setAlpha:1.0];
			[view setHidden:NO];
			view.layer.anchorPoint = CGPointMake(0.5,0.5);
			view.center = [view originalCenter];
		}
	});
}

- (void)resetTileVisibility {
	for (RSTile* view in [self->startScrollView subviews]) {
		[view setHidden:NO];
		[view.layer setOpacity:1];
		[view.layer removeAllAnimations];
	}
}

- (void)setIsEditing:(BOOL)editing {
	if (!self->isEditing && editing) {
		AudioServicesPlaySystemSound(1520);
	}

	self->isEditing = editing;
	[[[Redstone sharedInstance] rootScrollView] setScrollEnabled:!editing];


	if (!editing) {
		[self setSelectedTile:nil];
		[[[RSStartScreenController sharedInstance] startScrollView] setScrollEnabled:YES];
	}
}

- (BOOL)isEditing {
	return self->isEditing;
}

- (void)setSelectedTile:(RSTile*)tile {
	self->selectedTile = tile;

	for (UIView* subview in [self->startScrollView subviews]) {
		if ([subview isKindOfClass:[RSTile class]]) {
			[(RSTile*)subview setIsSelectedTile:NO];
		}

		if (subview == tile) {
			[tile setIsSelectedTile:YES];
		}
	}
}

- (RSTile*)selectedTile {
	return self->selectedTile;
}

- (NSArray*)affectedTilesForAttemptingSnapForRect:(CGRect)rect {
	// if rect.center between tile border (horizontal, vertical)
		// move all tiles where tile.y > rect.center
	// if rect.center is in left or right border
		// move tiles respecting rect width
	// if rect.center inside tile
		// move tile + all tiles below
	
	
	
	/*for (RSTile* tile in [self->startScrollView subviews]) {
		if (![tile isSelectedTile]) {
			[tile resetFrameToOriginalPosition];
		}
		if (CGRectIntersectsRect(rect, [tile originalRect])) {
			//CGPoint tileCenter = CGPointMake(tile.frame.size.width/2,
			//								 tile.frame.size.height/2);
			
			NSMutableArray* returnArray = [[NSMutableArray alloc] init];
			
			for (RSTile* _tile in [self->startScrollView subviews]) {
				//if (_tile.frame.origin.y >= tile.frame.origin.y + rect.size.height + [RSMetrics tileBorderSpacing]) {
				if ([_tile originalRect].origin.y >= [tile originalRect].origin.y && ![tile isSelectedTile]) {
					[returnArray addObject:_tile];
				}
			}
			
			[self getNearestSnapPointForPoint:rect.origin];

			return returnArray;
			break;
		}
	}*/
	
	for (RSTile* tile in [self->startScrollView subviews]) {
		if (CGRectIntersectsRect(rect, [tile originalRect])) {
			/*CGPoint tileCenter = CGPointMake(tile.frame.origin.x + (tile.frame.size.width/2),
											 tile.frame.origin.y + (tile.frame.size.height/2));
			
			CGPoint movingTileCenter = CGPointMake(rect.origin.x + (rect.size.width/2),
												   rect.origin.y + (rect.size.height/2));*/
			
			NSMutableArray* returnArray = [[NSMutableArray alloc] init];
			if ((rect.origin.x + rect.size.width) >= tile.frame.origin.x + (tile.frame.size.width*0.2) && rect.origin.y >= tile.frame.origin.y + (tile.frame.size.height*0.25)) {
				[returnArray addObject:tile];
			}
		}
	}
	
	//[self getNearestSnapPointForRect:self->selectedTile.frame];
	
	return nil;
}

- (void)moveDownAffectedTilesForAttemptingSnapForRect:(CGRect)rect {
	NSArray* affectedTiles = [self affectedTilesForAttemptingSnapForRect:rect];
	
	for (RSTile* tile in affectedTiles) {
		if (![tile isSelectedTile]) {
			CGAffineTransform currentTransform = tile.transform;
			[tile setTransform:CGAffineTransformMakeScale(1, 1)];
			CGRect frame = [tile originalRect];
			frame.origin.y += rect.size.height + [RSMetrics tileBorderSpacing];
			
			[tile setFrame:frame];
			[tile setTransform:currentTransform];
		}
	}
}

- (CGPoint)getNearestSnapPointForRect:(CGRect)frame {
	CGPoint point = frame.origin;
	CGSize basePoint = [RSMetrics tileDimensionsForSize:1];
	
	float x = round(MAX(MIN(point.x, self->startScrollView.contentSize.width-frame.size.width), 0) / basePoint.width);
	float y = round(MAX(MIN(point.y, self->startScrollView.contentSize.height-frame.size.height), 0) / basePoint.height);
	
	if (self->selectedTile) {
		self->selectedTile.tileX = x;
		self->selectedTile.tileY = y;
		
		
		CGSize tilePositionSize = [RSMetrics tileDimensionsForSize:1];
		CGSize tileSize = [RSMetrics tileDimensionsForSize:[self->selectedTile size]];
		
		[self->selectedTile setFrame:CGRectMake((tilePositionSize.width * x) + ((x + 1) * [RSMetrics tileBorderSpacing]),
												(tilePositionSize.width * y) + (y * [RSMetrics tileBorderSpacing]),
												tileSize.width,
												tileSize.height)];
	}
	
	NSLog(@"[Redstone] %f, %f", round(point.x / basePoint.width), round(point.y / basePoint.height));
	
	return CGPointZero;
}

- (void)moveDownAffectedTilesForAttemptingSnap:(NSTimer*)info {
	CGRect rect = [[[info userInfo] objectForKey:@"tileRect"] CGRectValue];
	NSArray* affectedTiles = [self affectedTilesForAttemptingSnapForRect:rect];
	
	for (RSTile* tile in affectedTiles) {
		CGRect frame = tile.frame;
		frame.origin.y += rect.size.height + [RSMetrics tileBorderSpacing];
		
		[tile setFrame:frame];
	}
}

- (void)restartMoveTimer:(UIView*)sender {
	
}

@end
