#import "../Redstone.h"

@implementation RSMediaControls

- (id)initWithFrame:(CGRect)frame {
	self = [super initWithFrame:frame];
	
	if (self) {
		mediaTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(24, 0, screenWidth - 48, 30)];
		[mediaTitleLabel setFont:[UIFont fontWithName:@"SegoeUI" size:32]];
		[mediaTitleLabel setTextColor:[UIColor whiteColor]];
		[mediaTitleLabel setText:@"Track Title"];
		[mediaTitleLabel setTextAlignment:NSTextAlignmentCenter];
		[self addSubview:mediaTitleLabel];
		
		mediaArtistLabel = [[UILabel alloc] initWithFrame:CGRectMake(24, 40, screenWidth - 48, 20)];
		[mediaArtistLabel setFont:[UIFont fontWithName:@"SegoeUI" size:24]];
		[mediaArtistLabel setTextColor:[UIColor whiteColor]];
		[mediaArtistLabel setText:@"Album Title"];
		[mediaArtistLabel setTextAlignment:NSTextAlignmentCenter];
		[self addSubview:mediaArtistLabel];
		
		playPauseButton = [UIButton buttonWithType:UIButtonTypeSystem];
		[playPauseButton setTintColor:[UIColor whiteColor]];
		[playPauseButton setFrame:CGRectMake(self.frame.size.width/2 - 32/2, self.frame.size.height - 32, 32, 32)];
		[playPauseButton.titleLabel setFont:[UIFont fontWithName:@"SegoeMDL2Assets" size:28]];
		[playPauseButton setTitle:@"\uE768" forState:UIControlStateNormal];
		[self addSubview:playPauseButton];
		
		prevButton = [UIButton buttonWithType:UIButtonTypeSystem];
		[prevButton setTintColor:[UIColor whiteColor]];
		[prevButton setFrame:CGRectMake(self.frame.size.width/2 - 32/2 - 100, self.frame.size.height - 32, 32, 32)];
		[prevButton.titleLabel setFont:[UIFont fontWithName:@"SegoeMDL2Assets" size:28]];
		[prevButton setTitle:@"\uE892" forState:UIControlStateNormal];
		[self addSubview:prevButton];
		
		nextButton = [UIButton buttonWithType:UIButtonTypeSystem];
		[nextButton setTintColor:[UIColor whiteColor]];
		[nextButton setFrame:CGRectMake(self.frame.size.width/2 - 32/2 + 100, self.frame.size.height - 32, 32, 32)];
		[nextButton.titleLabel setFont:[UIFont fontWithName:@"SegoeMDL2Assets" size:28]];
		[nextButton setTitle:@"\uE893" forState:UIControlStateNormal];
		[self addSubview:nextButton];
	}
	
	return self;
}

- (void)updateNowPlayingInfo:(NSDictionary*)nowPlayingInfo {
	/*[mediaTitleLabel setText:[[objc_getClass("SBMediaController") sharedInstance] nowPlayingTitle]];
	[mediaArtistLabel setText:[[objc_getClass("SBMediaController") sharedInstance] nowPlayingArtist]];*/
	
	if ([nowPlayingInfo objectForKey:@"kMRMediaRemoteNowPlayingInfoTitle"]) {
		[mediaTitleLabel setText:[nowPlayingInfo objectForKey:@"kMRMediaRemoteNowPlayingInfoTitle"]];
	} else {
		[mediaTitleLabel setText:nil];
	}
	
	if ([nowPlayingInfo objectForKey:@"kMRMediaRemoteNowPlayingInfoAlbum"]) {
		[mediaArtistLabel setText:[nowPlayingInfo objectForKey:@"kMRMediaRemoteNowPlayingInfoAlbum"]];
	} else {
		if ([[nowPlayingInfo objectForKey:@"kMRMediaRemoteNowPlayingInfoPlaybackRate"] boolValue]) {
			[mediaArtistLabel setText:[RSAesthetics localizedStringForKey:@"MEDIA_UNKNOWN_ARTIST"]];
		} else {
			[mediaArtistLabel setText:nil];
		}
	}
}

@end
