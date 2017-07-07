#import <UIKit/UIKit.h>

@class SBLeafIcon;

@interface SBIconModel : NSObject

- (SBLeafIcon*)leafIconForIdentifier:(NSString*)arg1;
- (void)removeIconForIdentifier:(id)arg1;
- (id)visibleIconIdentifiers;

@end
