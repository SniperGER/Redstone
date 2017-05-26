#import <UIKit/UIKit.h>

@interface RSTiltView : UIView

@property (nonatomic, retain, readonly) UILabel* titleLabel;
@property (nonatomic, assign) BOOL isTilted;
@property (nonatomic, assign) BOOL tiltEnabled;
@property (nonatomic, assign) BOOL highlightEnabled;
@property (nonatomic, assign) BOOL coloredHighlight;

- (void)calculatePerspective;
- (void)untilt;

- (void)addTarget:(id)target action:(SEL)action;

- (void)setTitle:(NSString*)title;
- (void)setTintColor:(UIColor *)tintColor;

@end
