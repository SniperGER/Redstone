#import <UIKit/UIKit.h>
#import "RSLiveTileDelegate.h"

@class BBServer, BBBulletin, RSTile;

@interface RSTileNotificationView : UIView <RSLiveTileDelegate> {
	NSString* sectionIdentifier;
	
	BBServer* bulletinServer;
	NSMutableArray* bulletins;
	
	UIView* currentNotificationView;
	UIView* nextNotificationView;
	
	BOOL canAddBulletin;
	BOOL canRemoveBulletin;
}

@property (nonatomic, strong) RSTile* tile;

- (void)addBulletin:(BBBulletin *)bulletin delayIncomingBulletins:(BOOL)delay;
- (void)removeBulletin:(BBBulletin*)bulletin;

@end
