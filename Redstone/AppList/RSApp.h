#import <UIKit/UIKit.h>

@class RSTiltView, RSTileInfo;

@interface RSApp : RSTiltView <UIGestureRecognizerDelegate> {
	UILabel* appLabel;
	UIImageView* appImageView;
	
	UITapGestureRecognizer* tapGestureRecognizer;
	UILongPressGestureRecognizer* longPressGestureRecognizer;
}

@property (nonatomic, retain) SBLeafIcon* icon;
@property (nonatomic, retain) RSTileInfo* tileInfo;

- (id)initWithFrame:(CGRect)frame leafIdentifier:(NSString*)leafId;

@end
