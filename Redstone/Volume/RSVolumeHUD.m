#import "../Redstone.h"

@implementation RSVolumeHUD

- (id)initWithFrame:(CGRect)frame {
	self = [super initWithFrame:frame];
	
	if (self) {
		volumeView = [[RSVolumeView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, 100)];
		[volumeView setBounds:CGRectMake(0, 0, screenWidth, 100)];
		[self addSubview:volumeView];
		
#pragma mark Ringer Volume Control
		ringerSlider = [[RSVolumeSlider alloc] initWithFrame:CGRectMake(screenWidth/2 - 280/2, 37, 280, 24)];
		[ringerSlider setValue:[[RSSoundController sharedInstance] ringerVolume]];
		[ringerSlider addTarget:self action:@selector(ringerVolumeChanged) forControlEvents:UIControlEventValueChanged];
		[volumeView addSubview:ringerSlider];
		
		ringerStatusText = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, screenWidth-20, 20)];
		[ringerStatusText setFont:[UIFont fontWithName:@"SegoeUI" size:15]];
		[ringerStatusText setTextColor:[UIColor whiteColor]];
		[volumeView addSubview:ringerStatusText];
		
		ringerStatusButton = [[RSTiltView alloc] initWithFrame:CGRectMake(10, 37, 36, 36)];
		[ringerStatusButton setTintColor:[UIColor whiteColor]];
		[ringerStatusButton.titleLabel setFont:[UIFont fontWithName:@"SegoeMDL2Assets" size:24]];
		[ringerStatusButton addTarget:self action:@selector(toggleRingerState)];
		[volumeView addSubview:ringerStatusButton];
		
		ringerVolumeLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.frame.size.width - 51, 31, 36, 36)];
		[ringerVolumeLabel setFont:[UIFont fontWithName:@"SegoeUI-Light" size:32]];
		[ringerVolumeLabel setTextAlignment:NSTextAlignmentCenter];
		[ringerVolumeLabel setTextColor:[UIColor whiteColor]];
		[ringerVolumeLabel setText:@"--"];
		[volumeView addSubview:ringerVolumeLabel];
		
		if ([[objc_getClass("SBMediaController") sharedInstance] isRingerMuted]) {
			[ringerStatusText setText:[RSAesthetics localizedStringForKey:@"RINGER_MODE_VIBRATION"]];
			[ringerStatusButton setTitle:@"\uE877"];
			
			[ringerSlider setValue:0.0];
			[ringerVolumeLabel setText:[NSString stringWithFormat:@"%02.00f", 0.0]];
		} else {
			[ringerStatusText setText:[RSAesthetics localizedStringForKey:@"RINGER_MODE_ENABLED"]];
			[ringerStatusButton setTitle:@"\uEA8F"];
			
			[ringerSlider setValue:[[RSSoundController sharedInstance] ringerVolume]];
			[ringerVolumeLabel setText:[NSString stringWithFormat:@"%02.00f", ([[RSSoundController sharedInstance] ringerVolume] * 16.0)]];
		}
		
#pragma mark Media Volume Control
		mediaSlider = [[RSVolumeSlider alloc] initWithFrame:CGRectMake(screenWidth/2 - 280/2, 147, 280, 24)];
		[mediaSlider setValue:[[RSSoundController sharedInstance] mediaVolume]];
		[mediaSlider addTarget:self action:@selector(mediaVolumeChanged) forControlEvents:UIControlEventValueChanged];
		[volumeView addSubview:mediaSlider];
		
		mediaStatusText = [[UILabel alloc] initWithFrame:CGRectMake(10, 110, screenWidth-20, 20)];
		[mediaStatusText setFont:[UIFont fontWithName:@"SegoeUI" size:15]];
		[mediaStatusText setTextColor:[UIColor whiteColor]];
		[mediaStatusText setText:[RSAesthetics localizedStringForKey:@"MEDIA_VOLUME"]];
		[volumeView addSubview:mediaStatusText];
		
		mediaStatusButton = [[RSTiltView alloc] initWithFrame:CGRectMake(10, 147, 36, 36)];
		[mediaStatusButton setTintColor:[UIColor whiteColor]];
		[mediaStatusButton.titleLabel setFont:[UIFont fontWithName:@"SegoeMDL2Assets" size:24]];
		[mediaStatusButton addTarget:self action:@selector(toggleMuteState)];
		[volumeView addSubview:mediaStatusButton];
		
		mediaVolumeLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.frame.size.width - 51, 141, 36, 36)];
		[mediaVolumeLabel setFont:[UIFont fontWithName:@"SegoeUI-Light" size:32]];
		[mediaVolumeLabel setTextAlignment:NSTextAlignmentCenter];
		[mediaVolumeLabel setTextColor:[UIColor whiteColor]];
		[mediaVolumeLabel setText:[NSString stringWithFormat:@"%02.00f", ([[RSSoundController sharedInstance] mediaVolume] * 16.0)]];
		[volumeView addSubview:mediaVolumeLabel];
		
		if ([[RSSoundController sharedInstance] mediaVolume] >= 1.0/16.0) {
			[mediaStatusButton setTitle:@"\uE15D"];
		} else {
			[mediaStatusButton setTitle:@"\uE74F"];
		}
		
		[self updateForChangedRingerState];
		
