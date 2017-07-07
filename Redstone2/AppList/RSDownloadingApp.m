#import "../Redstone.h"

@implementation RSDownloadingApp

- (id)initWithFrame:(CGRect)frame leafIdentifier:(NSString *)leafIdentifier {
	if (self = [super initWithFrame:frame leafIdentifier:leafIdentifier]) {
		if (self.tileInfo.localizedDisplayName) {
			[appLabel setText:self.tileInfo.localizedDisplayName];
		} else if (self.tileInfo.displayName) {
			[appLabel setText:self.tileInfo.displayName];
		} else {
			[appLabel setText:[self.icon realDisplayName]];
		}
		
		// Progress Bar
		
		progressBar = [[RSProgressBar alloc] initWithFrame:CGRectMake(70, 44, frame.size.width - 85, 6)];
		[progressBar setHidden:YES];
		[self addSubview:progressBar];
	}
	
	return self;
}

- (void)setDownloadProgress:(float)progress forState:(int)state {
	if (state == 0) {
		[[RSAppListController sharedInstance] loadApps];
	} else if (state == 1) {
		
	} else if (state == 2) {
		[progressBar setHidden:NO];
		[progressBar setProgress:progress];
		
		[self setUserInteractionEnabled:NO];
	}
}

@end
