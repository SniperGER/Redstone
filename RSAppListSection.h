#import <UIKit/UIKit.h>
#import "Headers.h"

@interface RSAppListSection : UIView {
    UILabel* _sectionTitle;
    RSAppList* _parentAppList;
}

@property (retain) UILabel* sectionTitle;
@property (retain) RSAppList* parentAppList;

@end
