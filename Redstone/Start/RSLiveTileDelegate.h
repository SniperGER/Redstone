#import <Foundation/Foundation.h>
#import "RSTile.h"

@protocol RSLiveTileDelegate <NSObject>

@required
@property (nonatomic, retain) RSTile* tile;
@property (nonatomic, assign) BOOL started;

- (id)initWithFrame:(CGRect)frame;
- (BOOL)readyForDisplay;
- (BOOL)hasAsyncLoading;
- (BOOL)hasMultiplePages;
- (BOOL)allowsRemovalOfSubviews;
- (CGFloat)tileUpdateInterval;
- (void)prepareForUpdate;
- (NSArray*)viewsForSize:(int)size;

- (void)requestStop;

@optional
- (void)triggerAnimation;

@end
