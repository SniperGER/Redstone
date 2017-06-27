#import "TemplateClass.h"

@implementation TemplateClass

- (id)initWithFrame:(CGRect)frame tile:(RSTile *)tile {
	if (self = [super initWithFrame:frame]) {
		self.tile = tile;
		
		// Initialize your live tile here
	}
	
	return self;
}

// If your live tile has asynchronous loading, store the loading progress in a variable
// Return that progress here, else return YES
- (BOOL)readyForDisplay {
	return YES;
}

// Perform any manual update
- (void)update {
	
}

// If your live tile relies on automatic updates, return the interval value here
// If not, return anything less than 1
// Interval is measured in seconds
- (CGFloat)updateInterval {
	return 0;
}

// If your live tile has multiple pages (like the weather live tile),
// return an array either for all sizes or for a specific size containing
// every page to be displayed for that size. Return an empty array or nil
// if otherwise
- (NSArray *)viewsForSize:(int)size {
	return nil;
}

/*
 // Only override triggerAnimation if you want your live tile to have custom animations.
 // Animations are triggered by the tile container
 - (void)triggerAnimation {
 
 }
 */

@end
