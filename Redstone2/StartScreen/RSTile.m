#import "../Redstone.h"

@implementation RSTile

- (id)initWithFrame:(CGRect)frame leafIdentifier:(NSString*)leafIdentifier size:(int)size {
	if (self = [super initWithFrame:frame]) {
		self.size = size;
		self.icon = [[(SBIconController*)[objc_getClass("SBIconController") sharedInstance] model] leafIconForIdentifier:leafIdentifier];
		self.tileInfo = [[RSTileInfo alloc] initWithBundleIdentifier:leafIdentifier];
		self.originalCenter = self.center;
		
		[self setBackgroundColor:[RSAesthetics accentColorForTile:self.tileInfo]];
		
		tileWrapper = [[UIView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
		[tileWrapper setClipsToBounds:YES];
		[self addSubview:tileWrapper];
		
		tileContainer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
		[tileWrapper addSubview:tileContainer];
		
		// Title Label
		[[self titleLabel] removeFromSuperview];
		tileLabel = [[UILabel alloc] initWithFrame:CGRectMake(8, self.frame.size.height - 28, self.frame.size.width - 16, 20)];
		[tileLabel setFont:[UIFont fontWithName:@"SegoeUI" size:14]];
		[tileLabel setTextAlignment:NSTextAlignmentLeft];
		[tileLabel setTextColor:[RSAesthetics readableForegroundColorForBackgroundColor:self.backgroundColor]];
		[tileContainer addSubview:tileLabel];
		
		if (self.tileInfo.localizedDisplayName) {
			[tileLabel setText:self.tileInfo.localizedDisplayName];
		} else if (self.tileInfo.displayName) {
			[tileLabel setText:self.tileInfo.displayName];
		} else {
			[tileLabel setText:[self.icon displayName]];
		}
		
		if (self.size < 2 || self.tileInfo.tileHidesLabel || [[self.tileInfo.labelHiddenForSizes objectForKey:[[NSNumber numberWithInt:self.size] stringValue]] boolValue]) {
			[tileLabel setHidden:YES];
		} else {
			[tileLabel setHidden:NO];
		}
		
		// Tile Icon
		if (self.tileInfo.fullSizeArtwork) {
			tileImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
			[tileImageView setImage:[RSAesthetics getImageForTileWithBundleIdentifier:[self.icon applicationBundleID] size:self.size colored:YES]];
			[tileContainer addSubview:tileImageView];
		} else {
			CGSize tileImageSize = [RSMetrics tileIconDimensionsForSize:size];
			tileImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, tileImageSize.width, tileImageSize.height)];
			[tileImageView setCenter:CGPointMake(frame.size.width/2, frame.size.height/2)];
			
			[tileImageView setImage:[RSAesthetics getImageForTileWithBundleIdentifier:[self.icon applicationBundleID] size:5 colored:self.tileInfo.hasColoredIcon]];
			[tileImageView setTintColor:[UIColor whiteColor]];
			[tileContainer addSubview:tileImageView];
		}
		
		// Gesture Recognizers
		longPressGestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(pressed:)];
		[longPressGestureRecognizer setMinimumPressDuration:0.5];
		[longPressGestureRecognizer setCancelsTouchesInView:NO];
		[longPressGestureRecognizer setDelaysTouchesBegan:NO];
		[self addGestureRecognizer:longPressGestureRecognizer];
		
		panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panMoved:)];
		[panGestureRecognizer setDelegate:self];
		[panGestureRecognizer setCancelsTouchesInView:NO];
		[panGestureRecognizer setDelaysTouchesBegan:NO];
		[self addGestureRecognizer:panGestureRecognizer];
		
		tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapped:)];
		[tapGestureRecognizer setCancelsTouchesInView:NO];
		[tapGestureRecognizer setDelaysTouchesBegan:NO];
		[tapGestureRecognizer requireGestureRecognizerToFail:panGestureRecognizer];
		[tapGestureRecognizer requireGestureRecognizerToFail:longPressGestureRecognizer];
		[self addGestureRecognizer:tapGestureRecognizer];
		
		// Editing Mode Buttons
		unpinButton = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
		[unpinButton setCenter:CGPointMake(frame.size.width, 0)];
		[unpinButton setBackgroundColor:[RSAesthetics colorsForCurrentTheme][@"InvertedBackgroundColor"]];
		[unpinButton.layer setCornerRadius:15];
		[unpinButton setHidden:YES];
		[self addSubview:unpinButton];
		
		UILabel* unpinLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
		[unpinLabel setFont:[UIFont fontWithName:@"SegoeMDL2Assets" size:14]];
		[unpinLabel setTextColor:[RSAesthetics colorsForCurrentTheme][@"InvertedForegroundColor"]];
		[unpinLabel setText:@"\uE77A"];
		[unpinLabel setTextAlignment:NSTextAlignmentCenter];
		[unpinButton addSubview:unpinLabel];
		
		unpinGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(unpin)];
		[unpinButton addGestureRecognizer:unpinGestureRecognizer];
		
		scaleButton = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
		[scaleButton setCenter:CGPointMake(frame.size.width, frame.size.height)];
		[scaleButton setBackgroundColor:[RSAesthetics colorsForCurrentTheme][@"InvertedBackgroundColor"]];
		[scaleButton.layer setCornerRadius:15];
		[scaleButton setHidden:YES];
		[scaleButton setTransform:CGAffineTransformMakeRotation(deg2rad([self scaleButtonRotationForCurrentSize]))];
		[self addSubview:scaleButton];
		
		UILabel* scaleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
		[scaleLabel setFont:[UIFont fontWithName:@"SegoeMDL2Assets" size:14]];
		[scaleLabel setTextColor:[RSAesthetics colorsForCurrentTheme][@"InvertedForegroundColor"]];
		[scaleLabel setText:@"\uE7EA"];
		[scaleLabel setTextAlignment:NSTextAlignmentCenter];
		[scaleButton addSubview:scaleLabel];
		
		scaleGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(setNextSize)];
		[scaleButton addGestureRecognizer:scaleGestureRecognizer];
	}
	
	return self;
}

