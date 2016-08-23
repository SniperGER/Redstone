//
//  RSAppList.m
//  
//
//  Created by Janik Schmidt on 07.08.16.
//
//

#import "Headers.h"
#define contains(str1, str2) ([str1 rangeOfString: str2 ].location != NSNotFound)

@implementation RSAppList

NSMutableArray* appListSections;
NSMutableArray* appListCells;
NSString *alphabet = @"#ABCDEFGHIJKLMNOPQRSTUVWXYZ";

-(UITableView *)makeTableView {
    CGFloat x = [[UIScreen mainScreen] bounds].size.width;
    CGFloat y = 80;
    CGFloat width = [[UIScreen mainScreen] bounds].size.width;
    CGFloat height = [[UIScreen mainScreen] bounds].size.height - 80;
    CGRect tableFrame = CGRectMake(x, y, width, height);
    
    UITableView* tableView = [[UITableView alloc] initWithFrame:tableFrame style:UITableViewStylePlain];
    
    tableView.backgroundColor = [UIColor colorWithWhite:0 alpha:0];
    tableView.contentInset = UIEdgeInsetsMake(0, 0, 80, 0);
    tableView.rowHeight = 54;
    tableView.sectionHeaderHeight = 60;
    tableView.showsVerticalScrollIndicator = NO;
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    tableView.delegate = self;
    
    return tableView;
}

-(void)viewDidLoad {
    [super viewDidLoad];
    
    _appData = [self getInstalledApps:NO];
    appListSections = [[NSMutableArray alloc] init];
    appListCells = [[NSMutableArray alloc] init];
    
    self.tableView = [self makeTableView];
    
    
    
    CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), //center
                                    (void*)self, // observer
                                    onPreferencesChanged, // callback
                                    CFSTR("ml.festival.redstone-PreferencesChanged"), // event name
                                    NULL, // object
                                    CFNotificationSuspensionBehaviorDeliverImmediately);
}

static void onPreferencesChanged(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo) {
    
    [(id)observer updateTileColor];
}

