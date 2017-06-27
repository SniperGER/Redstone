#import "../Redstone.h"

@implementation RSVolumeHUD

- (id)initWithFrame:(CGRect)frame {
	if (self = [super initWithFrame:frame]) {
		[self setBackgroundColor:[UIColor colorWithWhite:0.22 alpha:1.0]];
		[self setWindowLevel:2200];
		[self setClipsToBounds:YES];
		[self.layer setAnchorPoint:CGPointMake(0.5, 0)];
		
		ringerVolumeView = [[RSVolumeView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, 100) forCategory:@"Ringtone"];
		[self addSubview:ringerVolumeView];
		
		mediaVolumeView = [[RSVolumeView alloc] initWithFrame:CGRectMake(0, 110, screenWidth, 100) forCategory:@"Audio/Video"];
		[self addSubview:mediaVolumeView];
		
		headphoneVolumeView = [[RSVolumeView alloc] initWithFrame:CGRectMake(0, 110, screenWidth, 100) forCategory:@"Headphones"];
		[headphoneVolumeView setHidden:YES];
		[self addSubview:headphoneVolumeView];
		
		ringerSlider = [[RSVolumeSlider alloc] initWithFrame:CGRectMake(screenWidth/2 - 280/2, 37, 280, 24)];
		[ringerSlider setValue:[[RSSoundController sharedInstance] ringerVolume]];
		[ringerSlider addTarget:self action:@selector(ringerVolumeChanged) forControlEvents:UIControlEventValueChanged];
		[ringerVolumeView addSubview:ringerSlider];
		
		mediaSlider = [[RSVolumeSlider alloc] initWithFrame:CGRectMake(screenWidth/2 - 280/2, 37, 280, 24)];
		[mediaSlider setValue:[[RSSoundController sharedInstance] mediaVolume]];
		[mediaSlider addTarget:self action:@selector(mediaVolumeChanged) forControlEvents:UIControlEventValueChanged];
		[mediaVolumeView addSubview:mediaSlider];
		
		headphoneSlider = [[RSVolumeSlider alloc] initWithFrame:CGRectMake(screenWidth/2 - 280/2, 37, 280, 24)];
		[headphoneSlider setValue:[[RSSoundController sharedInstance] mediaVolume]];
		[headphoneSlider addTarget:self action:@selector(headphoneVolumeChanged) forControlEvents:UIControlEventValueChanged];
		[headphoneVolumeView addSubview:headphoneSlider];
		
		ringerMuteButton = [[RSTiltView alloc] initWithFrame:CGRectMake(10, 37, 36, 36)];
		[ringerMuteButton setTintColor:[UIColor whiteColor]];
		[ringerMuteButton.titleLabel setFont:[UIFont fontWithName:@"SegoeMDL2Assets" size:24]];
		[ringerMuteButton addTarget:self action:@selector(toggleRingerMuted)];
		[ringerVolumeView addSubview:ringerMuteButton];
		
		mediaMuteButton = [[RSTiltView alloc] initWithFrame:CGRectMake(10, 37, 36, 36)];
		[mediaMuteButton setTintColor:[UIColor whiteColor]];
		[mediaMuteButton.titleLabel setFont:[UIFont fontWithName:@"SegoeMDL2Assets" size:24]];
		[mediaMuteButton addTarget:self action:@selector(toggleMediaMuted)];
		[mediaVolumeView addSubview:mediaMuteButton];
		
		headphoneMuteButton = [[RSTiltView alloc] initWithFrame:CGRectMake(10, 37, 36, 36)];
		[headphoneMuteButton setTintColor:[UIColor whiteColor]];
		[headphoneMuteButton.titleLabel setFont:[UIFont fontWithName:@"SegoeMDL2Assets" size:24]];
		[headphoneMuteButton setTitle:@"\uE7F6"];
		[headphoneMuteButton addTarget:self action:@selector(toggleMediaMuted)];
		[headphoneVolumeView addSubview:headphoneMuteButton];
		
		if ([ringerSlider currentValue] >= 1.0/16.0) {
			[[objc_getClass("SBMediaController") sharedInstance] setRingerMuted:NO];
			[ringerMuteButton setTitle:@"\uEA8F"];
		} else {
			[[objc_getClass("SBMediaController") sharedInstance] setRingerMuted:YES];
			[ringerMuteButton setTitle:@"\uE877"];
		}
		
		if ([mediaSlider currentValue] >= 1.0/16.0) {
			[mediaMuteButton setTitle:@"\uE767"];
		} else {
			[mediaMuteButton setTitle:@"\uE74F"];
		}
		
		[ringerVolumeView setVolumeValue:[[RSSoundController sharedInstance] ringerVolume]];
		[mediaVolumeView setVolumeValue:[[RSSoundController sharedInstance] mediaVolume]];
		[headphoneVolumeView setVolumeValue:[[RSSoundController sharedInstance] mediaVolume]];
		
		expandButton = [[RSTiltView alloc] initWithFrame:CGRectMake(self.frame.size.width - 46, 10, 36, 18)];
		[expandButton setTiltEnabled:NO];
		[expandButton setTintColor:[UIColor whiteColor]];
		[expandButton.titleLabel setFont:[UIFont fontWithName:@"SegoeMDL2Assets" size:18]];
		[expandButton setTitle:@"\uE70D"];
		[expandButton addTarget:self action:@selector(toggleExpanded)];
		[self addSubview:expandButton];
		
		nowPlayingControls = [[RSNowPlayingControls alloc] initWithFrame:CGRectMake(0, 100, screenWidth, 120)];
		[nowPlayingControls setLightTextEnabled:NO];
		[self addSubview:nowPlayingControls];
		
		vibrateButton = [UIButton buttonWithType:UIButtonTypeSystem];
		[vibrateButton addTarget:self action:@selector(toggleVibrationEnabled) forControlEvents:UIControlEventTouchUpInside];
		[self addSubview:vibrateButton];
		[self updateVibrateButtonStatus];
		
		ringerButton = [UIButton buttonWithType:UIButtonTypeSystem];
		[ringerButton addTarget:self action:@selector(toggleRingerMuted) forControlEvents:UIControlEventTouchUpInside];
		[self addSubview:ringerButton];
		[self updateRingerButtonStatus];
	}
	
	return self;
}

