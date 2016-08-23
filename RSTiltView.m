#import "RSTiltView.h"
#define DegreesToRadians(degree) degree * M_PI / 180

@implementation RSTiltView

-(id)initWithFrame:(CGRect)frame {
	self = [super initWithFrame:frame];

    self.transformAngle = 15.0;
    _transformMultiplierX = 1;
    _transformMultiplierY = 1;

    /*UILongPressGestureRecognizer *gesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(touchesBegan:)];
    gesture.minimumPressDuration = 0.f;
    gesture.cancelsTouchesInView = NO;
    [self addGestureRecognizer:gesture];*/

    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapped:)];
    tapGesture.cancelsTouchesInView = NO;
    [self addGestureRecognizer:tapGesture];

    UILongPressGestureRecognizer *pressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(pressed:)];
    pressGesture.cancelsTouchesInView = NO;
    pressGesture.minimumPressDuration = 1.0;
    [self addGestureRecognizer:pressGesture];

    self.hasHighlight = NO;

	return self;
}

-(void)tapped:(UITapGestureRecognizer*)sender {
    if (targetForTapped && actionForTapped) {
        [targetForTapped performSelector:actionForTapped withObject:self];
    }
}

-(void)pressed:(UILongPressGestureRecognizer*)sender {
    if (sender.state == UIGestureRecognizerStateBegan && targetForPressed && actionForPressed) {
        [targetForPressed performSelector:actionForPressed withObject:self];
    }
}

-(void)setActionForTapped:(SEL)newActionForTapped forTarget:(id)target {
    if (target && newActionForTapped) {
        targetForTapped = target;
        actionForTapped = newActionForTapped;
    }
}
-(void)setActionForPressed:(SEL)newActionForPressed forTarget:(id)target {
    if (target && newActionForPressed) {
        targetForPressed = target;
        actionForPressed = newActionForPressed;
    }
}

-(void)setHighlighted:(BOOL)highlighted {
    if (highlighted) {
        [self setBackgroundColor:[UIColor colorWithWhite:1.0 alpha:0.2]];
    } else {
        [self setBackgroundColor:[UIColor colorWithWhite:0.0 alpha:0.0]];
    }
}


-(void)setTransformOptions:(NSDictionary*)options {
    if ([options objectForKey:@"transformMultiplierX"]) {
        _transformMultiplierX = [[options objectForKey:@"transformMultiplierX"] floatValue];
    }
    if ([options objectForKey:@"transformMultiplierY"]) {
        _transformMultiplierY = [[options objectForKey:@"transformMultiplierY"] floatValue];
    }
    if ([options objectForKey:@"transformAngle"]) {
        self.transformAngle = [[options objectForKey:@"transformAngle"] floatValue];
    }
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
//- (void)touchesBegan:(UIGestureRecognizer*)gestureRecognizer {
	[super touchesBegan:touches withEvent:event];

    //if (gestureRecognizer.state == UIGestureRecognizerStateBegan) {
    if (self.hasHighlight) {
        self.backgroundColor = [UIColor colorWithWhite:1.0 alpha: 0.2];
    }

	UITouch *touch = [[event allTouches] anyObject];
    CGPoint touchLocation = [touch locationInView:touch.view];
    //CGPoint touchLocation = [gestureRecognizer locationInView:self];

    [self calculatePerspective];

    [self.layer removeAllAnimations];

    float width = self.frame.size.width, height = self.frame.size.height;
    float x = touchLocation.x, y = touchLocation.y;
    
    float transformX = 0, transformY = 0, transformOrigX = 0, transformOrigY = 0;

    if (x>=0 && x <= width && y >= 0 && y <= height) {
        float angleX = self.transformAngle*_transformMultiplierX;
        float angleY = self.transformAngle*_transformMultiplierY;
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
    }
    //}
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesEnded:touches withEvent:event];

    [self untilt:YES];
}

-(void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesCancelled:touches withEvent:event];

    [self untilt:NO];
}

-(void)untilt:(BOOL)animated {
    [self untilt:animated overridesHighlight:NO];
}

-(void)untilt:(BOOL)animated overridesHighlight:(BOOL)highlightOverride {

    if (animated) {
        CABasicAnimation* rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform"];

        rotationAnimation.fromValue = [NSValue valueWithCATransform3D:_layerTransform];
        rotationAnimation.duration = animated ? 0.15f : 0.0f;
        rotationAnimation.cumulative = YES;
        rotationAnimation.repeatCount = 1;
        rotationAnimation.fillMode = kCAFillModeForwards;
        rotationAnimation.removedOnCompletion = NO;

        [self.layer addAnimation:rotationAnimation forKey:@"resetAnimation"];
    }

    if (self.hasHighlight && !highlightOverride) {
        if (animated) {
            CABasicAnimation* backgroundAnimation = [CABasicAnimation animationWithKeyPath:@"backgroundColor"];

            backgroundAnimation.fromValue = (id)[UIColor colorWithWhite:1.0 alpha:0.1].CGColor;
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