#pragma mark Expand Button
		expandButton = [[RSTiltView alloc] initWithFrame:CGRectMake(self.frame.size.width - 46, 10, 36, 18)];
		[expandButton setTiltEnabled:NO];
		[expandButton setTintColor:[UIColor whiteColor]];
		[expandButton.titleLabel setFont:[UIFont fontWithName:@"SegoeMDL2Assets" size:24]];
		[expandButton setTitle:@"\uE70D"];
		[expandButton addTarget:self action:@selector(toggleExpanded)];
		[volumeView addSubview:expandButton];
	}
	
	return self;
}

- (void)animateIn {
	[self setHidden:NO];
	
	[volumeView setFrame:CGRectMake(0, -100, screenWidth, 100)];
	
	[UIView animateWithDuration:0.3 animations:^{
		[volumeView setEasingFunction:easeOutCubic forKeyPath:@"frame"];
		
		[volumeView setFrame:CGRectMake(0, 0, screenWidth, 100)];
	} completion:^(BOOL finished){
		[volumeView removeEasingFunctionForKeyPath:@"frame"];
	}];
}

- (void)animateOut {
	slideOutTimer = nil;
	
	//[volumeView setFrame:CGRectMake(0, 0, screenWidth, 100)];
	[UIView animateWithDuration:0.3 animations:^{
		[volumeView setEasingFunction:easeInCubic forKeyPath:@"frame"];
		
		[volumeView setFrame:CGRectMake(0, -volumeView.frame.size.height, screenWidth, -volumeView.frame.size.height)];
	} completion:^(BOOL finished){
		[volumeView removeEasingFunctionForKeyPath:@"frame"];
		[volumeView setFrame:CGRectMake(0, 0, screenWidth, 100)];
		[expandButton setFrame:CGRectMake(self.frame.size.width - 46, 10, 36, 18)];
		[expandButton setTransform:CGAffineTransformIdentity];
		[self setHidden:YES];
		
		[[RSSoundController sharedInstance] setIsShowingVolumeHUD:NO];
		expanded = NO;
	}];
}

- (void)resetSlideOutTimer {
	if ([slideOutTimer isKindOfClass:[NSTimer class]]) {
		[self stopSlideOutTimer];
	}
	
	slideOutTimer = [NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(animateOut) userInfo:nil repeats:NO];
}

- (void)stopSlideOutTimer {
	if ([slideOutTimer isValid]) {
		[slideOutTimer invalidate];
		slideOutTimer = nil;
	}
}

- (void)updateVolume {
	if (ringerSlider.isTracking || mediaSlider.isTracking) {
		return;
	}
	
	SBMediaController* mediaController = [objc_getClass("SBMediaController") sharedInstance];
	if ([[RSSoundController sharedInstance] ringerVolume] >= 1.0/16.0 ) {
		[mediaController setRingerMuted:NO];
	} else {
		[mediaController setRingerMuted:YES];
	}
	
	[ringerSlider setValue:[[RSSoundController sharedInstance] ringerVolume]];
	[ringerVolumeLabel setText:[NSString stringWithFormat:@"%02.00f", ([[RSSoundController sharedInstance] ringerVolume] * 16.0)]];
	
	[mediaSlider setValue:[[RSSoundController sharedInstance] mediaVolume]];
	[mediaVolumeLabel setText:[NSString stringWithFormat:@"%02.00f", ([[RSSoundController sharedInstance] mediaVolume] * 16.0)]];
	
	[self updateForChangedRingerState];
}

