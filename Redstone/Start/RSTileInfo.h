#import <Foundation/Foundation.h>

@interface RSTileInfo : NSObject {
	NSBundle* tileBundle;
}

@property (nonatomic, assign, readonly) BOOL fullSizeArtwork;
@property (nonatomic, assign, readonly) BOOL tileHidesLabel;
@property (nonatomic, assign, readonly) BOOL usesCornerBadge;
@property (nonatomic, assign, readonly) BOOL hasColoredIcon;
@property (nonatomic, readonly) NSString* displayName;
@property (nonatomic, readonly) NSString* localizedDisplayName;
@property (nonatomic, readonly) NSString* accentColor;
@property (nonatomic, readonly) NSString* tileAccentColor;
@property (nonatomic, readonly) NSString* launchScreenAccentColor;
@property (nonatomic, readonly) NSDictionary* labelHiddenForSizes;
@property (nonatomic, readonly) NSDictionary* cornerBadgeForSizes;

- (id)initWithBundleIdentifier:(NSString*)bundleIdentifier;

@end
