/**
 @class RSBulletinView
 @author Sniper_GER
 @discussion A view representing a notification that is shown on a tile
 */

#import <UIKit/UIKit.h>

@class BBBulletin;

@interface RSBulletinView : UIView {
	RSTileInfo* tileInfo;
	
	UILabel* titleLabel;
	UILabel* subtitleLabel;
	UILabel* messageLabel;
	UILabel* badgeLabel;
	UIImageView* tileImage;
	UILabel* appTitle;
}

- (id)initWithFrame:(CGRect)frame bulletin:(BBBulletin*)bulletin tile:(RSTile*)tile bulletinCount:(int)bulletinCount;

- (void)setBadge:(int)badgeCount;

@end
