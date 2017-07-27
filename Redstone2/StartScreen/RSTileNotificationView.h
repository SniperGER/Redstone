/**
 @class RSTileNotificationView
 @author Sniper_GER
 @discussion A view container that shows notifications on tiles
 */

#import <UIKit/UIKit.h>

@class BBServer, BBBulletin, RSBulletinView;
@protocol RSLiveTileInterface;

@interface RSTileNotificationView : UIView <RSLiveTileInterface> {
	NSString* sectionIdentifier;
	BBServer* bulletinServer;
	
	RSBulletinView* currentNotificationView;
	RSBulletinView* nextNotificationView;
	UILabel* currentNotificationBadge;
	
	BOOL canAddBulletin;
	BOOL canRemoveBulletin;
}

@property (nonatomic, strong) RSTile* tile;
@property (nonatomic, assign) BOOL started;
@property (nonatomic, strong) NSMutableArray* bulletins;

//- (UIView*)viewWithBulletin:(BBBulletin*)bulletin;

- (void)addBulletin:(BBBulletin*)bulletin delayIncomingBulletins:(BOOL)delayBulletins;

- (void)removeBulletin:(BBBulletin*)bulletin;

- (void)setBadge:(int)badgeCount;

@end
