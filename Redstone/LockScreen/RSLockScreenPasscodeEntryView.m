#import "../Redstone.h"

@implementation RSLockScreenPasscodeEntryView

- (id)initWithFrame:(CGRect)frame {
	self = [super initWithFrame:frame];
	
	if (self) {
		CGSize buttonSize = CGSizeMake([RSMetrics tileDimensionsForSize:2].width, [RSMetrics tileDimensionsForSize:1].height);
		
		NSString* passcodeLabels = @"123456789 0<";
		for (int i=0; i<4; i++) {
			for (int j=0; j<3; j++) {
				int index = ((i * 3) + (j + 1)) - 1;
				
				if (![[passcodeLabels substringWithRange:NSMakeRange(index, 1)] isEqualToString:@" "]) {
					RSLockScreenPasscodeEntryButton* passcodeButton = [[RSLockScreenPasscodeEntryButton alloc] initWithFrame:CGRectMake(4 + (buttonSize.width+[RSMetrics tileBorderSpacing])*j,
																																		55 + (buttonSize.height+[RSMetrics tileBorderSpacing])*i,
																																		buttonSize.width, buttonSize.height)];
					
					if ([[passcodeLabels substringWithRange:NSMakeRange(index, 1)] isEqualToString:@"<"]) {
						[passcodeButton setIsBackSpaceButton:YES];
					} else {
						[passcodeButton setNumberPadButton:[objc_getClass("SBUIPasscodeLockNumberPad") _buttonForCharacter:index withLightStyle:NO]];
						[passcodeButton setButtonLabelText:[passcodeLabels substringWithRange:NSMakeRange(index, 1)]];
					}
					
					[self addSubview:passcodeButton];
				}
			}
		}
	}
	
	return self;
}

@end
