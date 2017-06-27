#import "../Redstone.h"

@implementation RSNotificationController

static RSNotificationController* sharedInstance;

+ (id)sharedInstance {
	return sharedInstance;
}

- (id)init {
	if (self = [super init]) {
		sharedInstance = self;
		
		notificationWindow = [[RSNotificationWindow alloc] initWithFrame:CGRectMake(0, 0, screenWidth, 130)];
	}
	
	return self;
}

- (void)addBulletin:(BBBulletin *)bulletin {
	NSLog(@"[Redstone | RSNotificationController] bulletin added");
	
	dispatch_async(dispatch_get_main_queue(), ^{
		if ([RSSoundController sharedInstance] && [[RSSoundController sharedInstance] isShowingVolumeHUD]) {
			[[RSSoundController sharedInstance] hideVolumeHUDAnimated:YES];
		}
		
		if (![notificationWindow isKeyWindow]) {
			[notificationWindow makeKeyAndVisible];
		}
	
		RSNotificationView* notification = [[RSNotificationView alloc] initForBulletin:bulletin];
		[notificationWindow addSubview:notification];
		[notification animateIn];
		[notification resetSlideOutTimer];
	});
}

- (void)removeBulletin:(RSNotificationView*)bulletin {
	[bulletin removeFromSuperview];
	
	if (notificationWindow.subviews.count < 1) {
		[notificationWindow setHidden:YES];
	}
}

- (void)removeAllBulletins {
	for (RSNotificationView* notification in notificationWindow.subviews) {
		[notification stopSlideOutTimer];
		[notification animateOut];
	}
}

@end
