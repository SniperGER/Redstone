#import <Foundation/Foundation.h>

@interface RSTile : UIView

- (void)setLiveTileHidden:(BOOL)hidden;
- (void)setLiveTileHidden:(BOOL)hidden animated:(BOOL)animated;

@end

@protocol RSLiveTileDelegate <NSObject>

@required
@property (nonatomic, strong) RSTile* tile;

- (id)initWithFrame:(CGRect)frame tile:(RSTile*)tile;
- (void)update;
- (BOOL)readyForDisplay;
- (NSArray*)viewsForSize:(int)size;
- (CGFloat)updateInterval;

@end
