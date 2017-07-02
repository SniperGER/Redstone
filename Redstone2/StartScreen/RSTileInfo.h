/**
 @class RSTileInfo
 @author Sniper_GER
 @discussion A class that describes various properties of a tile
 */

#import <Foundation/Foundation.h>

@interface RSTileInfo : NSObject {
	NSBundle* tileBundle;
}

@property (nonatomic, assign, readonly) BOOL fullSizeArtwork;
@property (nonatomic, assign, readonly) BOOL tileHidesLabel;
@property (nonatomic, assign, readonly) BOOL usesCornerBadge;
@property (nonatomic, assign, readonly) BOOL hasColoredIcon;
@property (nonatomic, assign, readonly) BOOL displaysNotificationsOnTile;
@property (nonatomic, readonly) NSString* displayName;
@property (nonatomic, readonly) NSString* localizedDisplayName;
@property (nonatomic, readonly) NSString* accentColor;
@property (nonatomic, readonly) NSString* tileAccentColor;
@property (nonatomic, readonly) NSString* launchScreenAccentColor;
@property (nonatomic, readonly) NSDictionary* labelHiddenForSizes;
@property (nonatomic, readonly) NSDictionary* cornerBadgeForSizes;

/**
 Initializes a tile info object for \p bundleIdentifier

 @param bundleIdentifier The bundle identifier to load tile info for
 @return An instance of RSTileInfo with read-only properties
 */
- (id)initWithBundleIdentifier:(NSString*)bundleIdentifier;

@end
