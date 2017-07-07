/**
 @class RSApp
 @author Sniper_GER
 @discussion Represents an entry for an installed app in App List
 */

#import <UIKit/UIKit.h>

@class RSTiltView, RSProgressBar, RSTileInfo, SBLeafIcon;

@interface RSApp : RSTiltView {
	UILabel* appLabel;
	
	UIView* appImageBackground;
	UIImageView* appImageView;
}

@property (nonatomic, strong) SBLeafIcon* icon;
@property (nonatomic, strong) RSTileInfo* tileInfo;

/**
 Creates a new App List entry for an app with the bundle identifier \p leafIdentifier

 @param frame The frame to create the App List Entry with
 @param leafIdentifier The bundle identifier for an installed app
 @return An instance of RSApp representing an app matching the bundle identifier \p leafIdetifier
 */
- (id)initWithFrame:(CGRect)frame leafIdentifier:(NSString*)leafIdentifier;

- (NSString*)displayName;

- (void)setDisplayName:(NSString*)displayName;

@end