- (void)ringerVolumeChanged {
	[self resetSlideOutTimer];
	
	float ringerValue = [[NSString stringWithFormat:@"%.04f", [ringerSlider value]] floatValue];
	ringerValue = roundf(ringerValue*16)/16;
	[ringerVolumeLabel setText:[NSString stringWithFormat:@"%02.00f", (ringerValue * 16.0)]];
	
	if (ringerValue >= 1.0/16.0) {
		[[objc_getClass("AVSystemController") sharedAVSystemController] setVolumeTo:ringerValue forCategory:@"Ringtone"];
		[[objc_getClass("SBMediaController") sharedInstance] setRingerMuted:NO];
	} else {
		[[objc_getClass("SBMediaController") sharedInstance] setRingerMuted:YES];
		[[RSSoundController sharedInstance] volumeChanged:0.0 forCategory:@"Ringtone" increasingVolume:NO];
		[[objc_getClass("AVSystemController") sharedAVSystemController] setVolumeTo:0.0 forCategory:@"Ringtone"];
	}
	
	[[RSSoundController sharedInstance] setRingerVolume:ringerValue];
	[self updateForChangedRingerState];
}

- (void)mediaVolumeChanged {
	[self resetSlideOutTimer];
	
	float mediaValue = [[NSString stringWithFormat:@"%.04f", [mediaSlider value]] floatValue];
	mediaValue = roundf(mediaValue*16)/16;
	[mediaVolumeLabel setText:[NSString stringWithFormat:@"%02.00f", (mediaValue * 16.0)]];
	
	[[objc_getClass("AVSystemController") sharedAVSystemController] setVolumeTo:mediaValue forCategory:@"Audio/Video"];
	
	if (mediaValue >= 1.0/16.0) {
		[mediaStatusButton setTitle:@"\uE15D"];
	} else {
		[mediaStatusButton setTitle:@"\uE74F"];
	}
	
	[[RSSoundController sharedInstance] setMediaVolume:mediaValue];
}

- (void)updateForChangedRingerState {
	[UIView performWithoutAnimation:^{
		if ([[objc_getClass("SBMediaController") sharedInstance] isRingerMuted]) {
			[ringerStatusText setText:[RSAesthetics localizedStringForKey:@"RINGER_MODE_VIBRATION"]];
			[ringerStatusButton setTitle:@"\uE877"];
		} else {
			[ringerStatusText setText:[RSAesthetics localizedStringForKey:@"RINGER_MODE_ENABLED"]];
			[ringerStatusButton setTitle:@"\uEA8F"];
		}
	}];
}

- (void)toggleRingerState {
	SBMediaController* mediaController = [objc_getClass("SBMediaController") sharedInstance];
	
	if ([mediaController isRingerMuted]) {
		[mediaController setRingerMuted:NO];
		[[RSSoundController sharedInstance] volumeChanged:1.0/16.0 forCategory:@"Ringtone" increasingVolume:YES];
		[[objc_getClass("AVSystemController") sharedAVSystemController] setVolumeTo:1.0/16.0 forCategory:@"Ringtone"];
	} else {
		[mediaController setRingerMuted:YES];
		[[RSSoundController sharedInstance] volumeChanged:0.0 forCategory:@"Ringtone" increasingVolume:NO];
		[[objc_getClass("AVSystemController") sharedAVSystemController] setVolumeTo:0.0 forCategory:@"Ringtone"];
	}
}

- (void)toggleMuteState {
	if ([[RSSoundController sharedInstance] mediaVolume] > 0) {
		[[RSSoundController sharedInstance] volumeChanged:0.0 forCategory:@"Audio/Video" increasingVolume:NO];
		[[objc_getClass("AVSystemController") sharedAVSystemController] setVolumeTo:0.0 forCategory:@"Audio/Video"];
		
		[mediaStatusButton setTitle:@"\uE74F"];
	} else {
		[[RSSoundController sharedInstance] volumeChanged:1.0/16.0 forCategory:@"Audio/Video" increasingVolume:YES];
		[[objc_getClass("AVSystemController") sharedAVSystemController] setVolumeTo:1.0/16.0 forCategory:@"Audio/Video"];
		
		[mediaStatusButton setTitle:@"\uE15D"];
	}
}

