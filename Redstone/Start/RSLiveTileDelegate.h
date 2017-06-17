#import <Foundation/Foundation.h>

@protocol RSLiveTileDelegate <NSObject>

@required
@property (nonatomic, strong) RSTile* tile;

- (id)initWithFrame:(CGRect)frame tile:(RSTile*)tile;
- (void)update;
- (BOOL)readyForDisplay;
- (NSArray*)viewsForSize:(int)size;
- (CGFloat)updateInterval;

@end
