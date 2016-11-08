#import "RSTiltView.h"
#define DegreesToRadians(degree) degree * M_PI / 180

@implementation RSTiltView

-(id)initWithFrame:(CGRect)frame {
	self = [super initWithFrame:frame];

	if (self) {
		_transformAngle = 15.0;
		_transformMultiplierX = 1;
		_transformMultiplierY = 1;
		_hasHighlight = NO;
		_keepsHighlightOnLongPress = NO;
		_isUntilted = YES;
	}

	return self;
}

-(void)setTransformMultiplierAngle:(float)angle {
	self->_transformAngle = angle;
}
-(void)setTransformMultiplierX:(float)multiplier {
	self->_transformMultiplierX = multiplier;
}
-(void)setTransformMultiplierY:(float)multiplier {
	self->_transformMultiplierY = multiplier;
}

-(void)setTransformOptions:(NSDictionary*)options {
	if ([options objectForKey:@"transformMultiplierX"]) {
		_transformMultiplierX = [[options objectForKey:@"transformMultiplierX"] floatValue];
	}
	if ([options objectForKey:@"transformMultiplierY"]) {
		_transformMultiplierY = [[options objectForKey:@"transformMultiplierY"] floatValue];
	}
	if ([options objectForKey:@"transformAngle"]) {
		_transformAngle = [[options objectForKey:@"transformAngle"] floatValue];
	}
}

-(void)setHighlighted:(BOOL)highlighted {
	if (_hasHighlight) {
		if (highlighted) {
			[self setBackgroundColor:[UIColor colorWithWhite:1.0 alpha:0.2]];
		} else if (CGColorEqualToColor(self.backgroundColor.CGColor, [UIColor colorWithWhite:1.0 alpha:0.2].CGColor)) {
			CABasicAnimation* backgroundAnimation = [CABasicAnimation animationWithKeyPath:@"backgroundColor"];

			backgroundAnimation.fromValue = (id)[UIColor colorWithWhite:1.0 alpha:0.2].CGColor;
			backgroundAnimation.duration = 0.15f;
			backgroundAnimation.cumulative = YES;
			backgroundAnimation.repeatCount = 1;
			backgroundAnimation.fillMode = kCAFillModeForwards;
			backgroundAnimation.removedOnCompletion = NO;

			[self.layer addAnimation:backgroundAnimation forKey:@"backgroundAnimation"];
			[self setBackgroundColor:[UIColor colorWithWhite:0.0 alpha:0.0]];
		}
	}
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
	[super touchesBegan:touches withEvent:event];

	if (_hasHighlight) {
		self.backgroundColor = [UIColor colorWithWhite:1.0 alpha: 0.2];
	}

	UITouch *touch = [[event allTouches] anyObject];
	CGPoint touchLocation = [touch locationInView:touch.view];

	[self calculatePerspective];

	[self.layer removeAllAnimations];

	float width = self.frame.size.width, height = self.frame.size.height;
	float x = touchLocation.x, y = touchLocation.y;
	
	float transformX = 0, transformY = 0, transformOrigX = 0, transformOrigY = 0;

	if (x>=0 && x <= width && y >= 0 && y <= height) {
		float angleX = _transformAngle*_transformMultiplierX;
		float angleY = _transformAngle*_transformMultiplierY;
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

		rotateX = CATransform3DRotate (_layerTransform, DegreesToRadians(angleX), 0, transformY, 0 );
		
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

		rotateY = CATransform3DRotate(_layerTransform, DegreesToRadians(angleY), transformX, 0, 0 );
		
		if (x<=(width/3)*2 && x>(width/3) && y<=(height/3)*2 && y>(height/3)) {
			transformOrigX = 0.5;
			transformOrigY = 0.5;
			_layerTransform = CATransform3DScale(_layerTransform, 0.985, 0.985, 1);
		} else {
			_layerTransform = CATransform3DConcat(rotateX, rotateY);
		}

		CABasicAnimation* rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform"];

		rotationAnimation.fromValue = [NSValue valueWithCATransform3D:CATransform3DIdentity];
		rotationAnimation.duration = 0.05f;
		rotationAnimation.cumulative = YES;
		rotationAnimation.repeatCount = 1;
		rotationAnimation.fillMode = kCAFillModeForwards;
		rotationAnimation.removedOnCompletion = NO;

		[self.layer addAnimation:rotationAnimation forKey:@"tiltAnimation"];
		
		[self.layer setTransform:_layerTransform];
		self.layer.allowsEdgeAntialiasing = YES;

		// Set Transform Origin
		[self setAnchorPoint:CGPointMake(transformOrigX,transformOrigY) forView:self];
		
		_isUntilted = NO;
	}
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
	[super touchesEnded:touches withEvent:event];

	[self untilt:YES];
}

-(void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesCancelled:touches withEvent:event];

    [self untilt:YES];
    [self setHighlighted:NO];
}

-(void)untilt:(BOOL)animated {

	if (animated && !_isUntilted) {
		CABasicAnimation* rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform"];

		rotationAnimation.fromValue = [NSValue valueWithCATransform3D:_layerTransform];
		rotationAnimation.duration = animated ? 0.15f : 0.0f;
		rotationAnimation.cumulative = YES;
		rotationAnimation.repeatCount = 1;
		rotationAnimation.fillMode = kCAFillModeForwards;
		rotationAnimation.removedOnCompletion = NO;

		[self.layer addAnimation:rotationAnimation forKey:@"resetAnimation"];
	}

	if (_hasHighlight && !_keepsHighlightOnLongPress) {
		if (animated) {
			CABasicAnimation* backgroundAnimation = [CABasicAnimation animationWithKeyPath:@"backgroundColor"];

			backgroundAnimation.fromValue = (id)[UIColor colorWithWhite:1.0 alpha:0.2].CGColor;
			backgroundAnimation.duration = animated ? 0.15f : 0.0f;
			backgroundAnimation.cumulative = YES;
			backgroundAnimation.repeatCount = 1;
			backgroundAnimation.fillMode = kCAFillModeForwards;
			backgroundAnimation.removedOnCompletion = NO;

			[self.layer addAnimation:backgroundAnimation forKey:@"backgroundAnimation"];
		}
		[self setBackgroundColor:[UIColor colorWithWhite:0.0 alpha:0.0]];
	}

	[self.layer setTransform:CATransform3DIdentity];
	_isUntilted = YES;
}

-(void)setAnchorPoint:(CGPoint)anchorPoint forView:(UIView *)view {
	CGPoint newPoint = CGPointMake(view.bounds.size.width * anchorPoint.x,
								   view.bounds.size.height * anchorPoint.y);
	CGPoint oldPoint = CGPointMake(view.bounds.size.width * view.layer.anchorPoint.x,
								   view.bounds.size.height * view.layer.anchorPoint.y);
	
	newPoint = CGPointApplyAffineTransform(newPoint, view.transform);
	oldPoint = CGPointApplyAffineTransform(oldPoint, view.transform);
	
	CGPoint position = view.layer.position;
	
	position.x -= oldPoint.x;
	position.x += newPoint.x;
	
	position.y -= oldPoint.y;
	position.y += newPoint.y;
	
	view.layer.position = position;
	view.layer.anchorPoint = anchorPoint;
}

-(void)calculatePerspective {
	[self.layer setShouldRasterize:YES];
	self.layer.rasterizationScale = [[UIScreen mainScreen] scale];
	self.layer.contentsScale = [[UIScreen mainScreen] scale];

	_layerTransform = CATransform3DIdentity;
	_layerTransform.m34 = -1.0 / 2000;
}

@end