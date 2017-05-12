#import "../Redstone.h"

@implementation RSTile

- (id)initWithFrame:(CGRect)frame leafIdentifier:(NSString*)leafId size:(int)tileSize {
	self = [super initWithFrame:frame];
	
	if (self) {
		self.size = tileSize;
		self.icon = [[[objc_getClass("SBIconController") sharedInstance] model] leafIconForIdentifier:leafId];
		self.originalCenter = self.center;
		
		self->tileLabel = [[UILabel alloc] initWithFrame:CGRectZero];
		[self->tileLabel setText:[self.icon displayName]];
		[self->tileLabel setFont:[UIFont fontWithName:@"SegoeUI" size:14]];
		[self->tileLabel setTextColor:[UIColor whiteColor]];
		
		[self->tileLabel sizeToFit];
		[self->tileLabel setFrame:CGRectMake(8,
											 self.frame.size.height - self->tileLabel.frame.size.height - 8,
											 self->tileLabel.frame.size.width,
											 self->tileLabel.frame.size.height)];
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
		[self->longPressGestureRecognizer setMinimumPressDuration:1.0];
		[self addGestureRecognizer:self->longPressGestureRecognizer];
		
		self->panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(moveViewWithGestureRecognizer:)];
		//[self->panGestureRecognizer setEnabled:NO];
		[self->panGestureRecognizer setDelegate:self];
		[self addGestureRecognizer:self->panGestureRecognizer];
		
		self->tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapped:)];
		[self->tapGestureRecognizer requireGestureRecognizerToFail:self->panGestureRecognizer];
		[self->tapGestureRecognizer requireGestureRecognizerToFail:self->longPressGestureRecognizer];
		[self addGestureRecognizer:self->tapGestureRecognizer];
		
		
		self->unpinButton = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
		[self->unpinButton setCenter:CGPointMake(frame.size.width, 0)];
		[self->unpinButton setBackgroundColor:[UIColor whiteColor]];
		[self->unpinButton.layer setCornerRadius:15];
		[self->unpinButton setHidden:YES];
		[self addSubview:self->unpinButton];
		
		UILabel* unpinLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
		[unpinLabel setFont:[UIFont fontWithName:@"SegoeMDL2Assets" size:14]];
		[unpinLabel setText:@"\uE77A"];
		[unpinLabel setTextAlignment:NSTextAlignmentCenter];
		[self->unpinButton addSubview:unpinLabel];
		
		self->unpinGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(unpin:)];
		[self->unpinButton addGestureRecognizer:self->unpinGestureRecognizer];
		
		self->scaleButton = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
		[self->scaleButton setCenter:CGPointMake(frame.size.width, frame.size.height)];
		[self->scaleButton setBackgroundColor:[UIColor whiteColor]];
		[self->scaleButton.layer setCornerRadius:15];
		[self->scaleButton setHidden:YES];
		[self->scaleButton setTransform:CGAffineTransformMakeRotation(deg2rad([self scaleButtonRotationForCurrentSize]))];
		[self addSubview:self->scaleButton];
		
		UILabel* scaleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
		[scaleLabel setText:@"\uE7EA"];
		[scaleLabel setFont:[UIFont fontWithName:@"SegoeMDL2Assets" size:14]];
		[scaleLabel setTextAlignment:NSTextAlignmentCenter];
		[self->scaleButton addSubview:scaleLabel];
		
		self->scaleGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(setNextSize)];
		[self->scaleButton addGestureRecognizer:self->scaleGestureRecognizer];
	}
	
	return self;
}

- (BOOL) gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer
shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
	return YES;
}

- (void)moveViewWithGestureRecognizer:(UIPanGestureRecognizer *)_panGestureRecognizer {
	CGPoint touchLocation = [_panGestureRecognizer locationInView:self.superview];
	
	if (_panGestureRecognizer.state == UIGestureRecognizerStateBegan) {
		[[RSStartScreenController sharedInstance] setSelectedTile:self];
		
		CGPoint relativePosition = [self.superview convertPoint:self.center toView:self.superview];
		self->centerOffset = CGPointMake(relativePosition.x - touchLocation.x, relativePosition.y - touchLocation.y);
	}
	
	if (_panGestureRecognizer.state == UIGestureRecognizerStateChanged && shouldAllowPan) {
		self.center = CGPointMake(touchLocation.x + self->centerOffset.x, touchLocation.y + self->centerOffset.y);
	}
	
	if (_panGestureRecognizer.state == UIGestureRecognizerStateEnded && shouldAllowPan) {
		self->centerOffset = CGPointZero;
		
		float step = [RSMetrics tileDimensionsForSize:1].width + [RSMetrics tileBorderSpacing];
		
		CGFloat maxPositionX = [[RSStartScreenController sharedInstance] startScrollView].contentSize.width - [self positionWithoutTransform].size.width;
		CGFloat maxPositionY =  [[RSStartScreenController sharedInstance] startScrollView].contentSize.height - [self positionWithoutTransform].size.height;
		
		CGRect newFrame = CGRectMake(MIN(MAX(step * roundf((self.frame.origin.x / step)), 0), maxPositionX),
											MIN(MAX(step * roundf((self.frame.origin.y / step)), 0), maxPositionY),
											[self positionWithoutTransform].size.width,
											[self positionWithoutTransform].size.height);
		
		int tileX = newFrame.origin.x / ([RSMetrics tileDimensionsForSize:1].width + [RSMetrics tileBorderSpacing]);
		int tileY = newFrame.origin.y / ([RSMetrics tileDimensionsForSize:1].height + [RSMetrics tileBorderSpacing]);
		
		[self setTileX:tileX];
		[self setTileY:tileY];
		
		[UIView animateWithDuration:.3 animations:^{
			[self setEasingFunction:easeOutQuint forKeyPath:@"frame"];
			[self setFrame:newFrame];
		} completion:^(BOOL finished) {
			[self removeEasingFunctionForKeyPath:@"frame"];
			
			self.originalCenter = self.center;
		}];
		
		[[RSStartScreenController sharedInstance] moveAffectedTilesForTile:self];
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
			[self->tapGestureRecognizer setEnabled:NO];
			[self->tapGestureRecognizer setEnabled:YES];
			
			[[RSStartScreenController sharedInstance] setIsEditing:YES];
			[[RSStartScreenController sharedInstance] setSelectedTile:self];
			
			[self->longPressGestureRecognizer setEnabled:NO];
		}
	}
}

