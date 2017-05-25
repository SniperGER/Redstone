#import <UIKit/UIKit.h>

@interface RSApp : RSTiltView <UIGestureRecognizerDelegate> {
	UILabel* appLabel;
	UIImageView* appImageView;
	
	UITapGestureRecognizer* tapGestureRecognizer;
	UILongPressGestureRecognizer* longPressGestureRecognizer;
}

@property (nonatomic, retain) SBLeafIcon* icon;

- (id)initWithFrame:(CGRect)frame leafIdentifier:(NSString*)leafId;

@end
