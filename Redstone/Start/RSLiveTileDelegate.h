#import <Foundation/Foundation.h>

@protocol RSLiveTileDelegate <NSObject>

@required
- (BOOL)keepsLiveTilePage;
- (NSInteger)liveTilePages;
- (void)prepareForUpdate;

@end
