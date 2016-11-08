#import <UIKit/UIKit.h>
#import "CommonHeaders.h"

@interface RSJumpList : UIView {
	UIScrollView* alphabetScrollView;
	BOOL isOpen;
}

-(void)animateIn;
-(void)animateOut;
-(void)jumpToLetter:(id)sender;

@end