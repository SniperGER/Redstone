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


/**
 Sets the download state and progress of a downloading app

 @param progress The current download progress. A float between 0 and 1.
 @param state The current download state.
 */
- (void)setDownloadProgress:(float)progress forState:(int)state;

@end
