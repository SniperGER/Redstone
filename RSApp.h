#import <UIKit/UIKit.h>
#import "CommonHeaders.h"
#import "RSTiltView.h"

@class SBIcon;

@interface RSApp : RSTiltView {

	SBIcon* appIcon;
	UIView* appTileView;
	UIImageView* appImageView;
	NSString* leafIdentifier;
	NSString* displayName;
	NSString* resourcePath;
	UILabel* appName;
	BOOL isWebApp;

}

-(id)initWithFrame:(CGRect)frame leafId:(id)identifier;
-(NSString *)displayName;
-(NSString *)leafIdentifier;
-(SBIcon*)appIcon;
-(void)updateTileColor;

@end