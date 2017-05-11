#import "../Redstone.h"

@implementation RSTile

- (id)initWithFrame:(CGRect)frame leafIdentifier:(NSString*)leafId size:(int)tileSize {
	self = [super initWithFrame:frame];
	
	if (self) {
		self.size = tileSize;
		self.icon = [[[objc_getClass("SBIconController") sharedInstance] model] leafIconForIdentifier:leafId];
		self.originalCenter = self.center;
		
		self->tileLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, frame.size.height-30, frame.size.height-20, 20)];
		[self->tileLabel setText:[self.icon displayName]];
		[self->tileLabel setFont:[UIFont fontWithName:@"SegoeUI" size:14]];
		[self->tileLabel setTextColor:[UIColor whiteColor]];
		[self addSubview:self->tileLabel];
		
		if (tileSize < 2) {
			[self->tileLabel setHidden:YES];
		}
		
		CGSize tileImageSize = [RSMetrics tileIconDimensionsForSize:tileSize];
		self->tileImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, tileImageSize.width, tileImageSize.height)];
		[self->tileImageView setCenter:CGPointMake(frame.size.width/2, frame.size.height/2)];
		[self->tileImageView setImage:[RSAesthetics getImageForTileWithBundleIdentifier:[[self.icon application] bundleIdentifier]]];
		[self->tileImageView setTintColor:[UIColor whiteColor]];
		[self addSubview:self->tileImageView];
		
		[self setBackgroundColor:[RSAesthetics accentColorForTile:[[self.icon application] bundleIdentifier]]];
		
		self->longPressGestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(pressed:)];
		[self->longPressGestureRecognizer setDelegate:self];
		[self addGestureRecognizer:self->longPressGestureRecognizer];
		
		self->panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(moveViewWithGestureRecognizer:)];
		//[self->panGestureRecognizer setEnabled:NO];
		[self->panGestureRecognizer setDelegate:self];
		[self addGestureRecognizer:self->panGestureRecognizer];
		
		self->tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapped:)];
		[self->tapGestureRecognizer requireGestureRecognizerToFail:self->panGestureRecognizer];
		[self->tapGestureRecognizer requireGestureRecognizerToFail:self->longPressGestureRecognizer];
		[self addGestureRecognizer:self->tapGestureRecognizer];
	}
	
	return self;
}

- (BOOL) gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer
shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
	return YES;
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
	if([gestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]] && ! shouldAllowPan) {
		return NO;
	}
	return YES;
}

- (void)moveViewWithGestureRecognizer:(UIPanGestureRecognizer *)_panGestureRecognizer {
	if (!shouldAllowPan) {
		return;
	}
	CGPoint touchLocation = [_panGestureRecognizer locationInView:self.superview];
	
	if (_panGestureRecognizer.state == UIGestureRecognizerStateBegan) {
		[[RSStartScreenController sharedInstance] setSelectedTile:self];
		
		CGPoint relativePosition = [self.superview convertPoint:self.center toView:self.superview];
		self->centerOffset = CGPointMake(relativePosition.x - touchLocation.x, relativePosition.y - touchLocation.y);
	} else if (_panGestureRecognizer.state == UIGestureRecognizerStateEnded) {
		self->centerOffset = CGPointZero;
		
		float step = [RSMetrics tileDimensionsForSize:1].width + [RSMetrics tileBorderSpacing];
		
		CGFloat maxPositionX = [[RSStartScreenController sharedInstance] startScrollView].contentSize.width - [self positionWithoutTransform].size.width;
		CGFloat maxPositionY =  [[RSStartScreenController sharedInstance] startScrollView].contentSize.height - [self positionWithoutTransform].size.height;
		
		CGRect newTilePosition = CGRectMake(MIN(MAX(step * roundf((self.frame.origin.x / step)), 0), maxPositionX),
											MIN(MAX(step * roundf((self.frame.origin.y / step)), 0), maxPositionY),
											[self positionWithoutTransform].size.width,
											[self positionWithoutTransform].size.height);
		
		[UIView animateWithDuration:.3 animations:^{
			[self setEasingFunction:easeOutQuint forKeyPath:@"frame"];
			[self setFrame:newTilePosition];
		} completion:^(BOOL finished) {
			[self removeEasingFunctionForKeyPath:@"frame"];
			self.originalCenter = self.center;
		}];
		
		[[RSStartScreenController sharedInstance] moveAffectedTilesForTile:self];
	} else {
		self.center = CGPointMake(touchLocation.x + self->centerOffset.x, touchLocation.y + self->centerOffset.y);
	}
}

- (void)tapped:(UITapGestureRecognizer*)_tapGestureRecognizer {
	if ([[RSStartScreenController sharedInstance] isEditing]) {
		if ([[RSStartScreenController sharedInstance] selectedTile] == self) {
			[[RSStartScreenController sharedInstance] setIsEditing:NO];
			[self->longPressGestureRecognizer setEnabled:YES];
		} else {
			[[RSStartScreenController sharedInstance] setSelectedTile:self];
		}
	} else {
		[[RSStartScreenController sharedInstance] prepareForAppLaunch:self];
	}
}

- (void)pressed:(UILongPressGestureRecognizer*)_longPressGestureRecognizer {
	if (_longPressGestureRecognizer.state == UIGestureRecognizerStateBegan) {
		shouldAllowPan = NO;
	}
	
	if  (_longPressGestureRecognizer.state == UIGestureRecognizerStateChanged) {
		
		if (![[RSStartScreenController sharedInstance] isEditing]) {
			[[RSStartScreenController sharedInstance] setIsEditing:YES];
			[[RSStartScreenController sharedInstance] setSelectedTile:self];
			
			shouldAllowPan = YES;
			[self->longPressGestureRecognizer setEnabled:NO];
			
			[[[[RSStartScreenController sharedInstance] startScrollView] panGestureRecognizer] setEnabled:NO];
			[[[[RSStartScreenController sharedInstance] startScrollView] panGestureRecognizer] setEnabled:YES];
		}
	}
}

- (CGRect)positionWithoutTransform {
	CGSize originalSize = [RSMetrics tileDimensionsForSize:self.size];
	
	return CGRectMake(self.layer.position.x - (self.bounds.size.width/2),
					  self.layer.position.y - (self.bounds.size.height/2),
					  originalSize.width,
					  originalSize.height);
}

- (void)setIsSelectedTile:(BOOL)isSelectedTile {
	if ([[RSStartScreenController sharedInstance] isEditing]) {
		self->_isSelectedTile = isSelectedTile;
		
		[self->panGestureRecognizer setEnabled:YES];
		[self.layer removeAllAnimations];
		
		if (isSelectedTile) {
			[self.superview bringSubviewToFront:self];
			[self setAlpha:1.0];
			[self setTransform:CGAffineTransformIdentity];
		} else {
			if ([[RSStartScreenController sharedInstance] isEditing]) {
				[self setAlpha:0.8];
				[self setTransform:CGAffineTransformMakeScale(0.8320610687, 0.8320610687)];
				
			} else {
				[self.layer removeAllAnimations];
				[self setAlpha:1.0];
				[self setTransform:CGAffineTransformIdentity];
			}
		}
	} else {
		self->_isSelectedTile = NO;
		[self.layer removeAllAnimations];
		[self setAlpha:1.0];
		[self setTransform:CGAffineTransformMakeScale(1, 1)];
		
		[self->longPressGestureRecognizer setEnabled:YES];
		//[self->panGestureRecognizer setEnabled:NO];
	}
}

@end
