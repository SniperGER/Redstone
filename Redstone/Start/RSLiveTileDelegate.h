#import <Foundation/Foundation.h>

@protocol RSLiveTileDelegate <NSObject>

@required
- (BOOL)isReadyForShow;
- (BOOL)keepsLiveTilePage;
- (NSInteger)liveTilePages;
- (CGFloat)tileUpdateInterval;
- (void)prepareForUpdate;

@end
