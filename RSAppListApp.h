//
//  RSAppListApp.h
//  
//
//  Created by Janik Schmidt on 07.08.16.
//
//

#import <UIKit/UIKit.h>

@interface RSAppListApp : UITableViewCell {
    UIImageView* _appImage;
    UIView* _appImageTile;
    UILabel* _appTitle;
    NSString* _bundleIdentifier;
}

@property (retain) NSString* bundleIdentifier;

-(id)initWithFrame:(CGRect)frame withApp:(LSApplicationProxy*)app;
-(void)updateTileColor;

@end
