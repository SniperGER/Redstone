#import <UIKit/UIKit.h>

@interface RSTiltView : UIView

@property (nonatomic, assign) BOOL isTilted;
@property (nonatomic, assign) BOOL tiltEnabled;
@property (nonatomic, assign) BOOL highlightEnabled;
@property (nonatomic, assign) BOOL coloredHighlight;

- (void)calculatePerspective;
- (void)untilt;

@end
