#import <UIKit/UIKit.h>

@interface RSTiltView : UIView {
	BOOL _isTilted;
	BOOL _tiltEnabled;
}

@property (nonatomic, assign) BOOL isTilted;
@property (nonatomic, assign) BOOL tiltEnabled;
@property (nonatomic, assign) BOOL highlightEnabled;

- (void)calculatePerspective;
- (void)untilt;

@end
