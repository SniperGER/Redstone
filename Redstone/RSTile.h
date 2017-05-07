#import <UIKit/UIKit.h>

@class SBIcon;

@interface RSTile : UIView {
	CGPoint centerOffset;
	SBIcon* _icon;
	UILabel* tileLabel;
}

@property (nonatomic, strong) SBIcon* icon;

- (id)initWithFrame:(CGRect)frame leafIdentifier:(NSString*)leafId size:(int)tileSize;
- (CGRect)positionWithoutTransform;

@end