- (void)unpin:(UITapGestureRecognizer*)recognizer {
	if (recognizer.state == UIGestureRecognizerStateBegan) {
		[self->tapGestureRecognizer setEnabled:NO];
		[self setBackgroundColor:[UIColor magentaColor]];
	}
	
	
	[[RSStartScreenController sharedInstance] unpinTile:self];
}

- (void)setNextSize {
	switch (self.size) {
		case 1:
			self.size = 3;
			break;
		case 2:
			self.size = 1;
			break;
		case 3:
			self.size = 2;
			break;
		default: break;
	}
	
	CGSize newTileSize = [RSMetrics tileDimensionsForSize:self.size];
	
	float step = [RSMetrics tileDimensionsForSize:1].width + [RSMetrics tileBorderSpacing];
	
	CGFloat maxPositionX = [[RSStartScreenController sharedInstance] startScrollView].contentSize.width - [self positionWithoutTransform].size.width;
	CGFloat maxPositionY =  [[RSStartScreenController sharedInstance] startScrollView].contentSize.height - [self positionWithoutTransform].size.height;
	
	CGRect newTilePosition = CGRectMake(MIN(MAX(step * roundf((self.frame.origin.x / step)), 0), maxPositionX),
										MIN(MAX(step * roundf((self.frame.origin.y / step)), 0), maxPositionY),
										newTileSize.width,
										newTileSize.height);
	
	
	[self setFrame:newTilePosition];
	self.originalCenter = self.center;
	
	if (self.size < 2) {
		[self->tileLabel setHidden:YES];
	} else {
		[self->tileLabel setFrame:CGRectMake(8,
											 self.frame.size.height - self->tileLabel.frame.size.height - 8,
											 self->tileLabel.frame.size.width,
											 self->tileLabel.frame.size.height)];
		[self->tileLabel setHidden:NO];
	}
	
	CGSize tileImageSize = [RSMetrics tileIconDimensionsForSize:self.size];
	[self->tileImageView setFrame:CGRectMake(0, 0, tileImageSize.width, tileImageSize.height)];
	[self->tileImageView setCenter:CGPointMake(self.frame.size.width/2, self.frame.size.height/2)];
	
	[self->unpinButton setCenter:CGPointMake(self.frame.size.width, 0)];
	[self->scaleButton setCenter:CGPointMake(self.frame.size.width, self.frame.size.height)];
	
	[self->scaleButton setTransform:CGAffineTransformMakeRotation(deg2rad([self scaleButtonRotationForCurrentSize]))];
	
	[[RSStartScreenController sharedInstance] moveAffectedTilesForTile:self];
}

- (CGFloat)scaleButtonRotationForCurrentSize {
	switch (self.size) {
		case 1:
			return -135.0;
			break;
		case 2:
			return 45.0;
			break;
		case 3:
			return 0.0;
			break;
		default:
			return 0.0;
			break;
			
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
			shouldAllowPan = YES;
			[[[[RSStartScreenController sharedInstance] startScrollView] panGestureRecognizer] setEnabled:NO];
			[[[[RSStartScreenController sharedInstance] startScrollView] panGestureRecognizer] setEnabled:YES];
			
			[self.superview bringSubviewToFront:self];
			[self setAlpha:1.0];
			[self setTransform:CGAffineTransformIdentity];
			
			[self->unpinButton setHidden:NO];
			[self->scaleButton setHidden:NO];
		} else {
			shouldAllowPan = NO;
			[self->unpinButton setHidden:YES];
			[self->scaleButton setHidden:YES];
			
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
		shouldAllowPan = NO;
		
		[self->unpinButton setHidden:YES];
		[self->scaleButton setHidden:YES];
	}
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
	if ([[RSStartScreenController sharedInstance] isEditing]) {
		if (CGRectContainsPoint(self->unpinButton.frame, point)) {
			
			[self->tapGestureRecognizer setEnabled:NO];
			[self->panGestureRecognizer setEnabled:NO];
			return self->unpinButton;
		} else if (CGRectContainsPoint(self->scaleButton.frame, point)) {
				
			[self->tapGestureRecognizer setEnabled:NO];
			[self->panGestureRecognizer setEnabled:NO];
			return self->scaleButton;
		}
	}
	
	[self->tapGestureRecognizer setEnabled:YES];
	[self->panGestureRecognizer setEnabled:YES];

	return [super hitTest:point withEvent:event];
}

@end
