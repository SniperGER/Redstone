/**
 @class RSLiveTileInterface
 @author Sniper_GER
 @discussion The interface of a Live TIle describing all required and optional methods
 */

#import <UIKit/UIKit.h>

@class RSTile;

@protocol RSLiveTileInterface <NSObject>

@required
@property (nonatomic, strong) RSTile* tile;
@property (nonatomic, assign) BOOL started;

- (id)initWithFrame:(CGRect)frame tile:(RSTile*)tile;
- (NSArray*)viewsForSize:(int)size;
- (BOOL)readyForDisplay;
- (CGFloat)updateInterval;
- (void)update;

@optional
- (void)triggerAnimation;
- (void)prepareForRemoval;
- (void)hasStarted;
- (void)hasStopped;

@end
