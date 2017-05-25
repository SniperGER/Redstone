#import <UIKit/UIKit.h>

@interface RSJumpList : UIView {
	UIScrollView* alphabetScrollView;
}

@property (nonatomic, assign) BOOL isOpen;

- (void)animateIn;
- (void)animateOut;

@end
