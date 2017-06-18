#import "RSPeopleTile.h"

@implementation RSPeopleTile

- (id)initWithFrame:(CGRect)frame tile:(RSTile *)tile {
	self = [super initWithFrame:frame];
	
	if (self) {
		contactFields = [NSMutableArray new];
		
		CNContactStore *store = [[CNContactStore alloc] init];
		NSPredicate *predicate = [CNContact predicateForContactsInContainerWithIdentifier:store.defaultContainerIdentifier];
		NSArray *cnContacts = [store unifiedContactsMatchingPredicate:predicate keysToFetch:@[CNContactImageDataKey] error:nil];
		
		CGSize circleSize = CGSizeMake(self.frame.size.height/2, self.frame.size.height/2);
		for (int i=0; i<7; i++) {
			NSMutableArray* contactsRow = [NSMutableArray new];
			
			for (int j=0; j<9; j++) {
				UIView* contactView = [[UIView alloc] initWithFrame:CGRectMake(j*circleSize.width - (circleSize.width*3.5), i*circleSize.width - (circleSize.width*2.5), circleSize.width, circleSize.height)];
				[contactView.layer setCornerRadius:circleSize.width/2];
				[contactView setClipsToBounds:YES];
				
				CNContact* contact = [cnContacts objectAtIndex:arc4random_uniform((int)cnContacts.count)];
				UIImage* contactImage = [UIImage imageWithData:contact.imageData];
				
				if (contactImage) {
					CGFloat factor = contactView.frame.size.width / contactImage.size.width;
					
					UIImageView* contactImageView = [[UIImageView alloc] initWithImage:contactImage];
					[contactImageView setFrame:CGRectMake(0, 0, contactImageView.frame.size.width*factor, contactImageView.frame.size.height*factor)];
					[contactImageView setCenter:CGPointMake(contactView.frame.size.width/2, contactView.frame.size.height/2)];
					[contactView addSubview:contactImageView];
				}
				
				BOOL hasDarkBackground = (BOOL)arc4random_uniform(2);
				if (hasDarkBackground) {
					[contactView setBackgroundColor:[UIColor colorWithWhite:0.25 alpha:0.5]];
				} else {
					[contactView setBackgroundColor:[UIColor colorWithWhite:0.75 alpha:0.5]];
				}
				
				[contactsRow addObject:contactView];
				[self addSubview:contactView];
			}
			
			[contactFields addObject:contactsRow];
		}
	}
	
	return self;
}