#pragma mark Animation

- (void)animateIn {
	[self setHidden:NO];
	
	[CATransaction begin];
	[CATransaction setDisableActions:YES];
	
	[self setFrame:CGRectMake(0, -self.frame.size.height, screenWidth, self.frame.size.height)];
	
	[[RSSoundController sharedInstance] updateNowPlayingInfo:nil];
	[ringerVolumeView updateVolumeDisplay];
	[mediaVolumeView updateVolumeDisplay];
	[headphoneVolumeView updateVolumeDisplay];
	
	[expandButton setFrame:CGRectMake(self.frame.size.width - 46, 10, 36, 18)];
	[expandButton setTransform:CGAffineTransformIdentity];
	[expandButton setAlpha:1.0];
	
	if (self.isShowingMediaControls) {
		[ringerButton setHidden:YES];
	}
	
	[CATransaction commit];
	
	[UIView animateWithDuration:0.3 animations:^{
		[self setEasingFunction:easeOutCubic forKeyPath:@"frame"];
		
		[self setFrame:CGRectMake(0, 0, screenWidth, self.frame.size.height)];
	} completion:^(BOOL finished){
		[self removeEasingFunctionForKeyPath:@"frame"];
	}];
}

- (void)animateOut {
	[UIView animateWithDuration:0.3 animations:^{
		[self setEasingFunction:easeInCubic forKeyPath:@"frame"];
		
		[self setFrame:CGRectMake(0, -self.frame.size.height, screenWidth, self.frame.size.height)];
	} completion:^(BOOL finished){
		[self removeEasingFunctionForKeyPath:@"frame"];
		
		_isExpanded = NO;
		[self setHidden:YES];
		
		if (self.isShowingMediaControls) {
			[self setFrame:CGRectMake(0, 0, screenWidth, 220)];
		} else {
			[self setFrame:CGRectMake(0, 0, screenWidth, 100)];
		}
		
		[expandButton setFrame:CGRectMake(self.frame.size.width - 46, 10, 36, 18)];
		[expandButton setTransform:CGAffineTransformIdentity];
		[expandButton setAlpha:1.0];
		
		[[RSSoundController sharedInstance] setIsShowingVolumeHUD:NO];
	}];
}

