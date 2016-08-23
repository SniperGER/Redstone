#import <UIKit/UIKit.h>

@interface RSTiltButton : UIView <UILongPressGestureRecognizerDelegate> {
    UIView* _innerView;
    BOOL hasTransformed;
}

@property (retain) UIView* innerView;

-(void)resetTransform;

@end