- (void)toggleExpanded {
	if (!expanded) {
		expanded = YES;
		[self setFrame:CGRectMake(0, 0, screenWidth, 244)];
		[self resetSlideOutTimer];
		
		[expandButton setFrame:CGRectMake(self.frame.size.width - 46, self.frame.size.height - 28, 36, 18)];
		[expandButton setTransform:CGAffineTransformMakeRotation(deg2rad(180))];
		
		[UIView animateWithDuration:0.3 animations:^{
			[volumeView setEasingFunction:easeInOutExpo forKeyPath:@"frame"];
			
			[volumeView setBounds:CGRectMake(0, 0, screenWidth, 244)];
		} completion:^(BOOL finished){
			[volumeView removeEasingFunctionForKeyPath:@"frame"];
			
		}];
	} else {
		expanded = NO;
		[self resetSlideOutTimer];
		
		[expandButton setFrame:CGRectMake(self.frame.size.width - 46, 10, 36, 18)];
		[expandButton setTransform:CGAffineTransformIdentity];
		
		[UIView animateWithDuration:0.3 animations:^{
			[volumeView setEasingFunction:easeInOutExpo forKeyPath:@"frame"];
			
			[volumeView setBounds:CGRectMake(0, 0, screenWidth, 100)];
		} completion:^(BOOL finished){
			[volumeView removeEasingFunctionForKeyPath:@"frame"];
			[self setFrame:CGRectMake(0, 0, screenWidth, 100)];
		}];
	}
}

