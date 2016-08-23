#import "CommonHeaders.h"
#import "RSTiltView.h"
#import "RSJumpListView.h"
#import "RSRootScrollView.h"

@interface RSAppListSection : RSTiltView {
	UILabel* sectionTitleLabel;
}

@property (retain) RSRootScrollView* rootScrollView;

-(id)initWithFrame:(CGRect)frame withSectionTitle:(NSString*)sectionTitle;

@end