#import "RSTile.h"
#import "RSTileScrollView.h"
#define deg2rad(x) (M_PI * (x) / 180.0)

@implementation RSTile

//\uE77A
//\uE7EA

-(id)initWithTileSize:(int)tileSize withOptions:(NSDictionary*)options {
	NSInteger x = [[options objectForKey:@"X"] intValue];
	NSInteger y = [[options objectForKey:@"Y"] intValue];
	
	self.parentView = [options objectForKey:@"parentView"];
	self.tileSize = tileSize;
	self.applicationIdentifier = [options objectForKey:@"bundleIdentifier"];
	
	self = [super initWithFrame:[self makeTileSize:x forY:y]];

	originalCenter = self.center;
	
	[self _initTile];
	
	return self;
}

-(void)_initTile {
	[self.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
	float factor = [[UIScreen mainScreen] bounds].size.width/414;
	
	// Colored Inside
	self.tileInnerView = [[RSTiltView alloc] initWithFrame:CGRectIntegral(CGRectMake(2, 2, [self bounds].size.width-4, [self bounds].size.height-4))];
	self.tileInnerView.clipsToBounds = YES;
	//self.tiltButton = [[RSTiltButton alloc] initWithFrame:CGRectIntegral(CGRectMake(0, 0, self.tileInnerView.frame.size.width, self.tileInnerView.frame.size.height))];
	[self.tileInnerView addSubview:self.tiltButton];
	[self.tileInnerView setBackgroundColor:[RSAesthetics accentColorForApp:self.applicationIdentifier]];
	[self.tileInnerView setTransformOptions:@{
		@"transformAngle": @8
	}];
	[self.tileInnerView setActionForTapped:@selector(triggerAppLaunch:) forTarget:self];
	[self.tileInnerView setActionForPressed:@selector(prepareForEditMode:) forTarget:self];
	if (self.parentView->isEditing) {
		[self.tileInnerView setUserInteractionEnabled:NO];
	}
	
	// - Set Alpha to Global Transparency setting
	if ([[RSTileDelegate getTileInfo:self.applicationIdentifier] objectForKey:@"tileAccentColor"] == nil) {
		[self.tileInnerView setBackgroundColor:[self.tileInnerView.backgroundColor colorWithAlphaComponent:[RSAesthetics getTileOpacity]]];
	}
	[self addSubview:self.tileInnerView];
	
	// Application Image
	if ([[[RSTileDelegate getTileInfo:self.applicationIdentifier] objectForKey:@"isFullsizeTile"] boolValue]) {
		UIImage* tileImageData = nil;
		switch (self.tileSize) {
			case 1:
				tileImageData = [RSAesthetics getTileImage:self.applicationIdentifier withSize:1];
				break;
			case 2:
				tileImageData = [RSAesthetics getTileImage:self.applicationIdentifier withSize:2];
				break;
			default: break;
		}
		self.tileImage = [[UIImageView alloc] initWithImage:tileImageData];
		[self.tileImage setFrame:CGRectMake(CGRectGetMidX(self.tileInnerView.bounds)-self.frame.size.width/2, CGRectGetMidY(self.tileInnerView.bounds)-self.frame.size.height/2, self.frame.size.width, self.frame.size.height)];
	} else {
		if (self.tileSize < 2) {
			UIImage* tileImageData = [RSAesthetics getTileImage:self.applicationIdentifier withSize:1];
			self.tileImage = [[UIImageView alloc] initWithImage:tileImageData];
			[self.tileImage setFrame:CGRectMake(CGRectGetMidX(self.tileInnerView.bounds)-16, CGRectGetMidY(self.tileInnerView.bounds)-16, 32, 32)];
		} else {
			UIImage* tileImageData = [RSAesthetics getTileImage:self.applicationIdentifier withSize:2];
			self.tileImage = [[UIImageView alloc] initWithImage:tileImageData];
			[self.tileImage setFrame:CGRectMake(CGRectGetMidX(self.tileInnerView.bounds)-24, CGRectGetMidY(self.tileInnerView.bounds)-24, 48, 48)];
		}
	}

	[self.tileInnerView addSubview:self.tileImage];

	// Application Label
	if (self.tileSize > 1 && ![[[RSTileDelegate getTileInfo:self.applicationIdentifier] objectForKey:@"isFullsizeTile"] boolValue]) {
		self.appLabel = [[UILabel alloc] initWithFrame:CGRectIntegral(CGRectMake(0,0, self.tileInnerView.frame.size.width-20, 20))];
		self.appLabel.text = [NSString stringWithFormat:@"%@", [RSTileDelegate getTileDisplayName:self.applicationIdentifier]];
		self.appLabel.center = CGPointMake(12*factor, self.tileInnerView.frame.size.height-(5*factor));
		self.appLabel.layer.anchorPoint = CGPointMake(0, 1);
		self.appLabel.font = [UIFont fontWithName:@"SegoeUI" size:14];
		self.appLabel.textColor = [UIColor whiteColor];
		[self.tileInnerView addSubview:self.appLabel];
	}
	[self.appLabel setTransform:CGAffineTransformMakeScale(factor, factor)];

	[self makeEditingModeButtons];
}

-(void)makeEditingModeButtons {
	// Unpin button
	unpinButton = [[UIView alloc] initWithFrame:CGRectMake(self.tileInnerView.frame.size.width-12, -12, 24, 24)];
	[unpinButton setBackgroundColor:[UIColor whiteColor]];
	[unpinButton.layer setCornerRadius:12.0];
	[self addSubview:unpinButton];

	UITapGestureRecognizer* unpin = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(unpin:)];
	[unpinButton addGestureRecognizer:unpin];

	UILabel* unpinButtonLabel = [[UILabel alloc] initWithFrame:CGRectMake(0,0,24,24)];
	unpinButtonLabel.text = @"\uE77A";
	unpinButtonLabel.font = [UIFont fontWithName:@"SegoeMDL2Assets" size:12];
	unpinButtonLabel.textAlignment = NSTextAlignmentCenter;
	unpinButtonLabel.textColor = [UIColor blackColor];
	[unpinButton addSubview:unpinButtonLabel];

	// Change size button
	changeSizeButton = [[UIView alloc] initWithFrame:CGRectMake(self.tileInnerView.frame.size.width-12, self.tileInnerView.frame.size.height-12, 24, 24)];
	[changeSizeButton setBackgroundColor:[UIColor whiteColor]];
	[changeSizeButton.layer setCornerRadius:12.0];
	[self addSubview:changeSizeButton];

	UITapGestureRecognizer* changeSize = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(setNextSize:)];
	[changeSizeButton addGestureRecognizer:changeSize];

	UILabel* changeSizeButtonLabel = [[UILabel alloc] initWithFrame:CGRectMake(0,0,24,24)];
	changeSizeButtonLabel.text = @"\uE7EA";
	changeSizeButtonLabel.font = [UIFont fontWithName:@"SegoeMDL2Assets" size:12];
	changeSizeButtonLabel.textAlignment = NSTextAlignmentCenter;
	changeSizeButtonLabel.textColor = [UIColor blackColor];
	[changeSizeButtonLabel setTransform:CGAffineTransformMakeRotation(deg2rad([self scaleButtonRotationForCurrentSize]))];

	[changeSizeButton addSubview:changeSizeButtonLabel];

	if (!isCurrentlyEditing) {
		[unpinButton setHidden:YES];
		[changeSizeButton setHidden:YES];
	}
}

