#import <Foundation/Foundation.h>


@protocol RSLiveTileDelegate <NSObject>

@required
@property (nonatomic, retain) RSTile* tile;

- (BOOL)isReadyForShow;
- (BOOL)keepsLiveTilePage;
- (BOOL)hasMultiplePages;
- (CGFloat)tileUpdateInterval;
- (void)prepareForUpdate;
- (NSArray*)viewsForSize:(int)size;

@end
