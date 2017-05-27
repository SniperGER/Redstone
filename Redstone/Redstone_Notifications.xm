#import "Redstone.h"
#import "substrate.h"

%group ios10

id traverseResponderChainForUIViewController(id target) {
	id nextResponder = [target nextResponder];
	if ([nextResponder isKindOfClass:[UIViewController class]]) {
		return nextResponder;
	} else if ([nextResponder isKindOfClass:[UIView class]]) {
		return traverseResponderChainForUIViewController(nextResponder);
	} else {
		return nil;
	}
}

%hook NCNotificationShortLookView

- (void)setFrame:(CGRect)frame {
	if (![self isNCNotification]) {
		frame = CGRectMake(-8, -8, screenWidth, frame.size.height);
		%orig(frame);
	} else {
		%orig(frame);
	}
}

- (void)layoutSubviews {
	BOOL isNCNotification = [self isNCNotification];
	for (UIView* subview in self.subviews) {
		if ([subview isKindOfClass:%c(RSNotificationView)] && isNCNotification) {
			[subview removeFromSuperview];
		}
		[subview setHidden:!isNCNotification];
	}
	
	if (!isNCNotification) {
		NCNotificationShortLookViewController* viewController = traverseResponderChainForUIViewController(self);
		BBBulletin* bulletin = [[viewController notificationRequest] bulletin];
		
		RSNotificationView* notificationView = [[RSNotificationView alloc] notificationForBulletin:bulletin isStatic:YES];
		[self addSubview:notificationView];
	}
	
	%orig;
}

%new
- (BOOL)isNCNotification {
	UIView* view = self;
	BOOL canProceed = NO;
	
	while (view.superview) {
		if ([view.superview isKindOfClass:%c(NCNotificationListCollectionView)]) {
			canProceed = YES;
			break;
		}
		
		view = view.superview;
	}
	
	return canProceed;
}

%end // %hook NCNotificationShortLookView

%end // %group ios10

%group ios9

%hook SBBannerContextView

- (void)layoutSubviews {
	for (UIView* subview in self.subviews) {
		if ([subview isKindOfClass:%c(RSNotificationView)]) {
			[subview removeFromSuperview];
		}
		[subview setHidden:YES];
	}
	
	BBBulletin* bulletin =  [[MSHookIvar<SBUIBannerContext*>(self,"_context") item] seedBulletin];
	RSNotificationView* notificationView = [[RSNotificationView alloc] notificationForBulletin:bulletin isStatic:YES];
	[self addSubview:notificationView];
	
	%orig;
}

%end // %hook SBBannerContextView

%end // %group ios9

%ctor {
	NSDictionary* settings = [NSDictionary dictionaryWithContentsOfFile:PREFERENCES_PATH];
	
	if ([[settings objectForKey:@"enabled"] boolValue] && [[settings objectForKey:@"notificationsEnabled"] boolValue]) {
		NSLog(@"[Redstone] Initializing Notifications");
		
		if (kCFCoreFoundationVersionNumber > kCFCoreFoundationVersionNumber_iOS_9_x_Max) {
			%init(ios10)
		} else if (kCFCoreFoundationVersionNumber > kCFCoreFoundationVersionNumber_iOS_8_x_Max) {
			%init(ios9);
		}
	}
}
