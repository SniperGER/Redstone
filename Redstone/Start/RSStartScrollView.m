#import "../Redstone.h"

@implementation RSStartScrollView

- (id)initWithFrame:(CGRect)frame {
	self = [super initWithFrame:frame];
	
	if (self) {
		[self setContentInset:UIEdgeInsetsMake(24, 0, 70, 0)];
		[self setClipsToBounds:NO];
		[self setShowsVerticalScrollIndicator:NO];
		[self setShowsHorizontalScrollIndicator:NO];
		[self setDelaysContentTouches:NO];
		
		self.allAppsButton = [[RSTiltView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, 60)];
		[self.allAppsButton setHighlightEnabled:YES];
		
		NSString* labelText = [NSString stringWithFormat:@"%@\t\uE0AD", [RSAesthetics localizedStringForKey:@"ALL_APPS"]];
		NSMutableAttributedString * string = [[NSMutableAttributedString alloc] initWithString:labelText];
		
		[string addAttributes:@{
								NSForegroundColorAttributeName: [UIColor whiteColor],
								NSFontAttributeName: [UIFont fontWithName:@"SegoeUI" size:18]
								} range:[labelText rangeOfString:[RSAesthetics localizedStringForKey:@"ALL_APPS"]]];
		[string addAttributes:@{
								NSForegroundColorAttributeName: [UIColor whiteColor],
								NSFontAttributeName: [UIFont fontWithName:@"SegoeMDL2Assets" size:18],
								NSBaselineOffsetAttributeName: @-3.0
								}range:[labelText rangeOfString:@"\uE0AD"]];
		[self.allAppsButton.titleLabel setAttributedText:string];
		[self.allAppsButton.titleLabel setTextAlignment:NSTextAlignmentRight];
		[self.allAppsButton addTarget:[^{
			[[[RSCore sharedInstance] rootScrollView] setContentOffset:CGPointMake(screenWidth, 0) animated:YES];
		} copy] action:@selector(invoke)];
		[self addSubview:self.allAppsButton];
	}
	
	return self;
}

- (void)setContentSize:(CGSize)contentSize {
	[super setContentSize:contentSize];
	[self.allAppsButton setFrame:CGRectMake(0,
											contentSize.height + [RSMetrics tileBorderSpacing],
											self.bounds.size.width,
											60)];
}

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {
	if (CGRectContainsPoint(self.frame, point) || [[RSStartScreenController sharedInstance] isEditing]) {
		return YES;
	}
	
	return [super pointInside:point withEvent:event];
}

@end
