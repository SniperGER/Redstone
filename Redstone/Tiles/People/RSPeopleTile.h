#import <UIKit/UIKit.h>
#import <objc/runtime.h>
#import <Contacts/Contacts.h>

#import "../headers/RSLiveTileDelegate.h"
#import "../headers/UIView+Easing.h"

@interface RSPeopleTile : UIView <RSLiveTileDelegate> {
	NSMutableArray* contactFields;
}

@property (nonatomic, strong) RSTile* tile;

@end