- (void)triggerAnimation {
	int direction = arc4random_uniform(4); // 0 = bottom to top, 1 = left to right, 2 = top to bottom, 3 = right to left
	int distance = arc4random_uniform(2) + 1;
	
	int position;
	if (self.tile.size == 3 && (direction == 0 || direction == 2)) {
		position = arc4random_uniform(5) + 2;
	} else {
		position = arc4random_uniform(3) + 3;
	}
	
	NSMutableArray* contactViews = [contactFields objectAtIndex:position];
	CGSize circleSize = CGSizeMake(self.frame.size.height/2, self.frame.size.height/2);
	
	switch (direction) {
		case 0: {
			NSMutableArray* affectedViews = [NSMutableArray new];
			for (int i=0; i<7; i++) {
				[affectedViews addObject:[[contactFields objectAtIndex:i] objectAtIndex:position]];
			}
			
			if (distance == 1) {
				UIView* firstView = [affectedViews objectAtIndex:0];
				
				[firstView setFrame:CGRectMake(firstView.frame.origin.x, circleSize.height*4.5, firstView.frame.size.width, firstView.frame.size.height)];
			} else if (distance == 2) {
				UIView* firstView = [affectedViews objectAtIndex:0];
				UIView* secondView = [affectedViews objectAtIndex:1];
				
				[firstView setFrame:CGRectMake(firstView.frame.origin.x, circleSize.width*4.5, firstView.frame.size.width, firstView.frame.size.height)];
				[secondView setFrame:CGRectMake(secondView.frame.origin.x, circleSize.width*5.5, secondView.frame.size.width, secondView.frame.size.height)];
			}
			
			[UIView animateWithDuration:1.5 animations:^{
				for (UIView* view in affectedViews) {
					[view setEasingFunction:easeOutQuint forKeyPath:@"frame"];
					[view setFrame:CGRectMake(view.frame.origin.x, view.frame.origin.y - (circleSize.width*distance), circleSize.width, circleSize.height)];
				}
			} completion:^(BOOL finished){
				for (UIView* view in [contactFields objectAtIndex:position]) {
					[view removeEasingFunctionForKeyPath:@"frame"];
				}
				
				[self sortVerticalContactViews:affectedViews forPosition:position];
			}];
			break;
		}
		case 1: {
			[self sortHorizontalContactViews:contactViews forPosition:position];
			if (distance == 1) {
				UIView* lastView = [contactViews lastObject];
				
				[lastView setFrame:CGRectMake(-circleSize.width*4.5, lastView.frame.origin.y, lastView.frame.size.width, lastView.frame.size.height)];
			} else if (distance == 2) {
				UIView* lastView = [contactViews lastObject];
				UIView* secondToLastView = [contactViews objectAtIndex:contactViews.count-2];
				
				[lastView setFrame:CGRectMake(-circleSize.width*4.5, lastView.frame.origin.y, lastView.frame.size.width, lastView.frame.size.height)];
				[secondToLastView setFrame:CGRectMake(-circleSize.width*5.5, secondToLastView.frame.origin.y, secondToLastView.frame.size.width, secondToLastView.frame.size.height)];
			}
			[UIView animateWithDuration:1.5 animations:^{
				for (UIView* view in [contactFields objectAtIndex:position]) {
					[view setEasingFunction:easeOutQuint forKeyPath:@"frame"];
					[view setFrame:CGRectMake(view.frame.origin.x + (circleSize.width*distance), view.frame.origin.y, circleSize.width, circleSize.height)];
				}
			} completion:^(BOOL finished){
				for (UIView* view in [contactFields objectAtIndex:position]) {
					[view removeEasingFunctionForKeyPath:@"frame"];
				}
				
				[self sortHorizontalContactViews:contactViews forPosition:position];
			}];
			break;
		}
		case 2: {
			NSMutableArray* affectedViews = [NSMutableArray new];
			for (int i=0; i<7; i++) {
				[affectedViews addObject:[[contactFields objectAtIndex:i] objectAtIndex:position]];
			}
			
			if (distance == 1) {
				UIView* lastView = [affectedViews lastObject];
				
				[lastView setFrame:CGRectMake(lastView.frame.origin.x, -circleSize.height*3.5, lastView.frame.size.width, lastView.frame.size.height)];
			} else if (distance == 2) {
				UIView* lastView = [affectedViews lastObject];
				UIView* secondToLastView = [affectedViews objectAtIndex:affectedViews.count-2];
				
				[lastView setFrame:CGRectMake(lastView.frame.origin.x, -circleSize.width*3.5, lastView.frame.size.width, lastView.frame.size.height)];
				[secondToLastView setFrame:CGRectMake(secondToLastView.frame.origin.x, -circleSize.width*4.5, secondToLastView.frame.size.width, secondToLastView.frame.size.height)];
			}
			
			[UIView animateWithDuration:1.5 animations:^{
				for (UIView* view in affectedViews) {
					[view setEasingFunction:easeOutQuint forKeyPath:@"frame"];
					[view setFrame:CGRectMake(view.frame.origin.x, view.frame.origin.y + (circleSize.width*distance), circleSize.width, circleSize.height)];
				}
			} completion:^(BOOL finished){
				for (UIView* view in [contactFields objectAtIndex:position]) {
					[view removeEasingFunctionForKeyPath:@"frame"];
				}
				
				[self sortVerticalContactViews:affectedViews forPosition:position];
			}];
			break;
		}
		case 3: {
			[self sortHorizontalContactViews:contactViews forPosition:position];
			if (distance == 1) {
				UIView* firstView = [contactViews objectAtIndex:0];
				
				[firstView setFrame:CGRectMake(circleSize.width*5.5, firstView.frame.origin.y, firstView.frame.size.width, firstView.frame.size.height)];
			} else if (distance == 2) {
				UIView* firstView = [contactViews objectAtIndex:0];
				UIView* secondView = [contactViews objectAtIndex:1];
				
				[firstView setFrame:CGRectMake(circleSize.width*5.5, firstView.frame.origin.y, firstView.frame.size.width, firstView.frame.size.height)];
				[secondView setFrame:CGRectMake(circleSize.width*6.5, secondView.frame.origin.y, secondView.frame.size.width, secondView.frame.size.height)];
			}
			[UIView animateWithDuration:1.5 animations:^{
				for (UIView* view in [contactFields objectAtIndex:position]) {
					[view setEasingFunction:easeOutQuint forKeyPath:@"frame"];
					[view setFrame:CGRectMake(view.frame.origin.x - (circleSize.width*distance), view.frame.origin.y, circleSize.width, circleSize.height)];
				}
			} completion:^(BOOL finished){
				for (UIView* view in [contactFields objectAtIndex:position]) {
					[view removeEasingFunctionForKeyPath:@"frame"];
				}
				
				[self sortHorizontalContactViews:contactViews forPosition:position];
			}];
			
			break;
		}
		default: break;
	}
}

- (void)sortVerticalContactViews:(NSArray*)contactViews forPosition:(int)position {
	NSArray* sortedViews = [contactViews sortedArrayUsingComparator:^NSComparisonResult(UIView* view1, UIView* view2) {
		return [[NSNumber numberWithFloat:view1.frame.origin.y] compare:[NSNumber numberWithFloat:view2.frame.origin.y]];
	}];
	
	for (int i=0; i<7; i++) {
		NSMutableArray* contactRow = [contactFields objectAtIndex:i];
		
		[contactRow removeObjectAtIndex:position];
		[contactRow insertObject: [sortedViews objectAtIndex:i] atIndex:position];
	}
}

- (void)sortHorizontalContactViews:(NSArray*)contactViews forPosition:(int)position {
	NSArray* sortedViews = [contactViews sortedArrayUsingComparator:^NSComparisonResult(UIView* view1, UIView* view2) {
		return [[NSNumber numberWithFloat:view1.frame.origin.x] compare:[NSNumber numberWithFloat:view2.frame.origin.x]];
	}];
	
	[contactFields removeObjectAtIndex:position];
	[contactFields insertObject:[sortedViews mutableCopy] atIndex:position];
}

- (void)update {
	return;
}

- (BOOL)readyForDisplay {
	return YES;
}

- (NSArray*)viewsForSize:(int)size {
	return nil;
}

- (CGFloat)updateInterval {
	return 0;
}

@end
