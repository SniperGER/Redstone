#import "RSAppListSection.h"
#import "RSAppListController.h"
#import "RSAesthetics.h"
#import "RSAppList.h"

@implementation RSAppListSection

-(id)initWithFrame:(CGRect)frame letter:(NSString*)letter {
	self = [super initWithFrame:frame];
	
	if (self) {
		[self setClipsToBounds:YES];
		NSUserDefaults* defaults = [[NSUserDefaults alloc] initWithSuiteName:@"ml.festival.redstone"];
		if ([[defaults objectForKey:@"showWallpaper"] boolValue]) {
			[self setBackgroundColor:[UIColor colorWithWhite:0.0 alpha:0.0]];
			/*self->bgImage = [[UIImageView alloc] initWithImage:[RSAesthetics getCurrentHomeWallpaper]];
			[self->bgImage setFrame:CGRectMake(0,-70,[[UIScreen mainScreen] bounds].size.width,[[UIScreen mainScreen] bounds].size.height)];

			[self addSubview:self->bgImage];*/
		} else {
			[self setBackgroundColor:[UIColor blackColor]];
		}
		
		self->displayName = letter;

		self->innerView = [[RSTiltView alloc] initWithFrame:CGRectMake(0,0,self.frame.size.width,self.frame.size.height)];
		self->innerView.transformMultiplierX = 0.25;
		self->innerView.hasHighlight = YES;
		self->innerView.keepsHighlightOnLongPress = YES;
		[self addSubview:self->innerView];

		UILabel* labelView = [[UILabel alloc] initWithFrame:CGRectMake(2,0,self.frame.size.height,self.frame.size.height)];
		[labelView setText:letter];
		[labelView setTextColor:[UIColor whiteColor]];
		[labelView setFont:[UIFont fontWithName:@"SegoeUI-Light" size:30]];
		[labelView setTextAlignment:NSTextAlignmentCenter];

		[self->innerView addSubview:labelView];

		UITapGestureRecognizer* tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapped:)];
		[tap setCancelsTouchesInView:NO];
		[self addGestureRecognizer:tap];
	}
	
	return self;
}

-(void)setFrame:(CGRect)frame {
	[super setFrame:frame];

	/*if (frame.origin.y == [[RSAppListController sharedInstance] appList].contentOffset.y) {
		[self->bgImage setFrame:CGRectMake(0,-70,[[UIScreen mainScreen] bounds].size.width,[[UIScreen mainScreen] bounds].size.height)];
	} else if (frame.origin.y < [[RSAppListController sharedInstance] appList].contentOffset.y) {
		[self->bgImage setFrame:CGRectMake(0,-70+[[RSAppListController sharedInstance] appList].contentOffset.y-self.frame.origin.y,[[UIScreen mainScreen] bounds].size.width,[[UIScreen mainScreen] bounds].size.height)];
	} else {
		[self->bgImage setFrame:CGRectMake(0,-70-self->yCoordinate+[[RSAppListController sharedInstance] appList].contentOffset.y,[[UIScreen mainScreen] bounds].size.width,[[UIScreen mainScreen] bounds].size.height)];
	}*/
}

-(void)tapped:(id)sender {
	[self->innerView setHighlighted:NO];
	[[RSAppListController sharedInstance] showJumpList];
}
-(void)pressed:(id)sender {}

-(void)updatePreferences {
	NSUserDefaults* defaults = [[NSUserDefaults alloc] initWithSuiteName:@"ml.festival.redstone"];
		if ([[defaults objectForKey:@"showWallpaper"] boolValue]) {
			[self setBackgroundColor:[UIColor colorWithWhite:0.0 alpha:0.0]];
			/*self->bgImage = [[UIImageView alloc] initWithImage:[RSAesthetics getCurrentHomeWallpaper]];
			[self->bgImage setFrame:CGRectMake(0,-70,[[UIScreen mainScreen] bounds].size.width,[[UIScreen mainScreen] bounds].size.height)];

			[self addSubview:self->bgImage];*/
		} else {
			[self setBackgroundColor:[UIColor blackColor]];
		}
}

-(NSString*)displayName {
	return self->displayName;
}

-(void)setYCoordinate:(double)y {
	self->yCoordinate = y;
	//[self->bgImage setFrame:CGRectMake(0,-70-self->yCoordinate,[[UIScreen mainScreen] bounds].size.width,[[UIScreen mainScreen] bounds].size.height)];
}

-(double)yCoordinate {
	return self->yCoordinate;
}

@end