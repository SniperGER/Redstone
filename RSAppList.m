#import "RSAppList.h"
#import "RSAesthetics.h"
#import "RSApp.h"
#import "RSAppListSection.h"
#import "RSAppListController.h"

@implementation RSAppList

-(NSArray*)sections {
	return sections;
}

-(id)initWithFrame:(CGRect)frame {
	self = [super initWithFrame:frame];
	
	if (self) {
		[self setShowsVerticalScrollIndicator:NO];
		[self setShowsHorizontalScrollIndicator:NO];
		[self setDelaysContentTouches:NO];
		[self setClipsToBounds:YES];
		
		self.contentInset = UIEdgeInsetsMake(0, 0, 80, 0);

		[self addAppsAndSections];

		UITapGestureRecognizer* tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapped:)];
		[tap setCancelsTouchesInView:NO];
		[self addGestureRecognizer:tap];
	}
	
	return self;
}

-(void)tapped:(id)sender {
	if ([[RSAppListController sharedInstance] pinMenu]) {
		[[RSAppListController sharedInstance] hidePinMenu];
	}
}

-(void)addAppsAndSections {
	self->sections = [[NSMutableArray alloc] init];
	self->appsBySection = [[NSMutableDictionary alloc] init];
	
	NSString* alphabet = [RSAesthetics localizedStringForKey:@"ALPHABET"];
	NSString* numbers = @"1234567890";
	
	for (int i=0; i<28; i++) {
		[appsBySection setObject:[@[] mutableCopy] forKey:[alphabet substringWithRange:NSMakeRange(i,1)]];
	}
	
	NSArray* visibleIcons = [[[objc_getClass("SBIconController") sharedInstance] model] visibleIconIdentifiers];
	for (int i=0; i<[visibleIcons count]; i++) {
		RSApp* app = [[RSApp alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, 54) leafId:[visibleIcons objectAtIndex:i]];
		[self addSubview:app];
		
		if (![[app displayName] isEqualToString:@""]) {
			NSString* first = [[[app displayName] substringWithRange:NSMakeRange(0,1)] uppercaseString];
			
			if (first != nil) {
				BOOL isString = [alphabet rangeOfString:first].location != NSNotFound;
				BOOL isNumeric = [numbers rangeOfString:first].location != NSNotFound;
				
				NSString* supposedSectionLetter = @"";
	
				if (isString) {
					[[appsBySection objectForKey:first] addObject:app];
					supposedSectionLetter = first;
				} else if (isNumeric) {
					[[appsBySection objectForKey:@"#"] addObject:app];
					supposedSectionLetter = @"#";
				} else {
					[[appsBySection objectForKey:@"@"] addObject:app];
					supposedSectionLetter = @"@";
				}
				
				if ([self sectionWithLetter:supposedSectionLetter] == nil) {
					RSAppListSection* section = [[RSAppListSection alloc] initWithFrame:CGRectMake(0,0,self.frame.size.width, 60) letter:supposedSectionLetter];
					//[self addSubview:section];
					[self->sections addObject:section];
				}
			}
		}
	}
	
	NSArray* sortedSections = [self->sections sortedArrayUsingComparator:^NSComparisonResult(RSAppListSection* app1, RSAppListSection* app2) {
		return [[app1 displayName] compare:[app2 displayName]];
	}];
	self->sections = [sortedSections mutableCopy];
	
	/*RSAppListSection* specialCharSection = [self sectionWithLetter:@"@"];
	[self->sections removeObject:specialCharSection];
	[self->sections addObject:specialCharSection];*/
	
	for (int i=0; i<28; i++) {
		NSArray* arrayToSort = [self->appsBySection objectForKey:[alphabet substringWithRange:NSMakeRange(i,1)]];
		if ([arrayToSort count] > 0) {
			arrayToSort = [arrayToSort sortedArrayUsingComparator:^NSComparisonResult(RSApp* app1, RSApp* app2) {
				return [[app1 displayName] caseInsensitiveCompare:[app2 displayName]];
			}];
			
			[self->appsBySection setObject:arrayToSort forKey:[alphabet substringWithRange:NSMakeRange(i,1)]];
		}
	}
	
	[self layoutContentsWithSections:YES];
}

-(RSAppListSection*)sectionWithLetter:(NSString*)letter {
	if (letter != nil) {
		for (RSAppListSection* section in self->sections) {
			if ([[section displayName] isKindOfClass:[NSString class]] && [[section displayName] isEqualToString:letter]) {
				return section;
				break;
			}
		}
	}
	
	return nil;
}

-(void)layoutContentsWithSections:(BOOL)arg1 {
	NSMutableArray* _sections = [[NSMutableArray alloc] init];
	
	for (UIView* subview in [self subviews]) {
		if ([subview isKindOfClass:[RSApp class]]) {
			[_sections addObject:subview];
		} else if ([subview isKindOfClass:[RSAppListSection class]]) {
			if (arg1) {
				[_sections addObject:subview];
				[subview setHidden:NO];
			} else {
				[subview setHidden:YES];
			}
		}
	}
	
	[self sortAppsAndLayout:self->sections];
}

