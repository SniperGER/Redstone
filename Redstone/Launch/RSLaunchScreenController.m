#import "../Redstone.h"

@implementation RSLaunchScreenController

static RSLaunchScreenController* sharedInstance;

+ (id)sharedInstance {
	return sharedInstance;
}

- (id)init {
	self = [super init];
	
	if (self) {
		sharedInstance = self;
		
		self.launchScreen = [[RSLaunchScreen alloc] initWithFrame:CGRectMake(0, 0, screenWidth, screenHeight)];
		[self.launchScreen setHidden:YES];
	}
	
	return self;
}

- (void)setLaunchScreenForLeafIdentifier:(NSString *)leafIdentifier {
	NSDictionary* tileInfo = [NSDictionary dictionaryWithContentsOfFile:[NSString stringWithFormat:@"%@/Tiles/%@/tile.plist", RESOURCE_PATH, leafIdentifier]];
	if ([tileInfo objectForKey:@"FullBleedArtwork"] && [[tileInfo objectForKey:@"FullBleedArtwork"] boolValue]) {
		[self.launchScreen.launchImageView setFrame:CGRectMake(0, 0, 269, 132)];
	} else {
		[self.launchScreen.launchImageView setFrame:CGRectMake(0, 0, 76, 76)];
	}
	[self.launchScreen.launchImageView setCenter:CGPointMake(screenWidth/2, screenHeight/2)];
	
	[self.launchScreen.launchImageView setImage:[RSAesthetics getImageForTileWithBundleIdentifier:leafIdentifier size:3]];
	[self.launchScreen setBackgroundColor:[RSAesthetics accentColorForLaunchScreen:leafIdentifier]];
}

- (void)show {
	CAAnimation* scale = [CAKeyframeAnimation animationWithKeyPath:@"transform.scale"
														  function:CubicEaseOut
														 fromValue:0.8
														   toValue:1.0];
	[scale setDuration:0.5];
	[scale setRemovedOnCompletion:NO];
	[scale setFillMode:kCAFillModeForwards];
	
	CAAnimation* opacity = [CAKeyframeAnimation animationWithKeyPath:@"opacity"
															function:CubicEaseIn
														   fromValue:0.0
															 toValue:1.0];
	[opacity setDuration:0.3];
	[opacity setRemovedOnCompletion:NO];
	[opacity setFillMode:kCAFillModeForwards];
	
	[self.launchScreen setHidden:NO];
	[self.launchScreen.layer addAnimation:opacity forKey:@"opacity"];
	[self.launchScreen.launchImageView.layer addAnimation:scale forKey:@"scale"];
}

- (void)hide {
	[self.launchScreen setHidden:YES];
	[self.launchScreen.layer removeAllAnimations];
	[self.launchScreen.launchImageView.layer removeAllAnimations];
}

@end
