#import "RSTile.h"
#import "RSAesthetics.h"
#import "RSTiltView.h"
#import "RSStartScreenController.h"
#import "RSMetrics.h"
#import "RSLaunchScreenController.h"

#define deg2rad(x) (M_PI * (x) / 180.0)

@implementation RSTile

-(id)initWithFrame:(CGRect)frame leafId:(id)arg2 size:(int)arg3 {
	float factor = [[UIScreen mainScreen] bounds].size.width/414;

	self = [super initWithFrame:frame];

	if (self) {
		self->shouldHover = NO;
		self->isInactive = NO;
		self->launchEnabled = YES;

		self->leafId = arg2;
		self->size = arg3;
		self->originalCenter = self.center;

		/*CGSize baseSize = [RSMetrics tileDimensionsForSize:1];
		self.tileX = frame.size.width / baseSize.width;
		self.tileY = frame.size.height / baseSize.height;*/

		self->icon = [[[objc_getClass("SBIconController") sharedInstance] model] leafIconForIdentifier:arg2];
		self->resourcePath = [NSString stringWithFormat:@"/var/mobile/Library/FESTIVAL/Redstone.bundle/Tiles/%@/", arg2];

		self->innerView = [[RSTiltView alloc] initWithFrame:CGRectMake(0,0,self.frame.size.width,self.frame.size.height)];
		[self->innerView setBackgroundColor:[[RSAesthetics accentColor] colorWithAlphaComponent:[RSAesthetics getTileOpacity]]];
		[self->innerView setTransformOptions:@{
			@"transformAngle": @8,
			@"transformMultiplierX": (self->size == 3) ? @0.5 : @1
		}];

		// self->appLabel = [[UILabel alloc] initWithFrame:CGRectMake(5,self->innerView.frame.size.height-25, self->innerView.frame.size.width-20, 20)];
		// [self->appLabel setText:[NSString stringWithFormat:@"%@", [self->icon displayName]]];

		self->appLabel = [[UILabel alloc] initWithFrame:CGRectIntegral(CGRectMake(0,0, self->innerView.frame.size.width-20, 20))];
		self->appLabel.text = [NSString stringWithFormat:@"%@", [self->icon displayName]];
		self->appLabel.center = CGPointMake(12*factor, self->innerView.frame.size.height-(5*factor));
		self->appLabel.layer.anchorPoint = CGPointMake(0, 1);
		self->appLabel.font = [UIFont fontWithName:@"SegoeUI" size:14];
		self->appLabel.textColor = [UIColor whiteColor];
		[self->appLabel setBackgroundColor:[UIColor colorWithWhite:0.0 alpha:0.0]];
		[self->innerView addSubview:self->appLabel];

		if (self->size < 2) {
			[self->appLabel setHidden:YES];
		}
		[self addSubview:self->innerView];

		UITapGestureRecognizer* tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapped:)];
		[tap setCancelsTouchesInView:NO];
		[self->innerView addGestureRecognizer:tap];

		UILongPressGestureRecognizer* press = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(pressed:)];
		[press setCancelsTouchesInView:YES];
		[self->innerView addGestureRecognizer:press];
	}

	return self;
}

-(void)setIsSelectedTile:(BOOL)isSelected {
	if ([[RSStartScreenController sharedInstance] isEditing]) {
		self->isSelectedTile = isSelected;
		[self.layer removeAllAnimations];
		if (isSelected) {
			[self.superview bringSubviewToFront:self];

			[self->unpinButton removeFromSuperview];
			self->unpinButton = [[UIView alloc] initWithFrame:CGRectMake(self.bounds.size.width-20,-20,40,40)];
			[self->unpinButton setBackgroundColor:[UIColor whiteColor]];
			[self->unpinButton.layer setCornerRadius:20.0];

			UILabel* unpinLabel = [[UILabel alloc] initWithFrame:CGRectMake(0,0,40,40)];
			[unpinLabel setText:@"\uE77A"];
			[unpinLabel setFont:[UIFont fontWithName:@"SegoeMDL2Assets" size:16]];
			[unpinLabel setTextAlignment:NSTextAlignmentCenter];
			[self->unpinButton addSubview:unpinLabel];

			UITapGestureRecognizer* tapToUnpin = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(unpin:)];
			[self->unpinButton addGestureRecognizer:tapToUnpin];

			[self addSubview:self->unpinButton];

			[self->scaleButton removeFromSuperview];
			self->scaleButton = [[UIView alloc] initWithFrame:CGRectMake(self.bounds.size.width-20,self.bounds.size.height-20,40,40)];
			[self->scaleButton setBackgroundColor:[UIColor whiteColor]];
			[self->scaleButton.layer setCornerRadius:20.0];

			UILabel* scaleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0,0,40,40)];
			[scaleLabel setText:@"\uE7EA"];
			[scaleLabel setFont:[UIFont fontWithName:@"SegoeMDL2Assets" size:16]];
			[scaleLabel setTextAlignment:NSTextAlignmentCenter];
			[self->scaleButton addSubview:scaleLabel];

			[self->scaleButton setTransform:CGAffineTransformMakeRotation(deg2rad([self scaleButtonRotationForCurrentSize]))];

			UITapGestureRecognizer* tapToResize = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(setNextSize:)];
			[self->scaleButton addGestureRecognizer:tapToResize];

			[self addSubview:self->scaleButton];

			[self setAlpha:1.0];
			[self setTransform:CGAffineTransformMakeScale(1, 1)];
		} else {
			[self->unpinButton removeFromSuperview];
			[self->scaleButton removeFromSuperview];

			if ([[RSStartScreenController sharedInstance] isEditing]) {
				[self setAlpha:0.8];
				[self setTransform:CGAffineTransformMakeScale(0.8320610687, 0.8320610687)];
				/*[UIView animateKeyframesWithDuration:5.0 delay:0.0 options:UIViewKeyframeAnimationOptionAutoreverse | UIViewKeyframeAnimationOptionRepeat | UIViewAnimationOptionCurveLinear | UIViewKeyframeAnimationOptionCalculationModeCubic animations:^{        
					[UIView addKeyframeWithRelativeStartTime:0.0 relativeDuration:0.25 animations:^{
						[self->innerView setBackgroundColor:[UIColor redColor]];
					}];
					[UIView addKeyframeWithRelativeStartTime:0.25 relativeDuration:0.25 animations:^{
						[self->innerView setBackgroundColor:[UIColor greenColor]];
					}];
					[UIView addKeyframeWithRelativeStartTime:0.5 relativeDuration:0.25 animations:^{
						[self->innerView setBackgroundColor:[UIColor blueColor]];
					}];
					[UIView addKeyframeWithRelativeStartTime:0.75 relativeDuration:0.25 animations:^{
						[self->innerView setBackgroundColor:[UIColor magentaColor]];
					}];
				} completion:nil];*/
			} else {
				[self.layer removeAllAnimations];
				[self setAlpha:1.0];
				[self setTransform:CGAffineTransformMakeScale(1, 1)];
			}
		}
	} else {
		self->isSelectedTile = NO;
		[self->unpinButton removeFromSuperview];
		[self->scaleButton removeFromSuperview];
		[self.layer removeAllAnimations];
		[self setAlpha:1.0];
		[self setTransform:CGAffineTransformMakeScale(1, 1)];
	}
}