- (void)stopSlideOutTimer {
	if ([slideOutTimer isKindOfClass:[NSTimer class]]) {
		[slideOutTimer invalidate];
		slideOutTimer = nil;
	}
}

- (void)resetSlideOutTimer {
	[self stopSlideOutTimer];
	
	slideOutTimer = [NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(animateOut) userInfo:nil repeats:NO];
}

#pragma mark States

- (void)toggleExpanded {
	[self setIsExpanded:!self.isExpanded];
}

- (void)setIsExpanded:(BOOL)isExpanded {
	_isExpanded = isExpanded;
	
	if (isExpanded) {
		if (self.isShowingMediaControls) {
			[expandButton setFrame:CGRectMake(self.frame.size.width - 46, 162, 36, 18)];
			[vibrateButton setFrame:CGRectMake(10, 110, vibrateButton.frame.size.width, vibrateButton.frame.size.height)];
			[nowPlayingControls setHidden:YES];
			[ringerButton setHidden:NO];
		} else {
			[expandButton setFrame:CGRectMake(self.frame.size.width - 46, 216, 36, 18)];
			[vibrateButton setFrame:CGRectMake(10, 214, vibrateButton.frame.size.width, vibrateButton.frame.size.height)];
			[ringerButton setHidden:YES];
		}
		[vibrateButton setHidden:NO];
		
		[expandButton setTransform:CGAffineTransformMakeRotation(deg2rad(180))];
	} else {
		if (self.isShowingMediaControls) {
			[nowPlayingControls setHidden:NO];
			[vibrateButton setHidden:YES];
		}
		[ringerButton setHidden:YES];
		
		[expandButton setFrame:CGRectMake(self.frame.size.width - 46, 10, 36, 18)];
		[expandButton setTransform:CGAffineTransformIdentity];
	}
	
	[UIView animateWithDuration:0.3 animations:^{
		[self setEasingFunction:easeInOutExpo forKeyPath:@"frame"];
		
		if (isExpanded) {
			if (self.isShowingMediaControls) {
				[self setBounds:CGRectMake(0, 0, screenWidth, 190)];
			} else {
				[self setBounds:CGRectMake(0, 0, screenWidth, 244)];
			}
		} else {
			if (self.isShowingMediaControls) {
				[self setBounds:CGRectMake(0, 0, screenWidth, 220)];
			} else {
				[self setBounds:CGRectMake(0, 0, screenWidth, 100)];
			}
		}
	} completion:^(BOOL finished){
		[self removeEasingFunctionForKeyPath:@"frame"];
	}];
	
	[ringerVolumeView updateVolumeDisplay];
	[mediaVolumeView updateVolumeDisplay];
	[headphoneVolumeView updateVolumeDisplay];
	
	[self resetSlideOutTimer];
}

