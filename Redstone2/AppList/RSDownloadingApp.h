/**
 @class RSDownloadingApp
 @author Sniper_GER
 @discussion A subclass of RSApp that shows the current download progress
 */

#import <UIKit/UIKit.h>

@class RSApp, RSProgressBar;

@interface RSDownloadingApp : RSApp {
	RSProgressBar* progressBar;
}

- (void)setDownloadProgress:(float)progress forState:(int)state;

@end
