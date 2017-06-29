#import "../Redstone.h"

@implementation RSTiltView

- (id)initWithFrame:(CGRect)frame {
	self = [super initWithFrame:frame];
	
	if (self) {
		self.tiltEnabled = YES;
		
		self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
		[self.titleLabel setTextAlignment:NSTextAlignmentCenter];
		[self addSubview:self.titleLabel];
		
		[self.layer setShouldRasterize:YES];
		[self.layer setRasterizationScale:[UIScreen mainScreen].scale];
		[self.layer setContentsScale:[UIScreen mainScreen].scale];
		[self.layer setAllowsEdgeAntialiasing:YES];
	}
	
	return self;
}

- (void)calculatePerspective {
	[self.layer removeAllAnimations];
	
	CATransform3D transform = CATransform3DIdentity;
	transform.m34 = -1.0 / 2000;
	
	[self.layer setTransform:transform];
}

- (void)untilt {
	if (!self.tiltEnabled && !self.highlightEnabled) {
		return;
	}
	
	[UIView animateWithDuration:.15 animations:^{
		if (self.tiltEnabled) {
			[self.layer setTransform:CATransform3DIdentity];
		}
		
		if (self.highlightEnabled) {
			[self setBackgroundColor:[UIColor clearColor]];
		}
	} completion:^(BOOL finished) {
		isTilted = NO;
		isHighlighted = NO;
	}];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
	[super touchesBegan:touches withEvent:event];
	
	if (self.tiltEnabled) {
		[self calculatePerspective];
		
		UITouch *touch = [[event allTouches] anyObject];
		CGPoint touchLocation = [touch locationInView:touch.view];
		
		float width = self.bounds.size.width, height = self.bounds.size.height;
		float x = touchLocation.x, y = touchLocation.y;
		
		float transformX = 0, transformY = 0, transformOrigX = 0, transformOrigY = 0;
		
		if (x>=0 && x <= width && y >= 0 && y <= height) {
			float angle = 7.5;
			
			CATransform3D rotateX = CATransform3DIdentity;
			CATransform3D rotateY = CATransform3DIdentity;
			
			// Set actual transform
			if (x<=(width/3)) {
				transformY = -1;
				transformOrigX = 1;
			} else if (x<=(width/3)*2 && x>(width/3)) {
				transformY = 0;
				transformOrigX = 0.5;
			} else if (x<=width && x>(width/3)*2) {
				transformY = 1;
				transformOrigX = 0;
			}
			
			if (y<=(height/3)) {
				transformX = 1;
				transformOrigY = 1;
			} else if (y<=(height/3)*2 && y>(height/3)) {
				transformX = 0;
				transformOrigY = 0.5;
			} else if (y<=height && y>(height/3)*2) {
				transformX = -1;
				transformOrigY = 0;
			}
			
			rotateX = CATransform3DRotate (self.layer.transform, deg2rad(angle), 0, transformY, 0 );
			rotateY = CATransform3DRotate(self.layer.transform, deg2rad(angle), transformX, 0, 0 );
			
			CATransform3D finalTransform;
			if (x<=(width/3)*2 && x>(width/3) && y<=(height/3)*2 && y>(height/3)) {
				transformOrigX = 0.5;
				transformOrigY = 0.5;
				finalTransform = CATransform3DScale(self.layer.transform, 0.985, 0.985, 1);
			} else {
				finalTransform = CATransform3DConcat(rotateX, rotateY);
			}
			
			[self.layer setTransform:finalTransform];
			isTilted = YES;
		}
	}
	
	if (self.highlightEnabled) {
		isHighlighted = YES;
		if (self.coloredHighlight) {
			[self setBackgroundColor:[RSAesthetics accentColor]];
		} else {
			[self setBackgroundColor:[UIColor colorWithWhite:1.0 alpha:0.2]];
		}
	}
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
	[super touchesEnded:touches withEvent:event];
	
	[self untilt];
}

- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
	[super touchesCancelled:touches withEvent:event];
	
	[self untilt];
}

- (void)setTiltEnabled:(BOOL)tiltEnabled {
	_tiltEnabled = tiltEnabled;
	
	if (!tiltEnabled && isTilted) {
		[self untilt];
	}
}

- (void)setHighlightEnabled:(BOOL)highlightEnabled {
	_highlightEnabled = highlightEnabled;
	
	if (!highlightEnabled && isHighlighted) {
		[self untilt];
	}
}

- (void)setFrame:(CGRect)frame {
	[super setFrame:frame];
	
	[self.titleLabel setFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
}

- (void)addTarget:(id)target action:(SEL)action {
	UITapGestureRecognizer* tap = [[UITapGestureRecognizer alloc] initWithTarget:target action:action];
	[self addGestureRecognizer:tap];
}

- (void)setTitle:(NSString*)title {
	[self.titleLabel setText:title];
}

- (void)setTintColor:(UIColor *)tintColor {
	[self.titleLabel setTextColor:tintColor];
}

@end
