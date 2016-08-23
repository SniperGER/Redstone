//
//  RSAppList.h
//  
//
//  Created by Janik Schmidt on 07.08.16.
//
//

#import <UIKit/UIKit.h>

@interface RSAppList : UITableViewController <UITableViewDelegate, UITableViewDataSource> {
    NSDictionary* _appData;
}

@property (retain) RSRootScrollView* parentRootScrollView;

-(void)resetAppVisibility;

@end
