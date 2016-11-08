#import <UIKit/UIKit.h>
#import "CommonHeaders.h"

@class RSApp;

@interface RSPinMenu : UIView {
	RSApp* appIcon;
}

-(id)initWithFrame:(CGRect)frame app:(RSApp*)app;
-(void)pinApp:(id)sender;
-(void)playOpeningAnimation:(BOOL)comesFromTop;

@end