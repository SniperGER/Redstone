//
//  RSAppListTable.m
//  Redstone
//
//  Created by Janik Schmidt on 03.08.16.
//  Copyright © 2016 FESTIVAL Development. All rights reserved.
//

#import "Headers.h"
#import "CAKeyframeAnimation+AHEasing.h"

@implementation RSAppListTable

NSMutableArray* appListSections;

-(UITableView *)makeTableView
{
    CGFloat x = self.view.frame.size.width;
    CGFloat y = 80;
    CGFloat width = self.view.frame.size.width;
    CGFloat height = [[UIScreen mainScreen] bounds].size.height-80;
    CGRect tableFrame = CGRectMake(x, y, width, height);
    
    UITableView *tableView = [[UITableView alloc]initWithFrame:tableFrame style:UITableViewStylePlain];
    
    tableView.backgroundColor = [UIColor colorWithWhite:0 alpha:0];
    tableView.contentInset = UIEdgeInsetsMake(0, 0, 80, 0);
    tableView.rowHeight = 54;
    tableView.sectionHeaderHeight = 60;
    tableView.scrollEnabled = YES;
    tableView.showsVerticalScrollIndicator = NO;
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    tableView.userInteractionEnabled = YES;
    tableView.bounces = YES;
    
    tableView.delegate = self;
    //tableView.dataSource = self;
    
    return tableView;
}

-(void)viewDidLoad {
    [super viewDidLoad];
    _appData = [self getInstalledApps:NO];
    
    appListSections = [[NSMutableArray alloc] init];
    
    self.tableView = [self makeTableView];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    NSInteger sections = 0;
    
    NSString *alphabet = @"ABCDEFGHIJKLMNOPQRSTUVWXYZ";
    for (int i=0; i<26; i++) {
        NSString *letter = [alphabet substringWithRange:NSMakeRange(i, 1)];
        if ([[_appData mutableArrayValueForKey:letter] count] > 0) {
            sections++;
        }
    }
    
    return sections;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSMutableArray* sectionsWithApps = [[NSMutableArray alloc] init];
    NSString *alphabet = @"ABCDEFGHIJKLMNOPQRSTUVWXYZ";
    for (int i=0; i<26; i++) {
        NSString *letter = [alphabet substringWithRange:NSMakeRange(i, 1)];
        if ([[_appData mutableArrayValueForKey:letter] count] > 0) {
            [sectionsWithApps addObject:letter];
        }
    }
    
    return [sectionsWithApps objectAtIndex:section];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSMutableArray* sectionsWithApps = [[NSMutableArray alloc] init];
    NSString *alphabet = @"ABCDEFGHIJKLMNOPQRSTUVWXYZ";
    for (int i=0; i<26; i++) {
        NSString *letter = [alphabet substringWithRange:NSMakeRange(i, 1)];
        if ([[_appData mutableArrayValueForKey:letter] count] > 0) {
            [sectionsWithApps addObject:[_appData mutableArrayValueForKey:letter]];
        }
    }
    
    return [[sectionsWithApps objectAtIndex:section] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSMutableArray* sectionsWithApps = [[NSMutableArray alloc] init];
    NSString *alphabet = @"ABCDEFGHIJKLMNOPQRSTUVWXYZ";
    for (int i=0; i<26; i++) {
        NSString *letter = [alphabet substringWithRange:NSMakeRange(i, 1)];
        if ([[_appData mutableArrayValueForKey:letter] count] > 0) {
            [sectionsWithApps addObject:[_appData mutableArrayValueForKey:letter]];
        }
    }
    
    NSArray* activeSection = [sectionsWithApps objectAtIndex:[indexPath section]];

    
    RSApp* cell = [[RSApp alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, 50)
                                       withApp:[activeSection objectAtIndex:[indexPath row]]];
    
    cell.backgroundColor = [UIColor clearColor];
    cell.backgroundView = nil;
    
    UIView *bgColorView = [[UIView alloc] init];
    bgColorView.backgroundColor = [UIColor colorWithWhite:1 alpha:0.2];
    [cell setSelectedBackgroundView:bgColorView];
    
    return cell;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    NSMutableArray* sectionsWithApps = [[NSMutableArray alloc] init];
    NSString *alphabet = @"ABCDEFGHIJKLMNOPQRSTUVWXYZ";
    for (int i=0; i<26; i++) {
        NSString *letter = [alphabet substringWithRange:NSMakeRange(i, 1)];
        if ([[_appData mutableArrayValueForKey:letter] count] > 0) {
            [sectionsWithApps addObject:letter];
        }
    }
    
    RSAppListSection* appSection = [[RSAppListSection alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, 60)];
    [appSection.sectionTitle setText:[sectionsWithApps objectAtIndex:section]];
    [appListSections addObject: appSection];
    
    return appSection;
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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    //show the second view..
    RSApp* tappedTile = [tableView cellForRowAtIndexPath:indexPath];
    [self triggerAppLaunch:tappedTile.appIdentifier sender:tappedTile];
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

-(void)triggerAppLaunch:(NSString*)applicationIdentifier sender:(RSApp*)sender {
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
    
    NSMutableArray* visibleTiles = [[NSMutableArray alloc] init];
    NSMutableArray* invisibleTiles = [[NSMutableArray alloc] init];
    
    for (int i=0; i<[appListSections count]; i++) {
        if (CGRectIntersectsRect(self.view.bounds, [(UIView*)[appListSections objectAtIndex:i] frame])) {
            [visibleTiles addObject:[appListSections objectAtIndex:i]];
            
            for (int j=0; j<(int)[self.tableView numberOfRowsInSection:i]; j++) {
                RSApp* cell = (RSApp*)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:j inSection:i]];
                if (cell == nil) {
                    break;
                }
                
                if (CGRectIntersectsRect(self.view.bounds, [cell frame])) {
                    [visibleTiles addObject:cell];
                } else {
                    [invisibleTiles addObject:cell];
                }
            }
        } else {
            [invisibleTiles addObject:[appListSections objectAtIndex:i]];
        }
    }
    
    for (UIView* view in invisibleTiles) {
        [view setHidden:true];
    }
    
    for (UIView* view in visibleTiles) {
        CGPoint basePoint = [view convertPoint:[view bounds].origin toView:self.view];
        
        float layerX = -(basePoint.x-CGRectGetMidX(self.view.bounds))/view.frame.size.width;
        float layerY = -(basePoint.y-CGRectGetMidY(self.view.bounds))/view.frame.size.height;
        
        view.center = CGPointMake(CGRectGetMidX(self.view.bounds), CGRectGetMidY(self.view.bounds));
        view.layer.anchorPoint = CGPointMake(layerX, layerY);
        
        float delay = 0.01*(int)[visibleTiles indexOfObject:view];
        
        scale.beginTime = CACurrentMediaTime()+delay;
        opacity.beginTime = CACurrentMediaTime()+delay;
        
        if (view == sender) {
            scale.beginTime = CACurrentMediaTime()+delay+0.02;
            opacity.beginTime = CACurrentMediaTime()+delay+0.015;
        }
        
        [view.layer addAnimation:scale forKey:@"scale"];
        [view.layer addAnimation:opacity forKey:@"opacity"];
    }
    
    float delayInSeconds = 0.01*(int)[visibleTiles count] + 0.3;
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.parentRootScrollView showLaunchImage:sender.appIdentifier];
    });
}