- (void)setIsShowingMediaControls:(BOOL)isShowingMediaControls {
	_isShowingMediaControls = isShowingMediaControls;
	
	if (isShowingMediaControls) {
		[ringerVolumeView setHidden:YES];
		
		if (!self.isExpanded) {
			[nowPlayingControls setHidden:NO];
			[vibrateButton setHidden:YES];
		} else {
			[nowPlayingControls setHidden:YES];
			[vibrateButton setHidden:NO];
		}
		
		[mediaVolumeView setFrame:CGRectMake(0, 0, screenWidth, 100)];
		[headphoneVolumeView setFrame:CGRectMake(0, 0, screenWidth, 100)];
	} else {
		[ringerVolumeView setHidden:NO];
		[nowPlayingControls setHidden:YES];
		
		[mediaVolumeView setFrame:CGRectMake(0, 110, screenWidth, 100)];
		[headphoneVolumeView setFrame:CGRectMake(0, 110, screenWidth, 100)];
		
		[vibrateButton setHidden:NO];
	}
	
	[mediaVolumeView setHidden:self.isShowingHeadphoneVolume];
	[headphoneVolumeView setHidden:!self.isShowingHeadphoneVolume];
	
	[mediaSlider setValue:[[RSSoundController sharedInstance] mediaVolume]];
	[mediaVolumeView setVolumeValue:[[RSSoundController sharedInstance] mediaVolume]];
	
	[headphoneSlider setValue:[[RSSoundController sharedInstance] mediaVolume]];
	[headphoneVolumeView setVolumeValue:[[RSSoundController sharedInstance] mediaVolume]];
	
	[UIView animateWithDuration:0.3 animations:^{
		[self setEasingFunction:easeInOutExpo forKeyPath:@"frame"];
		
		if (isShowingMediaControls) {
			if (self.isExpanded) {
				[self setBounds:CGRectMake(0, 0, screenWidth, 190)];
			} else {
				[self setBounds:CGRectMake(0, 0, screenWidth, 220)];
			}
		} else {
			if (self.isExpanded) {
				[self setBounds:CGRectMake(0, 0, screenWidth, 244)];
			} else {
				[self setBounds:CGRectMake(0, 0, screenWidth, 100)];
			}
		}
	} completion:^(BOOL finished){
		[self removeEasingFunctionForKeyPath:@"frame"];
	}];
	
	if ([[RSSoundController sharedInstance] isShowingVolumeHUD]) {
		[self resetSlideOutTimer];
	}
}

- (void)setIsShowingHeadphoneVolume:(BOOL)isShowingHeadphoneVolume {
	_isShowingHeadphoneVolume = isShowingHeadphoneVolume;
	
	if (isShowingHeadphoneVolume) {
		if (!self.isShowingMediaControls) {
			[mediaVolumeView setHidden:YES];
			[headphoneVolumeView setHidden:NO];
		}
	} else {
		if (self.isShowingMediaControls) {
			[ringerVolumeView setHidden:NO];
			[mediaVolumeView setHidden:YES];
			[headphoneVolumeView setHidden:YES];
		} else {
			[mediaVolumeView setHidden:NO];
			[headphoneVolumeView setHidden:YES];
		}
	}
	
	[mediaSlider setValue:[[RSSoundController sharedInstance] mediaVolume]];
	[mediaVolumeView setVolumeValue:[[RSSoundController sharedInstance] mediaVolume]];
	
	[headphoneSlider setValue:[[RSSoundController sharedInstance] mediaVolume]];
	[headphoneVolumeView setVolumeValue:[[RSSoundController sharedInstance] mediaVolume]];
	
	if ([[RSSoundController sharedInstance] isShowingVolumeHUD]) {
		[self resetSlideOutTimer];
	}
}

#pragma mark Volume Changes

- (void)updateVolume {
	float ringerVolume = [[RSSoundController sharedInstance] ringerVolume];
	float mediaVolume = [[RSSoundController sharedInstance] mediaVolume];
	
	[ringerSlider setValue:ringerVolume];
	[ringerVolumeView setVolumeValue:ringerVolume];
	
	[mediaSlider setValue:mediaVolume];
	[mediaVolumeView setVolumeValue:mediaVolume];
	
	[headphoneSlider setValue:mediaVolume];
	[headphoneVolumeView setVolumeValue:mediaVolume];
	
	if ([[RSSoundController sharedInstance] isPlaying]) {
		[ringerVolumeView setHidden:YES];
		
		if (self.isShowingHeadphoneVolume) {
			[mediaVolumeView setHidden:YES];
			[headphoneVolumeView setHidden:NO];
		} else {
			[mediaVolumeView setHidden:NO];
			[headphoneVolumeView setHidden:YES];
		}
	} else {
		[ringerVolumeView setHidden:NO];
		
		if (self.isShowingMediaControls) {
			[mediaVolumeView setHidden:YES];
			[headphoneVolumeView setHidden:YES];
		} else {
			if (self.isShowingHeadphoneVolume) {
				[mediaVolumeView setHidden:YES];
				[headphoneVolumeView setHidden:NO];
			} else {
				[mediaVolumeView setHidden:NO];
				[headphoneVolumeView setHidden:YES];
			}
		}
	}
	
	if (ringerVolume >= 1.0/16.0) {
		[[objc_getClass("SBMediaController") sharedInstance] setRingerMuted:NO];
		[ringerMuteButton setTitle:@"\uEA8F"];
	} else {
		[[objc_getClass("SBMediaController") sharedInstance] setRingerMuted:YES];
		
		if ([self getVibrationEnabled]) {
			[ringerMuteButton setTitle:@"\uE877"];
		} else {
			[ringerMuteButton setTitle:@"\uE7ED"];
		}
	}
	
	if (mediaVolume >= 1.0/16.0) {
		[mediaMuteButton setTitle:@"\uE767"];
	} else {
		[mediaMuteButton setTitle:@"\uE74F"];
	}
	
	[ringerVolumeView updateVolumeDisplay];
	[mediaVolumeView updateVolumeDisplay];
	[headphoneVolumeView updateVolumeDisplay];
}