-(void)updateTileColor {
    [appListCells makeObjectsPerformSelector:@selector(updateTileColor)];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSMutableArray* sectionsWithApps = [[NSMutableArray alloc] init];
    for (int i=0; i<28; i++) {
        NSString *letter = [alphabet substringWithRange:NSMakeRange(i, 1)];
        if ([[_appData mutableArrayValueForKey:letter] count] > 0) {
            [sectionsWithApps addObject:[_appData mutableArrayValueForKey:letter]];
        }
    }
    
    NSArray* activeSection = [sectionsWithApps objectAtIndex:[indexPath section]];
    
    
    RSAppListApp* cell = [[RSAppListApp alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, 50)
                                       withApp:[activeSection objectAtIndex:[indexPath row]]];
    
    cell.backgroundColor = [UIColor clearColor];
    cell.backgroundView = nil;
    
    UIView *bgColorView = [[UIView alloc] init];
    bgColorView.backgroundColor = [UIColor colorWithWhite:1 alpha:0.2];
    [cell setSelectedBackgroundView:bgColorView];
    
    [appListCells addObject:cell];
    
    return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    NSInteger sections = 0;
    
    for (int i=0; i<28; i++) {
        NSString *letter = [alphabet substringWithRange:NSMakeRange(i, 1)];
        if ([[_appData mutableArrayValueForKey:letter] count] > 0) {
            sections++;
        }
    }
    
    return sections;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSArray* sectionsWithApps = [self getSectionsWithApps];
    return [sectionsWithApps objectAtIndex:section];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSMutableArray* sectionsWithApps = [[NSMutableArray alloc] init];
    for (int i=0; i<28; i++) {
        NSString *letter = [alphabet substringWithRange:NSMakeRange(i, 1)];
        if ([[_appData mutableArrayValueForKey:letter] count] > 0) {
            [sectionsWithApps addObject:[_appData mutableArrayValueForKey:letter]];
        }
    }
    
    return [[sectionsWithApps objectAtIndex:section] count];
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    NSArray* sectionsWithApps = [self getSectionsWithApps];
    
    RSAppListSection* appSection = [[RSAppListSection alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, 60)];
    [appSection.sectionTitle setText:[sectionsWithApps objectAtIndex:section]];
    if ([[sectionsWithApps objectAtIndex:section] isEqualToString:@""]) {
        [appSection.sectionTitle setFont:[UIFont fontWithName:@"SegoeMDL2Assets" size:24]];
    }
    [appListSections addObject: appSection];
    appSection.parentAppList = self;
    
    return appSection;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    //show the second view..
    RSAppListApp* tappedTile = [tableView cellForRowAtIndexPath:indexPath];
    [self triggerAppLaunch:tappedTile.bundleIdentifier sender:tappedTile];
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (NSArray *)tableView:(UITableView *)tableView visibleCellsInSection:(NSInteger)section
{
    NSPredicate *visibleCellsInSectionPredicate = [NSPredicate predicateWithBlock:^BOOL(UITableViewCell *visibleCell, NSDictionary *bindings) {
        return [tableView indexPathForCell:visibleCell].section == section;
    }];
    return [tableView.visibleCells filteredArrayUsingPredicate:visibleCellsInSectionPredicate];
}

-(NSArray*)getSectionsWithApps {
    NSMutableArray* sectionsWithApps = [[NSMutableArray alloc] init];
    for (int i=0; i<28; i++) {
        NSString *letter = [alphabet substringWithRange:NSMakeRange(i, 1)];
        if ([[_appData mutableArrayValueForKey:letter] count] > 0) {
            [sectionsWithApps addObject:letter];
        }
    }
    
    return sectionsWithApps;
}

-(void)triggerAppLaunch:(NSString*)applicationIdentifier sender:(RSAppListApp*)sender {
    CAAnimation *opacity = [CAKeyframeAnimation animationWithKeyPath:@"opacity"
                                                            function:CubicEaseIn
                                                           fromValue:1.0
                                                             toValue:0.0];
    opacity.duration = 0.25;
    opacity.removedOnCompletion = NO;
    opacity.fillMode = kCAFillModeForwards;
    
    CAAnimation *scale = [CAKeyframeAnimation animationWithKeyPath:@"transform.scale"
                                                          function:CubicEaseIn
                                                         fromValue:1.0
                                                           toValue:4.0];
    scale.duration = 0.3;
    scale.removedOnCompletion = NO;
    scale.fillMode = kCAFillModeForwards;
    
    NSMutableArray* animatableRows = [[NSMutableArray alloc] init];
    for (NSIndexPath* i in [self.tableView indexPathsForVisibleRows])
    {
        RSAppListApp* app = [self.tableView cellForRowAtIndexPath:i];
        if (app != nil && (int)[animatableRows indexOfObject:app] == -1) {
            [animatableRows addObject:app];
        }
    }
    
    for (RSAppListSection* section in appListSections) {
        scale.duration = 0.15;
        [section.layer addAnimation:opacity forKey:@"opacity"];
    }
    
    for (UIView* view in animatableRows) {
        scale.duration = 0.3;
        [view.layer removeAllAnimations];
        
        CGPoint basePoint = [view convertPoint:[view bounds].origin toView:self.view];
        
        float layerX = -(basePoint.x-CGRectGetMidX(self.view.bounds))/view.frame.size.width;
        float layerY = -(basePoint.y-CGRectGetMidY(self.view.bounds))/view.frame.size.height;
        
        view.center = CGPointMake(CGRectGetMidX(self.view.bounds), CGRectGetMidY(self.view.bounds));
        view.layer.anchorPoint = CGPointMake(layerX, layerY);
        
        float delay = 0.01*(int)[animatableRows indexOfObject:view];
        
        scale.beginTime = CACurrentMediaTime()+delay;
        opacity.beginTime = CACurrentMediaTime()+delay;
        
        if (view == sender) {
            scale.beginTime = CACurrentMediaTime()+delay+0.05;
            opacity.beginTime = CACurrentMediaTime()+delay+0.04;
        }
        
        [view.layer addAnimation:scale forKey:@"scale"];
        [view.layer addAnimation:opacity forKey:@"opacity"];
    }
    
    float delayInSeconds = 0.01*(int)[animatableRows count] + 0.3;
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.parentRootScrollView showLaunchImage:sender.bundleIdentifier];
    });
}

