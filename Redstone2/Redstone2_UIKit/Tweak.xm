#import <objcipc/objcipc.h>

%ctor {
	[[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationDidBecomeActiveNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *notification) {
		if([[notification.object class] isSubclassOfClass:[%c(SpringBoard) class]]) {
			return;
		}
		
		[OBJCIPC sendMessageToSpringBoardWithMessageName:@"Redstone.Application.BecameActive" dictionary:nil];
	}];
}