/*- (id)initWithFrame:(CGRect)frame {
	self = [super initWithFrame:frame];
	
	if (self) {
		volumeView = [[RSVolumeView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, 100)];
		[self addSubview:volumeView];
		
		ringerSlider = [[RSVolumeSlider alloc] initWithFrame:CGRectMake(screenWidth/2 - 280/2, 37, 280, 36)];
		//[ringerSlider setMinValue:0.1];
		[ringerSlider addTarget:self action:@selector(ringerVolumeChanged) forControlEvents:UIControlEventValueChanged];
		[volumeView addSubview:ringerSlider];
		
		ringerStatusText = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, screenWidth-20, 30)];
		[ringerStatusText setFont:[UIFont fontWithName:@"SegoeUI" size:15]];
		[ringerStatusText setTextColor:[UIColor whiteColor]];
		[volumeView addSubview:ringerStatusText];
		
		ringerStatusButton = [[RSTiltView alloc] initWithFrame:CGRectMake(10, 37, 36, 36)];
		[ringerStatusButton setTintColor:[UIColor whiteColor]];
		[ringerStatusButton.titleLabel setFont:[UIFont fontWithName:@"SegoeMDL2Assets" size:24]];
		
		if ([[objc_getClass("SBMediaController") sharedInstance] isRingerMuted]) {
			[ringerStatusText setText:[RSAesthetics localizedStringForKey:@"RINGER_MODE_VIBRATION"]];
			[ringerStatusButton setTitle:@"\uE877"];
		} else {
			[ringerStatusText setText:[RSAesthetics localizedStringForKey:@"RINGER_MODE_ENABLED"]];
			[ringerStatusButton setTitle:@"\uEA8F"];
		}
		
		[ringerStatusText sizeToFit];
		[ringerStatusButton addTarget:self action:@selector(toggleRingerState)];
		[volumeView addSubview:ringerStatusButton];
		
		ringerVolumeLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.frame.size.width - 51, 37, 36, 36)];
		[ringerVolumeLabel setFont:[UIFont fontWithName:@"SegoeUI-Light" size:32]];
		[ringerVolumeLabel setTextAlignment:NSTextAlignmentCenter];
		[ringerVolumeLabel setTextColor:[UIColor whiteColor]];
		[ringerVolumeLabel setText:@"05"];
		[volumeView addSubview:ringerVolumeLabel];
		
		[self updateVolume];
	}
	
	return self;
}

- (void)animateIn {
	[self setHidden:NO];
	
	[volumeView setFrame:CGRectMake(0, -100, screenWidth, 100)];
	
	[UIView animateWithDuration:0.3 animations:^{
		[volumeView setEasingFunction:easeOutCubic forKeyPath:@"frame"];
		
		[volumeView setFrame:CGRectMake(0, 0, screenWidth, 100)];
	} completion:^(BOOL finished){
		[volumeView removeEasingFunctionForKeyPath:@"frame"];
	}];
	
}

- (void)animateOut {
	slideOutTimer = nil;
	
	[volumeView setFrame:CGRectMake(0, 0, screenWidth, 100)];
	[UIView animateWithDuration:0.3 animations:^{
		[volumeView setEasingFunction:easeInCubic forKeyPath:@"frame"];
		
		[volumeView setFrame:CGRectMake(0, -100, screenWidth, 100)];
	} completion:^(BOOL finished){
		[volumeView removeEasingFunctionForKeyPath:@"frame"];
		[self setHidden:YES];
		[[RSSoundController sharedInstance] setIsShowingVolumeHUD:NO];
	}];
}

- (void)resetSlideOutTimer {
	if ([slideOutTimer isKindOfClass:[NSTimer class]]) {
		[self stopSlideOutTimer];
	}
	
	slideOutTimer = [NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(animateOut) userInfo:nil repeats:NO];
}

- (void)stopSlideOutTimer {
	if ([slideOutTimer isValid]) {
		[slideOutTimer invalidate];
		slideOutTimer = nil;
	}
}

- (void)ringerVolumeChanged {
	[self resetSlideOutTimer];
	
	float ringerValue = [[NSString stringWithFormat:@"%.02f", [ringerSlider value]] floatValue];
	ringerValue = roundf(ringerValue * 10) / 10.0;
	
	[ringerVolumeLabel setText:[NSString stringWithFormat:@"%02.00f", (ringerValue * 10.0)]];
	
	if (ringerValue >= 0.10) {
		[[objc_getClass("AVSystemController") sharedAVSystemController] setVolumeTo:ringerValue forCategory:@"Ringtone"];
		[[objc_getClass("SBMediaController") sharedInstance] setRingerMuted:NO];
	} else {
		[[objc_getClass("SBMediaController") sharedInstance] setRingerMuted:YES];
	}
	
	[self updateForChangedRingerState];
}

- (void)mediaVolumeChanged {
	//[self resetSlideOutTimer];
	
	NSString* mediaValue = [NSString stringWithFormat:@"%.02f", [mediaSlider value]];
	[[objc_getClass("AVSystemController") sharedAVSystemController] setVolumeTo:[mediaValue floatValue] forCategory:@"Audio/Video"];
}

- (void)updateVolume {
	float ringerVolume = 0;
	[[objc_getClass("AVSystemController") sharedAVSystemController] getVolume:&ringerVolume forCategory:@"Ringtone"];
	
	if ([[objc_getClass("SBMediaController") sharedInstance] isRingerMuted]) {
		ringerVolume = 0.10;
		[[objc_getClass("SBMediaController") sharedInstance] setRingerMuted:NO];
		[[objc_getClass("AVSystemController") sharedAVSystemController] setVolumeTo:0.1 forCategory:@"Ringtone"];
	}
	
	[ringerSlider setValue:ringerVolume];
	[ringerVolumeLabel setText:[NSString stringWithFormat:@"%02.00f", (ringerVolume * 10.0)]];
	[self updateForChangedRingerState];
}

- (void)toggleRingerState {
	SBMediaController* mediaController = [objc_getClass("SBMediaController") sharedInstance];
	
	[mediaController setRingerMuted:![mediaController isRingerMuted]];
	
	[self resetSlideOutTimer];
}

- (void)updateForChangedRingerState {
	[UIView performWithoutAnimation:^{
		if ([[objc_getClass("SBMediaController") sharedInstance] isRingerMuted]) {
			[ringerStatusText setText:[RSAesthetics localizedStringForKey:@"RINGER_MODE_VIBRATION"]];
			[ringerStatusButton setTitle:@"\uE877"];
			
			[[objc_getClass("AVSystemController") sharedAVSystemController] setVolumeTo:0.0 forCategory:@"Ringtone"];
			
			[ringerSlider setValue:0.0];
			[ringerVolumeLabel setText:@"00"];
		} else {
			[ringerStatusText setText:[RSAesthetics localizedStringForKey:@"RINGER_MODE_ENABLED"]];
			[ringerStatusButton setTitle:@"\uEA8F"];
			
			float ringerVolume;
			[[objc_getClass("AVSystemController") sharedAVSystemController] getVolume:&ringerVolume forCategory:@"Ringtone"];
			
			[ringerSlider setValue:ringerVolume];
			[ringerVolumeLabel setText:[NSString stringWithFormat:@"%02.00f", (ringerVolume * 10.0)]];
		}
	}];
}*/

@end