-(void)unpin:(id)sender {
	[self.parentView unpinTile:self];
}

-(void)setNextSize:(id)sender {
	self.layer.transform = CATransform3DMakeScale(1.0, 1.0, 1);
	switch (self.tileSize) {
		case 1:
			self.tileSize = 3;
			break;
		case 2:
			self.tileSize = 1;
			break;
		case 3:
			self.tileSize = 2;
			break;
		default: break;
	}
	[self setFrame:[self makeTileSize:tileOrigin.x forY:tileOrigin.y]];
	[self _initTile];
	[self addSubview:editingModeButtons];

	self.layer.transform = CATransform3DMakeScale(1.1, 1.1, 1);
}

-(float)scaleButtonRotationForCurrentSize {
	switch (self.tileSize) {
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

-(void)updateTileColor {
	[self.tileInnerView setBackgroundColor:[RSAesthetics accentColorForApp:self.applicationIdentifier]];
	if ([[RSTileDelegate getTileInfo:self.applicationIdentifier] objectForKey:@"tileAccentColor"] == nil) {
		[self.tileInnerView setBackgroundColor:[self.tileInnerView.backgroundColor colorWithAlphaComponent:[RSAesthetics getTileOpacity]]];
	}
}

- (void)triggerAppLaunch:(id)sender {
	// id app = [[objc_getClass("SBApplicationController") sharedInstance] applicationWithBundleIdentifier:self.applicationIdentifier];
 //    [app setFlag:1 forActivationSetting:1];
 //    [[objc_getClass("SBUIController") sharedInstance] activateApplication:app];
	if (!self.parentView->isEditing) {
		[self.parentView tileExitAnimation:self];
	} else {
		[self changeEditingTileFocus];
	}
}

-(void)setIsCurrentlyEditing:(BOOL)isEditing {
	isCurrentlyEditing = isEditing;
}

- (void)prepareForEditMode:(id)sender {
	// id app = [[objc_getClass("SBApplicationController") sharedInstance] applicationWithBundleIdentifier:self.applicationIdentifier];
 //    [app setFlag:1 forActivationSetting:1];
 //    [[objc_getClass("SBUIController") sharedInstance] activateApplication:app];
	[self addSubview:editingModeButtons];
	[self.parentView enterEditModeWithTile:self];
	isCurrentlyEditing = YES;
	[unpinButton setHidden:NO];
	[changeSizeButton setHidden:NO];
	[self.tileInnerView setUserInteractionEnabled:NO];
}
-(void)changeEditingTileFocus {
	[self addSubview:editingModeButtons];
	[self.parentView changeEditingTileFocus:self];
	isCurrentlyEditing = YES;
	[unpinButton setHidden:NO];
	[changeSizeButton setHidden:NO];
	[self.tileInnerView setUserInteractionEnabled:NO];
}
-(void)exitEditMode {
	isCurrentlyEditing = NO;
	[editingModeButtons removeFromSuperview];
	[unpinButton setHidden:YES];
	[changeSizeButton setHidden:YES];
	[self.tileInnerView setUserInteractionEnabled:YES];
}

-(CGRect)makeTileSize:(NSInteger)X forY:(NSInteger)Y {
	CGRect tileSizeRect;
	
	CGFloat tileGridSize = (([self.parentView frame].size.width)/6) / (isCurrentlyEditing?0.9:1);

	self.tileX = X*tileGridSize;
	self.tileY = Y*tileGridSize;
	tileOrigin = CGPointMake(X,Y);

	[self setSize:self.tileSize forGridOrigin:tileOrigin];
	
	switch (self.tileSize) {
		case 1: {
			tileSizeRect = CGRectMake(tileGridSize*X, tileGridSize*Y, tileGridSize, tileGridSize);
			break;
		}
		case 2: {
			tileSizeRect = CGRectMake(tileGridSize*X, tileGridSize*Y, tileGridSize*2, tileGridSize*2);
			break;
		}
		case 3: {
			CGFloat height = tileGridSize*2;
			CGFloat width = (height*2);
			
			tileSizeRect = CGRectMake(tileGridSize*X, tileGridSize*Y, width, height);
			break;
		}
		default:
			tileSizeRect = CGRectZero;
			break;
	}
	
	return tileSizeRect;
}

-(void)setSize:(NSInteger)tileSize forGridOrigin:(CGPoint)gridOrigin {
	activePositions = [[NSMutableArray alloc] init];

	switch(tileSize) {
		case 1: {
			[activePositions addObject:[NSValue valueWithCGPoint:gridOrigin]];
			break;
		}
		case 2: {
			for (int i=0; i<=1; i++) {
				[activePositions addObject:[NSValue valueWithCGPoint:CGPointMake(gridOrigin.x+i, gridOrigin.y)]];
			}
			for (int i=0; i<=1; i++) {
				[activePositions addObject:[NSValue valueWithCGPoint:CGPointMake(gridOrigin.x+i, gridOrigin.y+1)]];
			}
			break;
		}
		case 3: {
			for (int i=0; i<=3; i++) {
				[activePositions addObject:[NSValue valueWithCGPoint:CGPointMake(gridOrigin.x+i, gridOrigin.y)]];
			}
			for (int i=0; i<=3; i++) {
				[activePositions addObject:[NSValue valueWithCGPoint:CGPointMake(gridOrigin.x+i, gridOrigin.y+1)]];
			}
			break;
		}
		default: break;
	}
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{   
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