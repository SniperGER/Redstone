#import "Redstone.h"

@implementation RSCore

static RSCore* sharedInstance;

+ (id)sharedInstance {
	return sharedInstance;
}

+ (void)hideAllExcept:(id)objectToShow {
	if (objectToShow) {
		[objectToShow setHidden:NO];
	}
	
	for (UIView* view in [[[objc_getClass("SBUIController") sharedInstance] window] subviews]) {
		if ([view isKindOfClass:[RSRootScrollView class]]) {
			[view setHidden:NO];
		} else if (view != objectToShow) {
			[view setHidden:YES];
		}
	}
}

+ (void)showAllExcept:(id)objectToHide {
	if (objectToHide) {
		[objectToHide setHidden:YES];
	}
	
	for (UIView* view in [[[objc_getClass("SBUIController") sharedInstance] window] subviews]) {
		if ([view isKindOfClass:[RSRootScrollView class]]) {
			[view setHidden:YES];
		} else if (view != objectToHide) {
			[view setHidden:NO];
		}
	}
}



- (id)initWithWindow:(id)window {
	self = [super init];
	
	if (self) {
		sharedInstance = self;
		self->_window = window;
		
		self.rootScrollView = [[RSRootScrollView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, screenHeight)];
		[self->_window addSubview:self.rootScrollView];
		
		self.startScreenController = [RSStartScreenController new];
		[self.rootScrollView addSubview:self.startScreenController.startScrollView];
	}
	
	return self;
}

@end
