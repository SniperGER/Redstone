/**
 @class RSAppListSection
 @author Sniper_GER
 @discussion Represents a section header in App List
 */

#import <UIKit/UIKit.h>

@class RSTiltView;

@interface RSAppListSection : RSTiltView {
	NSString* displayName;
	UILabel* sectionLabel;
}

@property (nonatomic, assign) int yPosition;
@property (nonatomic, assign) CGPoint originalCenter;

/**
 Initializes an App List section header with a given letter

 @param frame The frame to create the section header with
 @param letter The letter for the section header
 @return An instance of RSAppListSection
 */
- (id)initWithFrame:(CGRect)frame letter:(NSString*)letter;

- (NSString*)displayName;

@end
