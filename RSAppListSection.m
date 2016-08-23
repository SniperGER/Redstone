#import "RSAppListSection.h"

@implementation RSAppListSection

-(id)initWithFrame:(CGRect)frame withSectionTitle:(NSString*)sectionTitle {
	self = [super initWithFrame:frame];

	sectionTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(2, 0, self.frame.size.width-4, self.frame.size.height)];
    sectionTitleLabel.font = [UIFont fontWithName:@"SegoeUI-Light" size:30];
    sectionTitleLabel.textColor = [UIColor whiteColor];

    [sectionTitleLabel setText:[NSString stringWithString:sectionTitle]];
    [self addSubview:sectionTitleLabel];

    self.hasHighlight = YES;

    _transformAngle = 5;
    _transformMultiplierX = 0.3;
    _transformMultiplierY = 4;

	return self;
}

-(void)tapped:(UITapGestureRecognizer*)sender {
    [super tapped:sender];

    RSJumpListView* jumpListView = self.rootScrollView->jumpListView;
    [jumpListView show];
}

@end