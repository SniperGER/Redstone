//
//  RSAppListTable.h
//  Redstone
//
//  Created by Janik Schmidt on 03.08.16.
//  Copyright © 2016 FESTIVAL Development. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RSAppListSection.h"
#import "RSApp.h"
#import "Headers.h"
#include <objc/runtime.h>

@class Redstone;

@interface RSAppListTable : UITableViewController <UITableViewDataSource, UITableViewDelegate> {
    NSDictionary* _appData;
}

@property (retain) id parentRootScrollView;

@end