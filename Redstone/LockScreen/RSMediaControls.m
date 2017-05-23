#import "../Redstone.h"

@implementation RSMediaControls

- (id)initWithFrame:(CGRect)frame {
	self = [super initWithFrame:frame];
	
	if (self) {
		mediaTitleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
		[mediaTitleLabel setFont:[UIFont fontWithName:@"SegoeUI" size:32]];
		[mediaTitleLabel setTextColor:[UIColor whiteColor]];
		[mediaTitleLabel setText:@"Track Title"];
		[mediaTitleLabel setTextAlignment:NSTextAlignmentCenter];
		[mediaTitleLabel sizeToFit];
		[mediaTitleLabel setFrame:CGRectMake(24, 0, screenWidth - 48, mediaTitleLabel.frame.size.height)];
		[self addSubview:mediaTitleLabel];
		
		mediaArtistLabel = [[UILabel alloc] initWithFrame:CGRectZero];
		[mediaArtistLabel setFont:[UIFont fontWithName:@"SegoeUI" size:24]];
		[mediaArtistLabel setTextColor:[UIColor whiteColor]];
		[mediaArtistLabel setText:@"Album Title"];
		[mediaArtistLabel setTextAlignment:NSTextAlignmentCenter];
		[mediaArtistLabel sizeToFit];
		[mediaArtistLabel setFrame:CGRectMake(24, 40, screenWidth - 48, mediaArtistLabel.frame.size.height)];
		[self addSubview:mediaArtistLabel];
		
		playPauseButton = [UIButton buttonWithType:UIButtonTypeSystem];
		[playPauseButton setTintColor:[UIColor whiteColor]];
		[playPauseButton setFrame:CGRectMake(self.frame.size.width/2 - 44/2, self.frame.size.height - 44, 44, 44)];
		[playPauseButton.titleLabel setFont:[UIFont fontWithName:@"SegoeMDL2Assets" size:28]];
		[playPauseButton setTitle:@"\uE768" forState:UIControlStateNormal];
		[playPauseButton addTarget:self action:@selector(togglePlayPause) forControlEvents:UIControlEventTouchUpInside];
		[self addSubview:playPauseButton];
		
		prevButton = [UIButton buttonWithType:UIButtonTypeSystem];
		[prevButton setTintColor:[UIColor whiteColor]];
		[prevButton setFrame:CGRectMake(self.frame.size.width/2 - 44/2 - 100, self.frame.size.height - 44, 44, 44)];
		[prevButton.titleLabel setFont:[UIFont fontWithName:@"SegoeMDL2Assets" size:28]];
		[prevButton setTitle:@"\uE892" forState:UIControlStateNormal];
		[prevButton addTarget:self action:@selector(previousTrack) forControlEvents:UIControlEventTouchUpInside];
		[self addSubview:prevButton];
		
		nextButton = [UIButton buttonWithType:UIButtonTypeSystem];
		[nextButton setTintColor:[UIColor whiteColor]];
		[nextButton setFrame:CGRectMake(self.frame.size.width/2 - 44/2 + 100, self.frame.size.height - 44, 44, 44)];
		[nextButton.titleLabel setFont:[UIFont fontWithName:@"SegoeMDL2Assets" size:28]];
		[nextButton setTitle:@"\uE893" forState:UIControlStateNormal];
		[nextButton addTarget:self action:@selector(nextTrack) forControlEvents:UIControlEventTouchUpInside];
		[self addSubview:nextButton];
	}
	
	return self;
}

- (void)updateNowPlayingInfo:(NSDictionary*)nowPlayingInfo {
	if ([nowPlayingInfo objectForKey:@"kMRMediaRemoteNowPlayingInfoTitle"]) {
		[mediaTitleLabel setText:[nowPlayingInfo objectForKey:@"kMRMediaRemoteNowPlayingInfoTitle"]];
	} else {
		[mediaTitleLabel setText:nil];
	}
	
	if ([nowPlayingInfo objectForKey:@"kMRMediaRemoteNowPlayingInfoArtist"] && [nowPlayingInfo objectForKey:@"kMRMediaRemoteNowPlayingInfoAlbum"]) {
		[mediaArtistLabel setText:[NSString stringWithFormat:@"%@ — %@",
								   [nowPlayingInfo objectForKey:@"kMRMediaRemoteNowPlayingInfoArtist"],
								   [nowPlayingInfo objectForKey:@"kMRMediaRemoteNowPlayingInfoAlbum"]]];
	} else {
		if ([nowPlayingInfo objectForKey:@"kMRMediaRemoteNowPlayingInfoArtist"] && ![nowPlayingInfo objectForKey:@"kMRMediaRemoteNowPlayingInfoAlbum"]) {
			[mediaArtistLabel setText:[NSString stringWithFormat:@"%@ — %@",
									   [nowPlayingInfo objectForKey:@"kMRMediaRemoteNowPlayingInfoArtist"],
									   [RSAesthetics localizedStringForKey:@"MEDIA_UNKNOWN_ALBUM"]]];
		} else if (![nowPlayingInfo objectForKey:@"kMRMediaRemoteNowPlayingInfoArtist"] && [nowPlayingInfo objectForKey:@"kMRMediaRemoteNowPlayingInfoAlbum"]) {
			[mediaArtistLabel setText:[NSString stringWithFormat:@"%@ — %@",
									   [RSAesthetics localizedStringForKey:@"MEDIA_UNKNOWN_ARTIST"],
									   [nowPlayingInfo objectForKey:@"kMRMediaRemoteNowPlayingInfoAlbum"]]];
		} else {
			[mediaArtistLabel setText:[NSString stringWithFormat:@"%@ — %@",
									   [RSAesthetics localizedStringForKey:@"MEDIA_UNKNOWN_ARTIST"],
									   [RSAesthetics localizedStringForKey:@"MEDIA_UNKNOWN_ALBUM"]]];
		}
	}
	
	if ([[nowPlayingInfo objectForKey:@"kMRMediaRemoteNowPlayingInfoPlaybackRate"] boolValue]) {
		[playPauseButton setTitle:@"\uE769" forState:UIControlStateNormal];
	} else {
		[playPauseButton setTitle:@"\uE768" forState:UIControlStateNormal];
	}
}

- (void)togglePlayPause {
	[(SBMediaController*)[objc_getClass("SBMediaController") sharedInstance] togglePlayPause];
}

- (void)nextTrack {
	[(SBMediaController*)[objc_getClass("SBMediaController") sharedInstance] changeTrack:1];
}

- (void)previousTrack {
	[(SBMediaController*)[objc_getClass("SBMediaController") sharedInstance] changeTrack:-1];
}

@end
