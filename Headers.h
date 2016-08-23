#import <UIKit/UIKit.h>
#include <objc/runtime.h>

/// REQUIRED INTERFACES ///

@interface LSApplicationWorkspace
+ (id)defaultWorkspace;
- (id)allInstalledApplications;
@end

@interface LSApplicationProxy

@property (nonatomic,readonly) NSString * localizedName;
@property (nonatomic,readonly) NSString * applicationIdentifier;
@property (nonatomic,readonly) NSString * vendorName;
@property (nonatomic,readonly) NSString * itemName;
@property (nonatomic,readonly) NSString * bundlePath;
@property (nonatomic,readonly) NSURL * bundleURL;
@property (nonatomic,readonly) NSString * bundleIdentifier;

@end

@interface UIApplication (Undocumented)
- (void) launchApplicationWithIdentifier: (NSString*)identifier suspended: (BOOL)suspended;
@end

@interface SBApplicationController

+(id)sharedInstance;
-(id)applicationWithBundleIdentifier:(id)arg1 ;

@end

@interface SBApplication

- (void)setFlag:(int64_t)flag forActivationSetting:(unsigned)setting;

@end

@interface SBUIController

+(id)sharedInstance;
-(void)activateApplication:(id)arg1 ;

@end

/// ///

@interface RSTileDelegate : NSObject

+(NSArray*)getTileList;

+(NSDictionary*)getTileInformation:(NSString*)bundleIdentifier;
+(NSString*)getGlobalTileAccentColor;
+(NSString*)getIndividualTileAccentColor:(NSString*)bundleIdentifier;

+(BOOL)isTileHidden:(NSString*)bundleIdentifier;

@end



@interface RSAllAppsButton : UIView {
    UILabel* allAppsArrow;
    UILabel* allAppsText;
}

@end



@interface RSApp : UITableViewCell {
    UIImageView* _appImage;
    UIView* _appImageTile;
    UILabel* _appTitle;
    NSString* _appIdentifier;
}

@property (retain) NSString* appIdentifier;

-(id)initWithFrame:(CGRect)frame withApp:(LSApplicationProxy*)app;
-(void)launchApp;

@end



@interface RSAppList : UIScrollView

@end



@interface RSAppListSection : UIView {
    UILabel* _sectionTitle;
}

@property (retain) UILabel* sectionTitle;

@end



@interface RSAppListTable : UITableViewController <UITableViewDataSource, UITableViewDelegate> {
    NSDictionary* _appData;
}

@property (retain) id parentRootScrollView;

@end



@interface RSStartScrollView : UIScrollView {
    NSMutableArray* allTiles;
}

@property (retain) id parentRootScrollView;

+(id)sharedInstance;
-(void)triggerAppLaunch:(NSString*)applicationIdentifier sender:(id)sender;
-(void)appHomescreenAnimation;

@end



@interface RSRootScrollView : UIScrollView <UIScrollViewDelegate> {
    RSStartScrollView* _startScrollView;
    RSAppListTable* appListScrollView;
    UIView* transparentBG;
    UIView* launchBG;
}

@property (retain) RSStartScrollView* startScrollView;

//-(void)didAnimateActivationForApp;
-(void)showLaunchImage:(NSString*)bundleIdentifier;

@end



@interface RSTile : UIView {
    int tileSize;
    RSStartScrollView* parentView;
    //UILabel* appLabel;
    //NSString* applicationIdentifier;
    UIImageView* tileImage;
}

@property float tileX;
@property float tileY;
@property (retain) UILabel* appLabel;
@property (retain) NSString* applicationIdentifier;

-(id)initWithTileSize:(int)tileSize withOptions:(NSDictionary*)options;

@end

