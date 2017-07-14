#import <UIKit/UIKit.h>
#import <Contacts/Contacts.h>

#import "../../StartScreen/RSLiveTileInterface.h"
#import "../../Libraries/UIView+Easing.h"

@interface RSPeopleTile : UIView <RSLiveTileInterface> {
	NSMutableArray* contactFields;
}

@property (nonatomic, strong) RSTile* tile;

@end


@interface RSTile : NSObject
@property (nonatomic, assign) int size;
@end