- (void)ringerVolumeChanged {
	[self resetSlideOutTimer];
	
	float ringerVolume = [[NSString stringWithFormat:@"%.04f", [ringerSlider currentValue]] floatValue];
	ringerVolume = roundf(ringerVolume * 16) / 16;
	
	if (ringerVolume >= 1.0/16.0) {
		[[objc_getClass("AVSystemController") sharedAVSystemController] setVolumeTo:ringerVolume forCategory:@"Ringtone"];
		[[objc_getClass("SBMediaController") sharedInstance] setRingerMuted:NO];
		[ringerMuteButton setTitle:@"\uEA8F"];
	} else {
		[[objc_getClass("SBMediaController") sharedInstance] setRingerMuted:YES];
		[[RSSoundController sharedInstance] volumeChanged:0.0 forCategory:@"Ringtone" increasingVolume:NO];
		[[objc_getClass("AVSystemController") sharedAVSystemController] setVolumeTo:0.0 forCategory:@"Ringtone"];
		
		if ([self getVibrationEnabled]) {
			[ringerMuteButton setTitle:@"\uE877"];
		} else {
			[ringerMuteButton setTitle:@"\uE7ED"];
		}
	}
	
	[[RSSoundController sharedInstance] setRingerVolume:ringerVolume];
	
	[ringerVolumeView setVolumeValue:ringerVolume];
	[ringerVolumeView updateVolumeDisplay];
}

- (void)mediaVolumeChanged {
	[self resetSlideOutTimer];
	
	float mediaVolume = [[NSString stringWithFormat:@"%.04f", [mediaSlider currentValue]] floatValue];
	mediaVolume = roundf(mediaVolume * 16) / 16;
	
	[[objc_getClass("AVSystemController") sharedAVSystemController] setVolumeTo:mediaVolume forCategory:@"Audio/Video"];
	
	if (mediaVolume >= 1.0/16.0) {
		[mediaMuteButton setTitle:@"\uE767"];
	} else {
		[mediaMuteButton setTitle:@"\uE74F"];
	}
	
	[[RSSoundController sharedInstance] setMediaVolume:mediaVolume];
	
	[mediaVolumeView setVolumeValue:mediaVolume];
	[mediaVolumeView updateVolumeDisplay];
}

- (void)headphoneVolumeChanged {
	[self resetSlideOutTimer];
	
	float headphoneVolume = [[NSString stringWithFormat:@"%.04f", [headphoneSlider currentValue]] floatValue];
	headphoneVolume = roundf(headphoneVolume * 16) / 16;
	
	[[objc_getClass("AVSystemController") sharedAVSystemController] setVolumeTo:headphoneVolume forCategory:@"Audio/Video"];
	
	[[RSSoundController sharedInstance] setMediaVolume:headphoneVolume];
	
	[headphoneVolumeView setVolumeValue:headphoneVolume];
	[headphoneVolumeView updateVolumeDisplay];
}

#pragma mark Mute Buttons

- (void)toggleRingerMuted {
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
	
	[self updateRingerButtonStatus];
}

