#import "../Redstone.h"

@implementation RSLockScreenMediaControlsView

- (id)initWithFrame:(CGRect)frame {
	self = [super initWithFrame:frame];
	
	if (self) {
		mediaTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, 44)];
		[mediaTitleLabel setFont:[UIFont fontWithName:@"SegoeUI-Semilight" size:24]];
		[mediaTitleLabel setTextColor:[UIColor whiteColor]];
		[mediaTitleLabel setText:@"Track Title"];
		[mediaTitleLabel setTextAlignment:NSTextAlignmentCenter];
		[self addSubview:mediaTitleLabel];
		
		mediaSubtitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 35, frame.size.width, 30)];
		[mediaSubtitleLabel setFont:[UIFont fontWithName:@"SegoeUI-Semilight" size:17]];
		[mediaSubtitleLabel setTextColor:[UIColor whiteColor]];
		[mediaSubtitleLabel setText:@"Artist Name"];
		[mediaSubtitleLabel setTextAlignment:NSTextAlignmentCenter];
		[self addSubview:mediaSubtitleLabel];
		
		prevTitleButton = [[RSTiltView alloc] initWithFrame:CGRectMake(0, 0, 44, 44)];
		[prevTitleButton setHighlightEnabled:YES];
		[prevTitleButton setTintColor:[UIColor whiteColor]];
		[prevTitleButton setFrame:CGRectMake(self.frame.size.width/2 - 44/2 - 90, self.frame.size.height - 44, 44, 44)];
		[prevTitleButton.titleLabel setFont:[UIFont fontWithName:@"SegoeMDL2Assets" size:24]];
		[prevTitleButton setTitle:@"\uE892"];
		[prevTitleButton addTarget:self action:@selector(previousTrack)];
		[self addSubview:prevTitleButton];
		
		playPauseButton = [[RSTiltView alloc] initWithFrame:CGRectMake(0, 0, 44, 44)];
		[playPauseButton setHighlightEnabled:YES];
		[playPauseButton setTintColor:[UIColor whiteColor]];
		[playPauseButton setFrame:CGRectMake(self.frame.size.width/2 - 44/2, self.frame.size.height - 44, 44, 44)];
		[playPauseButton.titleLabel setFont:[UIFont fontWithName:@"SegoeMDL2Assets" size:24]];
		[playPauseButton setTitle:@"\uE768"];
		[playPauseButton addTarget:self action:@selector(togglePlayPause)];
		[self addSubview:playPauseButton];
		
		nextTitleButton = [[RSTiltView alloc] initWithFrame:CGRectMake(0, 0, 44, 44)];
		[nextTitleButton setHighlightEnabled:YES];
		[nextTitleButton setTintColor:[UIColor whiteColor]];
		[nextTitleButton setFrame:CGRectMake(self.frame.size.width/2 - 44/2 + 90, self.frame.size.height - 44, 44, 44)];
		[nextTitleButton.titleLabel setFont:[UIFont fontWithName:@"SegoeMDL2Assets" size:24]];
		[nextTitleButton setTitle:@"\uE893"];
		[nextTitleButton addTarget:self action:@selector(nextTrack)];
		[self addSubview:nextTitleButton];

		[self setHidden:YES];
	}
	
	return self;
}

- (void)updateNowPlayingInfo:(NSDictionary*)nowPlayingInfo {
	if (!nowPlayingInfo) {
		[self setHidden:YES];
		return;
	}
	
	[self setHidden:NO];
	
	if ([nowPlayingInfo objectForKey:@"kMRMediaRemoteNowPlayingInfoTitle"]) {
		[mediaTitleLabel setText:[nowPlayingInfo objectForKey:@"kMRMediaRemoteNowPlayingInfoTitle"]];
	} else {
		[mediaTitleLabel setText:[RSAesthetics localizedStringForKey:@"MEDIA_UNKNOWN_TITLE"]];
	}
	
	if ([nowPlayingInfo objectForKey:@"kMRMediaRemoteNowPlayingInfoArtist"]) {
		[mediaSubtitleLabel setText:[nowPlayingInfo objectForKey:@"kMRMediaRemoteNowPlayingInfoArtist"]];
	} else {
		[mediaSubtitleLabel setText:[RSAesthetics localizedStringForKey:@"MEDIA_UNKNOWN_ARTIST"]];
	}
	
	[UIView performWithoutAnimation:^{
		if ([[nowPlayingInfo objectForKey:@"kMRMediaRemoteNowPlayingInfoPlaybackRate"] boolValue]) {
			[playPauseButton setTitle:@"\uE769"];
		} else {
			[playPauseButton setTitle:@"\uE768"];
		}
		
		[playPauseButton layoutIfNeeded];
	}];
}

- (void)previousTrack {
	[(SBMediaController*)[objc_getClass("SBMediaController") sharedInstance] changeTrack:-1];
}


- (void)togglePlayPause {
	[(SBMediaController*)[objc_getClass("SBMediaController") sharedInstance] togglePlayPause];
}

- (void)nextTrack {
	[(SBMediaController*)[objc_getClass("SBMediaController") sharedInstance] changeTrack:1];
}

@end
