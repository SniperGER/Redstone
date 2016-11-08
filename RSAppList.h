#import <UIKit/UIKit.h>
#import "CommonHeaders.h"

@class RSAppListSection;

@interface RSAppList : UIScrollView {

	NSMutableArray* sections;
	NSMutableDictionary* appsBySection;

}
-(NSArray*)sections;
-(RSAppListSection*)sectionWithLetter:(NSString*)letter;
-(void)addAppsAndSections;
-(void)layoutContentsWithSections:(BOOL)arg1 ;
-(void)sortAppsAndLayout:(id)arg1 ;
-(void)updateSectionsWithOffset:(float)offset;
-(void)showAppsFittingQuery:(NSString*)query;
-(void)jumpToSectionWithLetter:(NSString*)letter;

@end