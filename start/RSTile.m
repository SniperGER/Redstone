#import "../RedstoneHeaders.h"

@implementation RSTile

- (id)initWithFrame:(CGRect)frame leafId:(id)_leafId size:(int)_size {

	self = [super initWithFrame:frame];

	if (self) {
		self->shouldHover = NO;
		self->isInactive = NO;
		self->launchEnabled = YES;

		self->leafId = _leafId;
		self->size = _size;
		self->originalRect = frame;
		self->originalCenter = self.center;

		self->icon = [[[objc_getClass("SBIconController") sharedInstance] model] leafIconForIdentifier:leafId];
		self->resourcePath = [NSString stringWithFormat:@"/var/mobile/Library/FESTIVAL/Redstone.bundle/Tiles/%@/", leafId];

		self->innerView = [[RSTiltView alloc] initWithFrame:CGRectMake(0,0,self.frame.size.width,self.frame.size.height)];
		[self->innerView setBackgroundColor:[[RSAesthetics accentColorForApp:self->leafId] colorWithAlphaComponent:[RSAesthetics tileOpacityForApp:self->leafId]]];
		[self->innerView setTransformOptions:@{
			@"transformAngle": @8,
			@"transformMultiplierX": (self->size == 3) ? @0.5 : @1
		}];

		CGSize tileImageSize = [RSMetrics tileImageDimensionsForSize:self->size];
		self->tileImage = [[UIImageView alloc] initWithImage:[RSAesthetics tileImageForApp:self->leafId withSize:self->size]];
		[self->tileImage setFrame:CGRectMake((self.frame.size.width/2) - (tileImageSize.width/2),
											 (self.frame.size.height/2) - (tileImageSize.height/2),
											 tileImageSize.width,
											 tileImageSize.height)];
		[self->innerView addSubview:self->tileImage];

		self->appLabel = [[UILabel alloc] initWithFrame:CGRectMake(8,self->innerView.frame.size.height-28, self->innerView.frame.size.width-20, 20)];
		self->appLabel.text = [NSString stringWithFormat:@"%@", [self->icon displayName]];
		self->appLabel.font = [UIFont fontWithName:@"SegoeUI" size:15];
		self->appLabel.textColor = [UIColor whiteColor];
		[self->appLabel setBackgroundColor:[UIColor colorWithWhite:0.0 alpha:0.0]];
		[self->innerView addSubview:self->appLabel];

		if (self->size < 2) {
			[self->appLabel setHidden:YES];
		}
		[self addSubview:self->innerView];

		self->tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapped:)];
		[tap setCancelsTouchesInView:NO];
		[self addGestureRecognizer:tap];

		self->press = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(pressed:)];
		//[press setCancelsTouchesInView:YES];
		[self addGestureRecognizer:press];
	}

	return self;
}

- (void)tapped:(id)sender {
	if ([[RSStartScreenController sharedInstance] isEditing]) {
		if ([[RSStartScreenController sharedInstance] selectedTile] == self) {
			[[RSStartScreenController sharedInstance] setIsEditing:NO];
			[[RSStartScreenController sharedInstance] saveTiles];
		} else {
			[[RSStartScreenController sharedInstance] setSelectedTile:self];
		}
	} else {
		//[[RSLaunchScreenController sharedInstance] setLaunchScreenForLeafIdentifier:self->leafId];
		[[RSStartScreenController sharedInstance] prepareForAppLaunch:self];
	}
}

- (void)pressed:(id)sender {
	if (![[RSStartScreenController sharedInstance] isEditing] && [(UILongPressGestureRecognizer*)sender state] == UIGestureRecognizerStateBegan) {
		[[RSStartScreenController sharedInstance] setIsEditing:YES];
		[[RSStartScreenController sharedInstance] setSelectedTile:self];
	}
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
	if (self->isSelectedTile) {
		self->tap.enabled = YES;
		[[[RSStartScreenController sharedInstance] startScrollView] setScrollEnabled:NO];
	}
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
	/*if (self->isSelectedTile) {
		self->tap.enabled = NO;
		UITouch *aTouch = [touches anyObject];
		CGPoint location = [aTouch locationInView:self];
		CGPoint previousLocation = [aTouch previousLocationInView:self];
		self.frame = CGRectOffset(self.frame, (location.x - previousLocation.x), (location.y - previousLocation.y));
	}*/
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
	if (self->isSelectedTile) {
		self->tap.enabled = YES;
		[[[RSStartScreenController sharedInstance] startScrollView] setScrollEnabled:YES];
		[[RSStartScreenController sharedInstance] moveDownAffectedTilesForAttemptingSnapForRect:self.frame];
	}
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
	if (self->isSelectedTile) {
		self->tap.enabled = YES;
		[[[RSStartScreenController sharedInstance] startScrollView] setScrollEnabled:YES];
	}
}

- (void)setIsSelectedTile:(BOOL)selected {
	if ([[RSStartScreenController sharedInstance] isEditing]) {
		self->isSelectedTile = selected;
		[self.layer removeAllAnimations];

		[self->innerView setUserInteractionEnabled:NO];

		if (selected) {
			[self.superview bringSubviewToFront:self];
			[self setAlpha:1.0];
			[self setTransform:CGAffineTransformMakeScale(1, 1)];
		} else {
			if ([[RSStartScreenController sharedInstance] isEditing]) {
				[self setAlpha:0.8];
				[self setTransform:CGAffineTransformMakeScale(0.8320610687, 0.8320610687)];
				
			} else {
				[self.layer removeAllAnimations];
				[self setAlpha:1.0];
				[self setTransform:CGAffineTransformMakeScale(1, 1)];
			}
		}
	} else {
		self->isSelectedTile = NO;
		[self.layer removeAllAnimations];
		[self setAlpha:1.0];
		[self setTransform:CGAffineTransformMakeScale(1, 1)];
		[self->innerView setUserInteractionEnabled:YES];
	}
}

- (void)resetFrameToOriginalPosition {
	CGAffineTransform currentTransform = self.transform;
	[self setTransform:CGAffineTransformMakeScale(1, 1)];

	[self setFrame:self->originalRect];
	
	[self setTransform:currentTransform];
	//NSLog(@"[Redstone] %@", [NSValue valueWithCGRect:self.frame]);
}

- (int)size {
	return self->size;
}

- (BOOL)isSelectedTile {
	return self->isSelectedTile;
}

- (CGRect)originalRect {
	return self->originalRect;
}

- (CGPoint)originalCenter {
	return self->originalCenter;
}

- (SBIcon*)icon {
	return self->icon;
}

@end
