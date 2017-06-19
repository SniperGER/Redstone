#import <UIKit/UIKit.h>

@class RSTiltView, RSTileInfo;

@interface RSApp : RSTiltView <UIGestureRecognizerDelegate> {
	UILabel* appLabel;
	UIImageView* appImageView;
	
	UITapGestureRecognizer* tapGestureRecognizer;
	UILongPressGestureRecognizer* longPressGestureRecognizer;
}

@property (nonatomic, strong) SBLeafIcon* icon;
@property (nonatomic, strong) NSString* iconIdentifier;
@property (nonatomic, strong) RSTileInfo* tileInfo;

- (id)initWithFrame:(CGRect)frame leafIdentifier:(NSString*)leafId;

@end
