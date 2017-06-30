#import "../Redstone.h"

@implementation RSTile

- (id)initWithFrame:(CGRect)frame leafIdentifier:(NSString*)leafIdentifier size:(int)size {
	if (self = [super initWithFrame:frame]) {
		[self setBackgroundColor:[[RSAesthetics accentColor] colorWithAlphaComponent:[RSAesthetics tileOpacity]]];
		
		// GESTURE RECOGNIZERS
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

#pragma mark Editing Mode

- (void)setIsSelectedTile:(BOOL)isSelectedTile {
	if ([[RSStartScreenController sharedInstance] isEditing]) {
		_isSelectedTile = isSelectedTile;
		
		[self.layer removeAllAnimations];
		
		if (isSelectedTile) {
			panEnabled = YES;
			
			[[(UIScrollView*)[[RSStartScreenController sharedInstance] view] panGestureRecognizer] setEnabled:NO];
			[[(UIScrollView*)[[RSStartScreenController sharedInstance] view] panGestureRecognizer] setEnabled:YES];
			
			[UIView animateWithDuration:.2 animations:^{
				[self setEasingFunction:easeOutQuint forKeyPath:@"frame"];
			
				[self.superview bringSubviewToFront:self];
				[self setAlpha:1.0];
				[self setTransform:CGAffineTransformMakeScale(1.05, 1.05)];
			} completion:^(BOOL finished) {
				[self removeEasingFunctionForKeyPath:@"frame"];
			}];
		} else {
			panEnabled = NO;
			
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
	}
}

@end
