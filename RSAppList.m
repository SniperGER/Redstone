//
//  RSAppList.m
//  Threshold
//
//  Created by Janik Schmidt on 30.07.16.
//  Copyright © 2016 FESTIVAL Development. All rights reserved.
//

#import "Headers.h"

@implementation RSAppList

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

-(id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    self.contentInset = UIEdgeInsetsMake(24, 0, 80, 0);
    
    NSDictionary* installedApps = [self getInstalledApps:NO];
    
    float currentHeight = 0;
    NSString *alphabet = @"ABCDEFGHIJKLMNOPQRSTUVWXYZ";
    for (int x = 0; x < 26; x++) {
        NSString *letter = [alphabet substringWithRange:NSMakeRange(x, 1)];
        
        NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"localizedName" ascending:YES];
        NSArray* _sortedApps=[[installedApps mutableArrayValueForKey:letter] sortedArrayUsingDescriptors:@[sort]];
        
        if ([_sortedApps count] > 0) {
            RSAppListSection* section = [[RSAppListSection alloc] initWithFrame:CGRectMake(0, currentHeight, self.frame.size.width, 48)];
            [section.sectionTitle setText:letter];
            currentHeight += 48;
            [self addSubview:section];
            
            for (int i=0; i<[_sortedApps count]; i++) {
                RSApp* app = [[RSApp alloc] initWithFrame:CGRectMake(0, currentHeight, self.frame.size.width, 42)
                                                  withApp:[_sortedApps objectAtIndex:i]];
                //NSLog(@"%@", [(LSApplicationProxy*)[_sortedApps objectAtIndex:i] localizedName]);
                [self addSubview:app];
                currentHeight += 42;
            }
        }
    }
    
    [self setContentSize:CGSizeMake(self.frame.size.width, currentHeight)];
    /*for (NSString* section in installedApps) {
        
        NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"localizedName" ascending:YES];
        NSArray* _sortedApps=[[installedApps mutableArrayValueForKey:section] sortedArrayUsingDescriptors:@[sort]];
        
        NSLog(@"%@",section);
        if ([_sortedApps count] > 0) {
            for (int i=0; i<[_sortedApps count]; i++) {
                NSLog(@"%@", [(LSApplicationProxy*)[_sortedApps objectAtIndex:i] localizedName]);
            }
        }
    }*/
    /*for (LSApplicationProxy* _app in installedApps) {
        int index = (int)[installedApps indexOfObject:_app];
        
        RSApp* app = [[RSApp alloc] initWithFrame:CGRectMake(2, index*42, self.frame.size.width-4, 42) withApp:_app];
        [self addSubview:app];
    }*/
    
    return self;
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
        
        if (appTags == nil || (appTags != nil && (int)[appTags indexOfObject:@"hidden"] != -1 && listHiddenApps)) {
            [[installedApps objectForKey:first] addObject:app];
        }
    }
    
    return installedApps;
}

@end
