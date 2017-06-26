#import "../Redstone.h"

@implementation RSVolumeView

- (id)initWithFrame:(CGRect)frame forCategory:(NSString *)_category {
	if (self = [super initWithFrame:frame]) {
		category = _category;
		
		categoryLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, screenWidth-20, 20)];
		[categoryLabel setFont:[UIFont fontWithName:@"SegoeUI" size:15]];
		[categoryLabel setTextColor:[UIColor whiteColor]];
		[self addSubview:categoryLabel];
		
		volumeValueLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.frame.size.width - 51, 31, 36, 36)];
		[volumeValueLabel setFont:[UIFont fontWithName:@"SegoeUI-Light" size:32]];
		[volumeValueLabel setTextAlignment:NSTextAlignmentCenter];
		[volumeValueLabel setTextColor:[UIColor whiteColor]];
		[volumeValueLabel setText:@"--"];
		[self addSubview:volumeValueLabel];
		
		[self updateVolumeDisplay];
	}
	
	return self;
}

- (void)updateVolumeDisplay {
	if ([category isEqualToString:@"Ringtone"]) {
		if ([[objc_getClass("SBMediaController") sharedInstance] isRingerMuted] && ![[[RSSoundController sharedInstance] volumeHUD] isExpanded]) {
			[categoryLabel setText:[RSAesthetics localizedStringForKey:@"RINGER_VOLUME_VIBRATION"]];
		} else {
			[categoryLabel setText:[RSAesthetics localizedStringForKey:@"RINGER_VOLUME_ENABLED"]];
		}
	} else if ([category isEqualToString:@"Audio/Video"]) {
		[categoryLabel setText:[RSAesthetics localizedStringForKey:@"MEDIA_VOLUME"]];
	} else if ([category isEqualToString:@"Headphones"]) {
		[categoryLabel setText:[RSAesthetics localizedStringForKey:@"HEADPHONE_VOLUME"]];
	}
}

- (void)setVolumeValue:(float)volume {
	[volumeValueLabel setText:[NSString stringWithFormat:@"%02.00f", (volume * 16.0)]];
}

@end
