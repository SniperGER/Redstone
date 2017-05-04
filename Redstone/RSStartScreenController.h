#import <Foundation/Foundation.h>

@class RSStartScrollView;

@interface RSStartScreenController : NSObject {
	RSStartScrollView* _startScrollView;
}

@property (nonatomic, retain) RSStartScrollView* startScrollView;

@end
