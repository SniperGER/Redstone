#import <UIKit/UIKit.h>
#import "RSTiltView.h"

@interface RSAppListSection : UIView {
	NSString* displayName;
	double yCoordinate;
	RSTiltView* innerView;
	UIImageView* bgImage;
}

-(id)initWithFrame:(CGRect)frame letter:(NSString*)letter;
-(NSString *)displayName;
-(void)setYCoordinate:(double)y;
-(double)yCoordinate;
-(void)updatePreferences;

@end