-(NSDictionary*)getInstalledApps:(BOOL)listHiddenApps {
    NSMutableDictionary* installedApps = [[NSMutableDictionary alloc] init];
    
    
    NSString *alphabet = @"ABCDEFGHIJKLMNOPQRSTUVWXYZ";
    for (int x = 0; x < 26; x++) {
        NSString *letter = [alphabet substringWithRange:NSMakeRange(x, 1)];
        [installedApps setObject:[NSMutableArray array] forKey:letter];
    }
    
    NSArray *_apps = [[objc_getClass("LSApplicationWorkspace") defaultWorkspace] allInstalledApplications];
    for (LSApplicationProxy *app in _apps)
    {
        NSString *first = [[[app localizedName] substringWithRange:NSMakeRange(0, 1)] uppercaseString];
        
        NSString *bundlePath = app.bundleURL.path;
        NSBundle* appBundle = [NSBundle bundleWithPath:bundlePath];
        NSArray* appTags = [[appBundle infoDictionary] objectForKey:@"SBAppTags"];
        NSString *appIdentifier = app.bundleIdentifier;
        
        
        
        if (appTags == nil || (appTags != nil && (int)[appTags indexOfObject:@"hidden"] != -1 && listHiddenApps)) {
            if (![appIdentifier isEqualToString:@"com.apple.webapp"] && ![appIdentifier isEqualToString:@"com.apple.webapp1"]) {
               [[installedApps objectForKey:first] addObject:app];
            }
        }
    }
    
    return installedApps;
}

@end
