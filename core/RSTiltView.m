#import "../RedstoneHeaders.h"
#define DegreesToRadians(degree) degree * M_PI / 180

@implementation RSTiltView

- (id)initWithFrame:(CGRect)frame {
	self = [super initWithFrame:frame];

	if (self) {
		self->transformAngle = 15.0;
		self->transformMultiplierX = 1;
		self->transformMultiplierY = 1;
		self->hasHighlight = NO;
		self->keepsHighlightOnLongPress = NO;
		self->isUntilted = YES;
	}
	
	return self;
}

- (void)setTransformOptions:(NSDictionary*)options {
	if ([options objectForKey:@"transformMultiplierX"]) {
		self->transformMultiplierX = [[options objectForKey:@"transformMultiplierX"] floatValue];
	}
	if ([options objectForKey:@"transformMultiplierY"]) {
		self->transformMultiplierY = [[options objectForKey:@"transformMultiplierY"] floatValue];
	}
	if ([options objectForKey:@"transformAngle"]) {
		self->transformAngle = [[options objectForKey:@"transformAngle"] floatValue];
	}
}

- (void)calculatePerspective {
	[self.layer setShouldRasterize:YES];
	self.layer.rasterizationScale = [[UIScreen mainScreen] scale];
	self.layer.contentsScale = [[UIScreen mainScreen] scale];

	self->layerTransform = CATransform3DIdentity;
	self->layerTransform.m34 = -1.0 / 2000;
}

- (void)setAnchorPoint:(CGPoint)anchorPoint forView:(UIView *)view {
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

- (void)untilt:(BOOL)animated {

	if (animated && !self->isUntilted) {
		CABasicAnimation* rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform"];

		rotationAnimation.fromValue = [NSValue valueWithCATransform3D:self->layerTransform];
		rotationAnimation.duration = animated ? 0.15f : 0.0f;
		rotationAnimation.cumulative = YES;
		rotationAnimation.repeatCount = 1;
		rotationAnimation.fillMode = kCAFillModeForwards;
		rotationAnimation.removedOnCompletion = NO;

		[self.layer addAnimation:rotationAnimation forKey:@"resetAnimation"];
	}

	if (self->hasHighlight && !self->keepsHighlightOnLongPress) {
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
	self->isUntilted = YES;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
	[super touchesBegan:touches withEvent:event];

	UITouch *touch = [[event allTouches] anyObject];
	CGPoint touchLocation = [touch locationInView:touch.view];

	[self calculatePerspective];

	[self.layer removeAllAnimations];

	float width = self.frame.size.width, height = self.frame.size.height;
	float x = touchLocation.x, y = touchLocation.y;
	
	float transformX = 0, transformY = 0, transformOrigX = 0, transformOrigY = 0;

	if (x>=0 && x <= width && y >= 0 && y <= height) {
		float angleX = self->transformAngle*self->transformMultiplierX;
		float angleY = self->transformAngle*self->transformMultiplierY;
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

		rotateX = CATransform3DRotate (self->layerTransform, DegreesToRadians(angleX), 0, transformY, 0 );
		
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

		rotateY = CATransform3DRotate(self->layerTransform, DegreesToRadians(angleY), transformX, 0, 0 );
		
		if (x<=(width/3)*2 && x>(width/3) && y<=(height/3)*2 && y>(height/3)) {
			transformOrigX = 0.5;
			transformOrigY = 0.5;
			self->layerTransform = CATransform3DScale(self->layerTransform, 0.985, 0.985, 1);
		} else {
			self->layerTransform = CATransform3DConcat(rotateX, rotateY);
		}

		CABasicAnimation* rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform"];

		rotationAnimation.fromValue = [NSValue valueWithCATransform3D:CATransform3DIdentity];
		rotationAnimation.duration = 0.05f;
		rotationAnimation.cumulative = YES;
		rotationAnimation.repeatCount = 1;
		rotationAnimation.fillMode = kCAFillModeForwards;
		rotationAnimation.removedOnCompletion = NO;

		[self.layer addAnimation:rotationAnimation forKey:@"tiltAnimation"];
		
		[self.layer setTransform:self->layerTransform];
		self.layer.allowsEdgeAntialiasing = YES;

		// Set Transform Origin
		[self setAnchorPoint:CGPointMake(transformOrigX,transformOrigY) forView:self];
		
		self->isUntilted = NO;
	}
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
	[super touchesEnded:touches withEvent:event];

	[self untilt:YES];
}

-(void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
	[super touchesCancelled:touches withEvent:event];

	[self untilt:YES];
}

@end
