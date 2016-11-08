#import <Preferences/PSListController.h>

@interface RDSRootListController : PSListController <UIAlertViewDelegate>

-(void)killSpringBoard;
-(void)resetHomeScreenLayout;
-(NSDictionary*)getLocalization;

@end

@interface RSStartScreenController : NSObject

+(id)sharedInstance;
-(void)loadTiles;

@end