- (void)toggleMediaMuted {
	if ([[RSSoundController sharedInstance] mediaVolume] >= 1.0/16.0) {
		[[RSSoundController sharedInstance] volumeChanged:0.0 forCategory:@"Audio/Video" increasingVolume:NO];
		[[objc_getClass("AVSystemController") sharedAVSystemController] setVolumeTo:0.0 forCategory:@"Audio/Video"];
	} else {
		[[RSSoundController sharedInstance] volumeChanged:1.0/16.0 forCategory:@"Audio/Video" increasingVolume:YES];
		[[objc_getClass("AVSystemController") sharedAVSystemController] setVolumeTo:1.0/16.0 forCategory:@"Audio/Video"];
	}
}

#pragma mark Vibration State

- (BOOL)getVibrationEnabled {
	if ([[objc_getClass("SBMediaController") sharedInstance] isRingerMuted]) {
		BOOL silentVibrate = [[[NSUserDefaults standardUserDefaults] objectForKey:@"silent-vibrate"] boolValue];
		[[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:silentVibrate] forKey:@"ring-vibrate"];
		
		return silentVibrate;
	} else {
		BOOL ringerVibrate = [[[NSUserDefaults standardUserDefaults] objectForKey:@"ring-vibrate"] boolValue];
		[[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:ringerVibrate] forKey:@"silent-vibrate"];
		
		return ringerVibrate;
	}
	
	return NO;
}

- (void)toggleVibrationEnabled {
	if ([[objc_getClass("SBMediaController") sharedInstance] isRingerMuted]) {
		BOOL silentVibrate = [[[NSUserDefaults standardUserDefaults] objectForKey:@"silent-vibrate"] boolValue];
		[[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:!silentVibrate] forKey:@"silent-vibrate"];
		[[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:!silentVibrate] forKey:@"slient-vibrate"];
		
	} else {
		BOOL ringerVibrate = [[[NSUserDefaults standardUserDefaults] objectForKey:@"ring-vibrate"] boolValue];
		[[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:!ringerVibrate] forKey:@"ring-vibrate"];
		[[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:!ringerVibrate] forKey:@"ring-vibrate"];
	}
	
	[self updateVibrateButtonStatus];
	[self resetSlideOutTimer];
}

- (void)updateVibrateButtonStatus {
	[vibrateButton setFrame:CGRectMake(10, 214, self.frame.size.width/2 - 10, 20)];
	
	[UIView performWithoutAnimation:^{
		if ([self getVibrationEnabled]) {
			NSString* baseString = [NSString stringWithFormat:@"\uE877 %@", [RSAesthetics localizedStringForKey:@"VIBRATE_ENABLED"]];
			NSMutableAttributedString* attributedString = [[NSMutableAttributedString alloc] initWithString:baseString];
			
			[attributedString addAttributes:@{
											  NSFontAttributeName:[UIFont fontWithName:@"SegoeMDL2Assets" size:14],
											  NSForegroundColorAttributeName: [RSAesthetics accentColor],
											  NSBaselineOffsetAttributeName: @-3.0
											  } range:[baseString rangeOfString:@"\uE877"]];
			[attributedString addAttributes:@{
											  NSFontAttributeName:[UIFont fontWithName:@"SegoeUI" size:14],
											  NSForegroundColorAttributeName: [RSAesthetics accentColor]
											  } range:[baseString rangeOfString:[RSAesthetics localizedStringForKey:@"VIBRATE_ENABLED"]]];
			[vibrateButton setAttributedTitle:attributedString forState:UIControlStateNormal];
		} else {
			NSString* baseString = [NSString stringWithFormat:@"\uE877 %@", [RSAesthetics localizedStringForKey:@"VIBRATE_DISABLED"]];
			NSMutableAttributedString* attributedString = [[NSMutableAttributedString alloc] initWithString:baseString];
			
			[attributedString addAttributes:@{
											  NSFontAttributeName:[UIFont fontWithName:@"SegoeMDL2Assets" size:14],
											  NSForegroundColorAttributeName: [UIColor whiteColor],
											  NSBaselineOffsetAttributeName: @-3.0
											  } range:[baseString rangeOfString:@"\uE877"]];
			[attributedString addAttributes:@{
											  NSFontAttributeName:[UIFont fontWithName:@"SegoeUI" size:14],
											  NSForegroundColorAttributeName: [UIColor whiteColor]
											  } range:[baseString rangeOfString:[RSAesthetics localizedStringForKey:@"VIBRATE_DISABLED"]]];
			[vibrateButton setAttributedTitle:attributedString forState:UIControlStateNormal];
		}
		
		[vibrateButton layoutIfNeeded];
	}];
	
	CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), CFSTR("com.apple.springboard.silent-vibrate.changed"), NULL, NULL, TRUE);
	CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), CFSTR("com.apple.springboard.ring-vibrate.changed"), NULL, NULL, TRUE);
	
	[vibrateButton sizeToFit];
	
	if (self.isShowingMediaControls) {
		[vibrateButton setFrame:CGRectMake(10, 110, vibrateButton.frame.size.width, 20)];
	} else {
		[vibrateButton setFrame:CGRectMake(10, 214, vibrateButton.frame.size.width, 20)];
	}
	
	if ([[RSSoundController sharedInstance] ringerVolume] >= 1.0/16.0) {
		[ringerMuteButton setTitle:@"\uEA8F"];
	} else if ([self getVibrationEnabled]) {
		[ringerMuteButton setTitle:@"\uE877"];
	} else {
		[ringerMuteButton setTitle:@"\uE7ED"];
	}
}

