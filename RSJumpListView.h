#import <UIKit/UIKit.h>
#import "Headers.h"

@interface RSJumpListView : UIScrollView {
    NSMutableDictionary* sections;
    RSAppList* _parentAppListView;
}

@property (retain) RSAppList* parentAppListView;

-(id)initWithFrame:(CGRect)frame withAppList:(RSAppList*)appList;

-(void)setCategoriesWithApps:(NSDictionary*)sectionsWithApps;
-(void)show;
-(void)hide;

@end