-(void)tapped:(id)sender {
	//[[objc_getClass("SBIconController") sharedInstance] _launchIcon:self->icon];
	if ([[RSStartScreenController sharedInstance] isEditing]) {
		if ([[RSStartScreenController sharedInstance] selectedTile] == self) {
			[[RSStartScreenController sharedInstance] setIsEditing:NO];
			[[RSStartScreenController sharedInstance] saveTiles];
		} else {
			[[RSStartScreenController sharedInstance] setSelectedTile:self];
		}
	} else {
		[[RSLaunchScreenController sharedInstance] setLaunchScreenForLeafIdentifier:self->leafId];
		[[RSStartScreenController sharedInstance] prepareForAppLaunch:self];
	}
}

-(void)pressed:(id)sender {
	if (![[RSStartScreenController sharedInstance] isEditing] && [(UILongPressGestureRecognizer*)sender state] == UIGestureRecognizerStateBegan) {
		[[RSStartScreenController sharedInstance] setIsEditing:YES];
		[[RSStartScreenController sharedInstance] setSelectedTile:self];
	}
}

-(void)unpin:(id)sender {
	[[RSStartScreenController sharedInstance] unpinTile:self];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
	[[[RSStartScreenController sharedInstance] startScrollView] setScrollEnabled:NO];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
	if (self->isSelectedTile) {
		UITouch *aTouch = [touches anyObject];
		CGPoint location = [aTouch locationInView:self];
		CGPoint previousLocation = [aTouch previousLocationInView:self];
		self.frame = CGRectOffset(self.frame, (location.x - previousLocation.x), (location.y - previousLocation.y));
	}
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
	[[[RSStartScreenController sharedInstance] startScrollView] setScrollEnabled:YES];
}

-(void)setNextSize:(id)sender {
	self.layer.transform = CATransform3DMakeScale(1.0, 1.0, 1);
	switch (self->size) {
		case 1:
			self->size = 3;
			break;
		case 2:
			self->size = 1;
			break;
		case 3:
			self->size = 2;
			break;
		default: break;
	}

	CGSize tileSize = [RSMetrics tileDimensionsForSize:self->size];
	[self setFrame:CGRectMake(self.frame.origin.x, self.frame.origin.y, tileSize.width, tileSize.height)];
	[self->innerView setFrame:CGRectMake(0,0,self.frame.size.width,self.frame.size.height)];

	if (self->size > 1) {
		[self->appLabel setHidden:NO];
		float factor = [[UIScreen mainScreen] bounds].size.width/414;

		[self->appLabel setFrame:CGRectMake(0,0, self->innerView.frame.size.width-20, 20)];
		self->appLabel.center = CGPointMake(12*factor, self->innerView.frame.size.height-(5*factor));
		self->appLabel.layer.anchorPoint = CGPointMake(0, 1);
	} else {
		[self->appLabel setHidden:YES];
	}
	

	[self setIsSelectedTile:YES];
}

-(float)scaleButtonRotationForCurrentSize {
	switch (self->size) {
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

-(int)size {
	return self->size;
}

-(CGPoint)originalCenter {
	return self->originalCenter;
}

-(NSString*)leafId {
	return self->leafId;
}

-(SBIcon*)icon {
	return self->icon;
}

-(void)updateTileColor {
	[self->innerView setBackgroundColor:[[RSAesthetics accentColorForApp:self->leafId] colorWithAlphaComponent:[RSAesthetics getTileOpacity]]];
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {   
	if (!self.clipsToBounds && !self.hidden && self.alpha > 0) {
		for (UIView *subview in self.subviews.reverseObjectEnumerator) {
			CGPoint subPoint = [subview convertPoint:point fromView:self];
			UIView *result = [subview hitTest:subPoint withEvent:event];
			if (result != nil) {
				return result;
			}
		}
	}

	return nil;
}

@end