float customRounding(float value) {
	const float roundingValue = 0.5;
	int mulitpler = floor(value / roundingValue);
	return mulitpler * roundingValue;
}

- (CGRect)basePosition {
	float width = customRounding(self.bounds.size.width);
	float height = customRounding(self.bounds.size.height);
	
	return CGRectMake(self.layer.position.x - (width/2),
					  self.layer.position.y - (height/2),
					  width,
					  height);
}

#pragma mark Gesture Recognizers

- (BOOL) gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer
shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
	return YES;
}

- (void)tapped:(UITapGestureRecognizer*)gestureRecognizer {
	if ([[RSStartScreenController sharedInstance] isEditing]) {
		if ([[RSStartScreenController sharedInstance] selectedTile] == self) {
			[[RSStartScreenController sharedInstance] setIsEditing:NO];
			//[longPressGestureRecognizer setEnabled:YES];
		} else {
			[[RSStartScreenController sharedInstance] setSelectedTile:self];
		}
	} else {
		[self setTransform:CGAffineTransformIdentity];
		[[RSLaunchScreenController sharedInstance] setLaunchIdentifier:[self.icon applicationBundleID]];
		[[objc_getClass("SBIconController") sharedInstance] _launchIcon:self.icon];
	}
}

- (void)pressed:(UILongPressGestureRecognizer*)gestureRecognizer {
	panEnabled = NO;
	
	if (![[RSStartScreenController sharedInstance] isEditing]) {
		[tapGestureRecognizer setEnabled:NO];
		[tapGestureRecognizer setEnabled:YES];
		
		[[RSStartScreenController sharedInstance] setIsEditing:YES];
		[[RSStartScreenController sharedInstance] setSelectedTile:self];
		
		[longPressGestureRecognizer setEnabled:NO];
	}
}

- (void)panMoved:(UIPanGestureRecognizer*)gestureRecognizer {
	CGPoint touchLocation = [gestureRecognizer locationInView:self.superview];
	
	if (gestureRecognizer.state == UIGestureRecognizerStateBegan) {
		[[RSStartScreenController sharedInstance] setSelectedTile:self];
		
		CGPoint relativePosition = [self.superview convertPoint:self.center toView:self.superview];
		centerOffset = CGPointMake(relativePosition.x - touchLocation.x, relativePosition.y - touchLocation.y);
	}
	
	if (gestureRecognizer.state == UIGestureRecognizerStateChanged && panEnabled) {
		self.center = CGPointMake(touchLocation.x + centerOffset.x, touchLocation.y + centerOffset.y);
	}
	
	if (gestureRecognizer.state == UIGestureRecognizerStateEnded && panEnabled) {
		centerOffset = CGPointZero;
		
		[[RSStartScreenController sharedInstance] snapTile:self withTouchPosition:self.center];
	}
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
	if (self.isSelectedTile) {
		if (CGRectContainsPoint(unpinButton.frame, point)) {
			
			[tapGestureRecognizer setEnabled:NO];
			[panGestureRecognizer setEnabled:NO];
			return unpinButton;
		} else if (CGRectContainsPoint(scaleButton.frame, point)) {
			
			[tapGestureRecognizer setEnabled:NO];
			[panGestureRecognizer setEnabled:NO];
			return scaleButton;
		}
	}
	
	[tapGestureRecognizer setEnabled:YES];
	[panGestureRecognizer setEnabled:YES];
	
	return [super hitTest:point withEvent:event];
}

#pragma mark Editing Mode

