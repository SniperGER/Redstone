#import "Headers.h"
#import <QuartzCore/QuartzCore.h>
#define DegreesToRadians(degree) degree * M_PI / 180

@implementation RSTiltButton

-(id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    //[self addSubview:self.innerView];
    
    UILongPressGestureRecognizer *gesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(setButtonTransform:)];
    gesture.minimumPressDuration = 0.f;
    gesture.cancelsTouchesInView = NO;
    [self addGestureRecognizer:gesture];
    gesture.delegate = self;
    
    return self;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return YES;
}

//- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
- (void)setButtonTransform:(UILongPressGestureRecognizer *)gestureRecognizer {
    CGPoint touchLocation = [gestureRecognizer locationInView:self];
    /*UITouch *touch = [[event allTouches] anyObject];
    CGPoint touchLocation = [touch locationInView:self];*/
    
    float width = self.frame.size.width, height = self.frame.size.height;
    float x = touchLocation.x, y = touchLocation.y;
    
    float transformX = 0, transformY = 0, transformOrigX = 0, transformOrigY = 0;
    
    if (x>=0 && x <= width && y >= 0 && y <= height && !hasTransformed) {
        hasTransformed = YES;
        CATransform3D trans = CATransform3DIdentity;
        trans.m34 = 1.0 / -2000;
        
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
        
        if (x<=(width/3)*2 && x>(width/3) && y<=(height/3)*2 && y>(height/3)) {
            transformOrigX = 0.5;
            transformOrigY = 0.5;
            trans = CATransform3DScale(trans, 0.98, 0.98, 1);
        } else {
            trans = CATransform3DRotate (trans, DegreesToRadians(8), transformX, transformY, 0 );
        }
        
        [self.layer setTransform:trans];
        self.layer.allowsEdgeAntialiasing = YES;
        
        // Set Transform Origin
        [self setAnchorPoint:CGPointMake(transformOrigX,transformOrigY) forView:self];
    }
}

-(void)setAnchorPoint:(CGPoint)anchorPoint forView:(UIView *)view
{
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

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    //[self resetTransform];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    [self resetTransform];
}

-(void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    hasTransformed = NO;
    [self resetTransform];
}

-(void)resetTransform {
    [self.layer setTransform:CATransform3DIdentity];
    [self.layer setAnchorPoint:CGPointMake(0.5,0.5)];
    [self setCenter:CGPointMake(self.frame.size.width/2, self.frame.size.height/2)];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        hasTransformed = NO;
    });
}

@end
