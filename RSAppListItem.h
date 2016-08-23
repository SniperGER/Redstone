#import "CommonHeaders.h"
#import "RSTiltView.h"
#import "RSPinMenu.h"

@class RSAppListScrollView;
#import "RSAppListScrollView.h"

@interface RSAppListItem : RSTiltView {
@public
	RSTiltView* innerView;
	UIView* appImageTile;
	UIImageView* appImage;
	UILabel* appLabel;
	NSString* appBundleIdentifier;
	NSDictionary* tileInfo;

	SBApplication* application;
	SBIconModel* model;

	RSAppListScrollView* parentScrollView;
}

-(id)initWithFrame:(CGRect)frame withBundleIdentifier:(NSString*)bundleIdentifier;
-(void)setTileBackgroundColor:(UIColor*)backgroundColor;

-(void)setParentScrollView:(RSAppListScrollView*)parent;

@end