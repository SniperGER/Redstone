//
//  RSPasscodeButton.h
//  Redstone
//
//  Created by Janik Schmidt on 24.05.17.
//
//

#import <UIKit/UIKit.h>

@interface RSPasscodeButton : UIView {
	BOOL _isBackspaceButton;
	UILabel* buttonLabel;
}

@property (nonatomic, assign) BOOL isBackspaceButton;
@property (nonatomic, assign) BOOL isReturnButton;

- (void)setButtonLabel:(NSString*)label;
- (NSString*)buttonLabel;

@end
