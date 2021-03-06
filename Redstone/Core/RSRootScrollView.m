#import "../Redstone.h"

@implementation RSRootScrollView

- (id)initWithFrame:(CGRect)frame {
	self = [super initWithFrame:frame];
	
	if (self) {
		[self setDelegate:self];
		
		[self setContentSize:CGSizeMake(screenWidth*2, screenHeight)];
		[self setPagingEnabled:YES];
		[self setBounces:NO];
		[self setDelaysContentTouches:NO];
		
		[self setShowsVerticalScrollIndicator:NO];
		[self setShowsHorizontalScrollIndicator:NO];
	}
	
	return self;
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
	[[[RSAppListController sharedInstance] searchBar] resignFirstResponder];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
	CGFloat progress = MIN(scrollView.contentOffset.x / scrollView.frame.size.width, 0.75);
	
	[self setBackgroundColor:[UIColor colorWithWhite:0.0 alpha:progress]];
	[[RSAppListController sharedInstance] updateSectionOverlayPosition];
	[[RSAppListController sharedInstance] setSectionOverlayAlpha:progress];
}

- (UIView *)hitTest:(CGPoint) point withEvent:(UIEvent *)event {
	UIView* view = [super hitTest:point withEvent:event];
	
	if (view == self) {
		return [[[RSStartScreenController sharedInstance] selectedTile] hitTest:point withEvent:event];
	}
	
	return view;
}

- (void)setScrollEnabled:(BOOL)scrollEnabled {
	if ([[[RSStartScreenController sharedInstance] pinnedTiles] count] <= 0) {
		[super setScrollEnabled:NO];
		return;
	}
	
	[super setScrollEnabled:scrollEnabled];
}

@end
