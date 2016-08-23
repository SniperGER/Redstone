#import "CommonHeaders.h"
//#import "RSAppListItem.h"

@class RSAppListScrollView, RSAppListItem;

@interface RSAppListItemContainer : UITableViewCell {
	RSAppListItem* cellInnerView;
	NSString* bundleIdentifier;

	RSAppListScrollView* parentScrollView;
}

-(id)initWithFrame:(CGRect)frame withBundleIdentifier:(NSString*)appBundleIdentifier;
-(RSAppListItem*)getAppListItem;

@end