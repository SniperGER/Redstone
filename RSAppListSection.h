//
//  RSAppListSection.h
//  Redstone
//
//  Created by Janik Schmidt on 02.08.16.
//  Copyright © 2016 FESTIVAL Development. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Redstone;

@interface RSAppListSection : UIView {
    UILabel* _sectionTitle;
}

@property (retain) UILabel* sectionTitle;

@end
