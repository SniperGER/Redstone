#import <Foundation/Foundation.h>
#import "RSTile.h"

@protocol RSLiveTileDelegate <NSObject>

@required
@property (nonatomic, retain) RSTile* tile;

- (id)initWithFrame:(CGRect)frame;
- (BOOL)isReadyForDisplay;
- (BOOL)hasMultiplePages;
- (BOOL)allowsRemovalOfSubviews;
- (CGFloat)tileUpdateInterval;
- (void)prepareForUpdate;
- (NSArray*)viewsForSize:(int)size;

- (void)requestStop;

@end