-(void)resetAppVisibility {
    for (UIView* view in appListSections) {
        [view setHidden:NO];
        [view.layer setOpacity:1];
        [view.layer removeAllAnimations];
    }
    
    for (UIView* view in appListCells) {
        [view setHidden:NO];
        [view.layer setOpacity:1];
        [view.layer removeAllAnimations];
    }
    
    for (int i=0; i<[appListSections count]; i++) {
        for (int j=0; j<(int)[self.tableView numberOfRowsInSection:i]; j++) {
            RSAppListApp* cell = (RSAppListApp*)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:j inSection:i]];
            [cell setHidden:NO];
            [cell.layer setOpacity:1];
            [cell.layer removeAllAnimations];
        }
    }
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if ([tableView respondsToSelector:@selector(setSeparatorInset:)]) {
        [tableView setSeparatorInset:UIEdgeInsetsZero];
    }
    
    if ([tableView respondsToSelector:@selector(setLayoutMargins:)]) {
        [tableView setLayoutMargins:UIEdgeInsetsZero];
    }
    
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
}

-(NSDictionary*)getInstalledApps:(BOOL)listHiddenApps {
    NSMutableDictionary* installedApps = [[NSMutableDictionary alloc] init];
    
    for (int x = 0; x < 28; x++) {
        NSString *letter = [alphabet substringWithRange:NSMakeRange(x, 1)];
        [installedApps setObject:[NSMutableArray array] forKey:letter];
    }
    
    NSArray *_apps = [[objc_getClass("LSApplicationWorkspace") defaultWorkspace] allInstalledApplications];
    for (LSApplicationProxy *app in _apps)
    {
        NSString *first = [[[app localizedName] substringToIndex:1] uppercaseString];
        
        if (first != nil) {
            NSScanner* scanner = [NSScanner scannerWithString:first];
            BOOL appTitleIsNumber = [scanner scanInt:NULL];
            BOOL appTitleIsSpecialChar = ([alphabet rangeOfString:first].location == NSNotFound);
            
            NSString *appIdentifier = app.bundleIdentifier;
            
            BOOL appIsHidden = [RSTileDelegate isAppHidden:app.bundleIdentifier];
            if (appIsHidden && listHiddenApps) {
                if (appTitleIsNumber) {
                    [[installedApps objectForKey:@"#"] addObject:app];
                } else if (appTitleIsSpecialChar) {
                    [[installedApps objectForKey:@""] addObject:app];
                } else {
                    [[installedApps objectForKey:first] addObject:app];
                }
            } else if (!appIsHidden && ![appIdentifier isEqualToString:@"com.apple.webapp"] && ![appIdentifier isEqualToString:@"com.apple.webapp1"]) {
                if (appTitleIsNumber) {
                    [[installedApps objectForKey:@"#"] addObject:app];
                } else if (appTitleIsSpecialChar) {
                    [[installedApps objectForKey:@""] addObject:app];
                } else {
                    [[installedApps objectForKey:first] addObject:app];
                }
            }
        }
    }
    
    NSMutableDictionary* sortedInstalledApps = [[NSMutableDictionary alloc] init];
    for (NSString* letter in installedApps) {
        NSArray* arrayToSort = [NSArray arrayWithArray:[installedApps objectForKey:letter]];

        NSArray *sortedArray = [arrayToSort sortedArrayUsingComparator:^NSComparisonResult(id a, id b) {
            NSString *first = [(LSApplicationProxy*)a localizedName];
            NSString *second = [(LSApplicationProxy*)b localizedName];
            return [first compare:second];
        }];
        
        [sortedInstalledApps setObject:sortedArray forKey:letter];
    }
    
    [self.parentRootScrollView.jumpListView setCategoriesWithApps:sortedInstalledApps];
    
    return sortedInstalledApps;
}

@end
