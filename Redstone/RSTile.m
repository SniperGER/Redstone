#import "Redstone.h"

@implementation RSTile

- (id)initWithFrame:(CGRect)frame leafIdentifier:(NSString*)leafId size:(int)tileSize {
	self = [super initWithFrame:frame];
	
	if (self) {
		self.size = tileSize;
		self.icon = [[[objc_getClass("SBIconController") sharedInstance] model] leafIconForIdentifier:leafId];
		self->originalCenter = self.center;
		
		self->tileLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, frame.size.height-30, frame.size.height-20, 20)];
		[self->tileLabel setText:[self.icon displayName]];
		[self->tileLabel setFont:[UIFont fontWithName:@".SFCompactText-Regular" size:14]];
		[self->tileLabel setTextColor:[UIColor whiteColor]];
		[self addSubview:self->tileLabel];
		
		if (tileSize < 2) {
			[self->tileLabel setHidden:YES];
		}
		
		[self setBackgroundColor:[UIColor colorWithRed:0.0 green:0.47 blue:0.843 alpha:1.0]];
		
		self->panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(moveViewWithGestureRecognizer:)];
		[self->panGestureRecognizer setEnabled:NO];
		[self addGestureRecognizer:self->panGestureRecognizer];
		
		UITapGestureRecognizer* tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapped:)];
		[tap requireGestureRecognizerToFail:self->panGestureRecognizer];
		[self addGestureRecognizer:tap];
	}
	
	return self;
}

- (void)moveViewWithGestureRecognizer:(UIPanGestureRecognizer *)_panGestureRecognizer {
	CGPoint touchLocation = [_panGestureRecognizer locationInView:self.superview];
	
	if (_panGestureRecognizer.state == UIGestureRecognizerStateBegan) {
		[self.superview bringSubviewToFront:self];
		
		CGPoint relativePosition = [self.superview convertPoint:self.center toView:self.superview];
		self->centerOffset = CGPointMake(relativePosition.x - touchLocation.x, relativePosition.y - touchLocation.y);
	} else if (_panGestureRecognizer.state == UIGestureRecognizerStateEnded) {
		self->centerOffset = CGPointZero;
		
		float step = [RSMetrics tileDimensionsForSize:1].width + [RSMetrics tileBorderSpacing];
		
		CGRect newTilePosition = CGRectMake(MIN(MAX(step * roundf((self.frame.origin.x / step)), 0), self.superview.frame.size.width - self.frame.size.width),
											MIN(MAX(step * roundf((self.frame.origin.y / step)), 0), self.superview.frame.size.height - self.frame.size.height),
											self.frame.size.width,
											self.frame.size.height);
		
		[UIView animateWithDuration:.3 animations:^{
			[self setEasingFunction:easeOutQuint forKeyPath:@"frame"];
			[self setFrame:newTilePosition];
		} completion:^(BOOL finished) {
			[self removeEasingFunctionForKeyPath:@"frame"];
		}];
		[[[RSCore sharedInstance] startScreenController] moveAffectedTilesForTile:self];
	} else {
		self.center = CGPointMake(touchLocation.x + self->centerOffset.x, touchLocation.y + self->centerOffset.y);
	}
}

- (void)tapped:(UITapGestureRecognizer*)tapGestureRecognizer {
	//[[objc_getClass("SBIconController") sharedInstance] _launchIcon:self.icon];
	
	if ([[[RSCore sharedInstance] startScreenController] isEditing]) {
		[[[RSCore sharedInstance] startScreenController] setSelectedTile:self];
	} else {
		[[[RSCore sharedInstance] startScreenController] prepareForAppLaunch:self];
	}
}

- (CGRect)positionWithoutTransform {
	CGSize originalSize = [RSMetrics tileDimensionsForSize:self.size];
	
	return CGRectMake(self.layer.position.x - (self.bounds.size.width/2),
					  self.layer.position.y - (self.bounds.size.height/2),
					  originalSize.width,
					  originalSize.height);
}

- (CGPoint)originalCenter {
	return self->originalCenter;
}

- (void)setIsSelectedTile:(BOOL)isSelectedTile {
	if ([[[RSCore sharedInstance] startScreenController] isEditing]) {
		self->_isSelectedTile = isSelectedTile;
		
		[self.layer removeAllAnimations];
		
		if (isSelectedTile) {
			[self->panGestureRecognizer setEnabled:YES];
			[self.superview bringSubviewToFront:self];
			[self setAlpha:1.0];
			[self setTransform:CGAffineTransformMakeScale(1, 1)];
		} else {
			[self->panGestureRecognizer setEnabled:NO];
			if ([[[RSCore sharedInstance] startScreenController] isEditing]) {
				[self setAlpha:0.8];
				[self setTransform:CGAffineTransformMakeScale(0.8320610687, 0.8320610687)];
				
			} else {
				[self.layer removeAllAnimations];
				[self setAlpha:1.0];
				[self setTransform:CGAffineTransformMakeScale(1, 1)];
			}
		}
	} else {
		self->_isSelectedTile = NO;
		[self.layer removeAllAnimations];
		[self setAlpha:1.0];
		[self setTransform:CGAffineTransformMakeScale(1, 1)];
		[self->panGestureRecognizer setEnabled:NO];
	}
}

@end