-(void)sortAppsAndLayout:(NSArray*)sections {
	NSString* alphabet = [RSAesthetics localizedStringForKey:@"ALPHABET"];

	int yPos = 0;
	id previousSection = nil;
	for (int i=0; i<28; i++) {
		NSArray* currentSection = [self->appsBySection objectForKey:[alphabet substringWithRange:NSMakeRange(i,1)]];

		if ([currentSection count] > 0) {
			previousSection = [alphabet substringWithRange:NSMakeRange(i,1)];

			RSAppListSection* section = [self sectionWithLetter:previousSection];
			[section setFrame:CGRectMake(0, yPos, self.frame.size.width, 60)];
			[section setYCoordinate:yPos];
			
			yPos += 60;
			[self addSubview:section];
			
			for (RSApp* app in currentSection) {
				//[self addSubview:app];
				[app setFrame:CGRectMake(0, yPos, self.frame.size.width, 56)];
				[app setHidden:NO];
				
				yPos += 56;
			}
		}
	}
	
	CGRect contentRect = CGRectZero;
	for (UIView *view in self.subviews) {
    	contentRect = CGRectUnion(contentRect, view.frame);
	}
	self.contentSize = contentRect.size;

}

-(void)updateSectionsWithOffset:(float)offset {
	for (int i=0; i<[self->sections count]; i++) {
		RSAppListSection* section = [self->sections objectAtIndex:i];
		
		//if (CGRectIntersectsRect(self.bounds, section.frame)) {
			if ([section yCoordinate]-offset < 0  && (i+1) < [self->sections count]) {
				if ([self->sections objectAtIndex:i+1] && (offset+60) < [[self->sections objectAtIndex:i+1] yCoordinate]) {
					[section setFrame:CGRectMake(0,offset,self.frame.size.width,60)];
				} else {
					[section setFrame:CGRectMake(0,[[self->sections objectAtIndex:i+1] yCoordinate]-60,self.frame.size.width,60)];
				}
			} else {
				[section setFrame:CGRectMake(0,[section yCoordinate],self.frame.size.width,60)];
			}
		//}
	}
}

-(void)jumpToSectionWithLetter:(NSString*)letter {
	if ([self sectionWithLetter:letter]) {
		for (RSAppListSection* section in self->sections) {
			if ([[section displayName] isEqualToString:letter]) {
				int sectionOffset = [section yCoordinate];
				int maxOffsetByScreen = self.contentSize.height - self.bounds.size.height + 80;
				
				[self setContentOffset:CGPointMake(0,(sectionOffset > maxOffsetByScreen ? maxOffsetByScreen : sectionOffset))];
				break;
			}
		}
	}
}

-(void)showAppsFittingQuery:(NSString*)query {
	NSMutableArray* newSubviews = [[NSMutableArray alloc] init];

	for (UIView* subview in [self subviews]) {
		if ([query length] > 0) {
			if ([subview isKindOfClass:[RSApp class]]) {
				NSArray* displayName = [[[(RSApp*)subview displayName] lowercaseString] componentsSeparatedByString:@" "];

				for (int i=0; i<[displayName count]; i++) {
					if ([[displayName objectAtIndex:i] hasPrefix:[query lowercaseString]]) {
						[newSubviews addObject:subview];
						break;
					} else {
						[subview setHidden:YES];
					}
				}

			} else {
				[subview setHidden:YES];
			}
		} else {
			[subview setHidden:NO];
		}
	}

	if ([newSubviews count] > 0 && (query != nil || ![query isEqualToString:@""])) {
		[[RSAppListController sharedInstance] showNoResultsLabel:NO forQuery:nil];
		for (UIView* subview in [self subviews]) {
			[subview setHidden:YES];
		}

		newSubviews = [[newSubviews sortedArrayUsingComparator:^NSComparisonResult(RSApp* app1, RSApp* app2) {
			return [[app1 displayName] caseInsensitiveCompare:[app2 displayName]];
		}] mutableCopy];

		for (int i=0; i<[newSubviews count]; i++) {
			RSApp* subview = [newSubviews objectAtIndex:i];
			[subview setHidden:NO];

			CGRect frame = subview.frame;
			frame.origin.y = i * frame.size.height;
			[subview setFrame:frame];
		}

		CGRect contentRect = CGRectZero;
		for (UIView *view in self.subviews) {
			if (!view.hidden) {
	    		contentRect = CGRectUnion(contentRect, view.frame);
	    	}
		}
		self.contentSize = contentRect.size;
	} else if ([newSubviews count] == 0 && ![query isEqualToString:@""]) {
		[[RSAppListController sharedInstance] showNoResultsLabel:YES forQuery:query];
	} else {
		[[RSAppListController sharedInstance] showNoResultsLabel:NO forQuery:nil];
		[self sortAppsAndLayout:self->sections];
	}
}

@end