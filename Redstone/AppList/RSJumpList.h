#import <UIKit/UIKit.h>

@interface RSJumpList : UIView {
	UIScrollView* alphabetScrollView;
	BOOL _isOpen;
}

@property (nonatomic, assign) BOOL isOpen;

- (void)animateIn;
- (void)animateOut;

@end