- (void)updateRingerButtonStatus {
	[ringerButton setFrame:CGRectMake(self.frame.size.width/2, 214, self.frame.size.width/2 - 10, 20)];
	
	SBMediaController* mediaController = [objc_getClass("SBMediaController") sharedInstance];
	
	[UIView performWithoutAnimation:^{
		if (![mediaController isRingerMuted]) {
			NSString* baseString = [NSString stringWithFormat:@"\uEA8F %@", [RSAesthetics localizedStringForKey:@"RINGER_ENABLED"]];
			NSMutableAttributedString* attributedString = [[NSMutableAttributedString alloc] initWithString:baseString];
			
			[attributedString addAttributes:@{
											  NSFontAttributeName:[UIFont fontWithName:@"SegoeMDL2Assets" size:14],
											  NSForegroundColorAttributeName: [RSAesthetics accentColor],
											  NSBaselineOffsetAttributeName: @-3.0
											  } range:[baseString rangeOfString:@"\uEA8F"]];
			[attributedString addAttributes:@{
											  NSFontAttributeName:[UIFont fontWithName:@"SegoeUI" size:14],
											  NSForegroundColorAttributeName: [RSAesthetics accentColor]
											  } range:[baseString rangeOfString:[RSAesthetics localizedStringForKey:@"RINGER_ENABLED"]]];
			[ringerButton setAttributedTitle:attributedString forState:UIControlStateNormal];
		} else {
			NSString* baseString = [NSString stringWithFormat:@"\uE7ED %@", [RSAesthetics localizedStringForKey:@"RINGER_DISABLED"]];
			NSMutableAttributedString* attributedString = [[NSMutableAttributedString alloc] initWithString:baseString];
			
			[attributedString addAttributes:@{
											  NSFontAttributeName:[UIFont fontWithName:@"SegoeMDL2Assets" size:14],
											  NSForegroundColorAttributeName: [UIColor whiteColor],
											  NSBaselineOffsetAttributeName: @-3.0
											  } range:[baseString rangeOfString:@"\uE7ED"]];
			[attributedString addAttributes:@{
											  NSFontAttributeName:[UIFont fontWithName:@"SegoeUI" size:14],
											  NSForegroundColorAttributeName: [UIColor whiteColor]
											  } range:[baseString rangeOfString:[RSAesthetics localizedStringForKey:@"RINGER_DISABLED"]]];
			[ringerButton setAttributedTitle:attributedString forState:UIControlStateNormal];
		}
		
		[ringerButton layoutIfNeeded];
	}];
	
	[ringerButton sizeToFit];
	
	[ringerButton setFrame:CGRectMake(self.frame.size.width - ringerButton.frame.size.width - 10, 110, ringerButton.frame.size.width, 20)];
	if (self.isShowingMediaControls) {
		[ringerButton setHidden:NO];
	} else {
		[ringerButton setHidden:YES];
	}
}

@end