- (void)setIsSelectedTile:(BOOL)isSelectedTile {
	if ([[RSStartScreenController sharedInstance] isEditing]) {
		_isSelectedTile = isSelectedTile;
		
		[self.layer removeAllAnimations];
		
		if (isSelectedTile) {
			panEnabled = YES;
			
			[[(UIScrollView*)[[RSStartScreenController sharedInstance] view] panGestureRecognizer] setEnabled:NO];
			[[(UIScrollView*)[[RSStartScreenController sharedInstance] view] panGestureRecognizer] setEnabled:YES];
			
			
			[self.superview bringSubviewToFront:self];
			[self setAlpha:1.0];
			[self setTransform:CGAffineTransformMakeScale(1.05, 1.05)];
			
			[unpinButton setHidden:NO];
			[scaleButton setHidden:NO];
		} else {
			panEnabled = NO;
			[unpinButton setHidden:YES];
			[scaleButton setHidden:YES];
			
			[UIView animateWithDuration:.2 animations:^{
				[self setEasingFunction:easeOutQuint forKeyPath:@"frame"];
				
				[self setAlpha:0.8];
				[self setTransform:CGAffineTransformMakeScale(0.85, 0.85)];
			} completion:^(BOOL finished) {
				[self removeEasingFunctionForKeyPath:@"frame"];
			}];

		}
	} else {
		_isSelectedTile = NO;
		[self.layer removeAllAnimations];
		
		[UIView animateWithDuration:.2 animations:^{
			[self setEasingFunction:easeOutQuint forKeyPath:@"frame"];
			
			[self setAlpha:1.0];
			[self setTransform:CGAffineTransformIdentity];
		} completion:^(BOOL finished) {
			[self removeEasingFunctionForKeyPath:@"frame"];
		}];
		
		[longPressGestureRecognizer setEnabled:YES];
		panEnabled = NO;
		
		[unpinButton setHidden:YES];
		[scaleButton setHidden:YES];
	}
}

- (void)unpin {
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
	CGFloat step = [RSMetrics tileDimensionsForSize:1].width + [RSMetrics tileBorderSpacing];
	
	CGFloat maxPositionX = [[RSStartScreenController sharedInstance] view].bounds.size.width - newTileSize.width;
	CGFloat maxPositionY = [(UIScrollView*)[[RSStartScreenController sharedInstance] view] contentSize].height + [RSMetrics tileBorderSpacing];
	
	CGRect newFrame = CGRectMake(MIN(MAX(step * roundf((self.basePosition.origin.x / step)), 0), maxPositionX),
								 MIN(MAX(step * roundf((self.basePosition.origin.y / step)), 0), maxPositionY),
								 newTileSize.width,
								 newTileSize.height);
	
	CGAffineTransform currentTransform = self.transform;
	
	[self setTransform:CGAffineTransformIdentity];
	[self setFrame:newFrame];
	[self setTransform:currentTransform];
	
	[tileWrapper setFrame:CGRectMake(0, 0, newFrame.size.width, newFrame.size.height)];
	
	/// TODO: Live Tile
	
	if (self.size < 2 || self.tileInfo.tileHidesLabel || [[self.tileInfo.labelHiddenForSizes objectForKey:[[NSNumber numberWithInt:self.size] stringValue]] boolValue]) {
		[tileLabel setHidden:YES];
	} else {
		[tileLabel setHidden:NO];
		[tileLabel setFrame:CGRectMake(8,
									   newFrame.size.height - tileLabel.frame.size.height - 8,
									   tileLabel.frame.size.width,
									   tileLabel.frame.size.height)];
	}
	
	if (self.tileInfo.fullSizeArtwork) {
		[tileImageView setFrame:CGRectMake(0, 0, newFrame.size.width, newFrame.size.height)];
		[tileImageView setImage:[RSAesthetics getImageForTileWithBundleIdentifier:[self.icon applicationBundleID] size:self.size colored:YES]];
	} else {
		CGSize tileImageSize = [RSMetrics tileIconDimensionsForSize:self.size];
		[tileImageView setFrame:CGRectMake(0, 0, tileImageSize.width, tileImageSize.height)];
		[tileImageView setCenter:CGPointMake(newFrame.size.width/2, newFrame.size.height/2)];
		
		[tileImageView setImage:[RSAesthetics getImageForTileWithBundleIdentifier:[self.icon applicationBundleID] size:self.size colored:self.tileInfo.hasColoredIcon]];
		[tileImageView setTintColor:[UIColor whiteColor]];
	}
	
	[unpinButton setCenter:CGPointMake(newFrame.size.width, 0)];
	[scaleButton setCenter:CGPointMake(newFrame.size.width, newFrame.size.height)];
	
	[scaleButton setTransform:CGAffineTransformMakeRotation(deg2rad([self scaleButtonRotationForCurrentSize]))];
	
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
		case 4:
			return 90.0;
		default:
			return 0.0;
			break;
			
	}
}

@end
