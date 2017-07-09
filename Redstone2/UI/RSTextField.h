/**
 @class RSTextField
 @author Sniper_GER
 @discussion This class provides a text input field with a Windows 10 Mobile design
 */

#import <UIKit/UIKit.h>

@class RSTiltView;

@interface RSTextField : UITextField <UITextFieldDelegate> {
	RSTiltView* clearButton;
}

@end
