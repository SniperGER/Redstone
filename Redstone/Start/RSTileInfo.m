#import "../Redstone.h"

@implementation RSTileInfo

- (id)initWithBundleIdentifier:(NSString*)bundleIdentifier {
	self = [super init];
	
	if (self) {
		NSDictionary* tileInfo = [NSDictionary dictionaryWithContentsOfFile:[NSString stringWithFormat:@"%@/Tiles/%@/tile.plist", RESOURCE_PATH, bundleIdentifier]];
		tileBundle = [NSBundle bundleWithPath:[NSString stringWithFormat:@"%@/Tiles/%@", RESOURCE_PATH, bundleIdentifier]];
		
		if ([tileInfo objectForKey:@"FullSizeArtwork"]) {
			_fullSizeArtwork = [[tileInfo objectForKey:@"FullSizeArtwork"] boolValue];
		}
		
		if ([tileInfo objectForKey:@"TileHidesLabel"]) {
			_tileHidesLabel = [[tileInfo objectForKey:@"TileHidesLabel"] boolValue];
		}
		
		if ([tileInfo objectForKey:@"UsesCornerBadge"]) {
			_usesCornerBadge = [[tileInfo objectForKey:@"UsesCornerBadge"] boolValue];
		}
		
		if ([tileInfo objectForKey:@"HasColoredIcon"]) {
			_hasColoredIcon = [[tileInfo objectForKey:@"HasColoredIcon"] boolValue];
		}
		
		if ([tileInfo objectForKey:@"DisplayName"]) {
			_displayName = [tileInfo objectForKey:@"DisplayName"];
		}
		
		if ([tileInfo objectForKey:@"LocalizedDisplayName"] && [[tileInfo objectForKey:@"LocalizedDisplayName"] boolValue]) {
			_localizedDisplayName = [tileBundle localizedStringForKey:@"DisplayName" value:nil table:nil];
			// TODO: Read localized display name from XX.lproj/Localizable.strings included with tile bundle
		}
		
		if ([tileInfo objectForKey:@"AccentColor"]) {
			_accentColor = [tileInfo objectForKey:@"AccentColor"];
		}
		
		if ([tileInfo objectForKey:@"TileAccentColor"]) {
			_tileAccentColor = [tileInfo objectForKey:@"TileAccentColor"];
		}
		
		if ([tileInfo objectForKey:@"LaunchScreenAccentColor"]) {
			_launchScreenAccentColor = [tileInfo objectForKey:@"LaunchScreenAccentColor"];
		}
		
		if ([tileInfo objectForKey:@"LabelHiddenForSizes"]) {
			NSMutableDictionary* sizes = [NSMutableDictionary new];
			for (int i=1; i<=4; i++) {
				if ([[tileInfo objectForKey:@"LabelHiddenForSizes"] objectForKey:[NSString stringWithFormat:@"%d", i]]) {
					[sizes setObject:[[tileInfo objectForKey:@"LabelHiddenForSizes"] objectForKey:[NSString stringWithFormat:@"%d", i]]
							  forKey:[NSString stringWithFormat:@"%d", i]];
				} else {
					[sizes setObject:@NO forKey:[NSString stringWithFormat:@"%d", i]];
				}
			}
			_labelHiddenForSizes = sizes;
		} else {
			NSMutableDictionary* sizes = [NSMutableDictionary new];
			for (int i=1; i<=4; i++) {
				[sizes setObject:@NO forKey:[NSString stringWithFormat:@"%d", i]];
			}
			_labelHiddenForSizes = sizes;
		}
		
		if ([tileInfo objectForKey:@"CornerBadgeForSizes"]) {
			NSMutableDictionary* sizes = [NSMutableDictionary new];
			for (int i=1; i<=4; i++) {
				if ([[tileInfo objectForKey:@"CornerBadgeForSizes"] objectForKey:[NSString stringWithFormat:@"%d", i]]) {
					[sizes setObject:[[tileInfo objectForKey:@"CornerBadgeForSizes"] objectForKey:[NSString stringWithFormat:@"%d", i]]
							  forKey:[NSString stringWithFormat:@"%d", i]];
				} else {
					[sizes setObject:@NO forKey:[NSString stringWithFormat:@"%d", i]];
				}
			}
			_cornerBadgeForSizes = sizes;
		} else {
			NSMutableDictionary* sizes = [NSMutableDictionary new];
			for (int i=1; i<=4; i++) {
				[sizes setObject:@NO forKey:[NSString stringWithFormat:@"%d", i]];
			}
			_cornerBadgeForSizes = sizes;
		}
	}
	
	return self;
}

@end
