#import <UIKit/UIKit.h>

@class BBServer, BBBulletin, RSTile;

@interface RSTileNotificationView : UIView {
	NSString* sectionIdentifier;
	
	BBServer* bulletinServer;
	NSMutableArray* bulletins;
	
	UIView* currentNotificationView;
	UIView* nextNotificationView;
	
	BOOL canAddBulletin;
	BOOL canRemoveBulletin;
}

@property (nonatomic, retain) RSTile* tile;

- (id)initWithFrame:(CGRect)frame sectionIdentifier:(NSString*)section;
- (void)addBulletin:(BBBulletin *)bulletin delayIncomingBulletins:(BOOL)delay;
- (void)removeBulletin:(BBBulletin*)bulletin;

- (BOOL)readyForDisplay;

@end
