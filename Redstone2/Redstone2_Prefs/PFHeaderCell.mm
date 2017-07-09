//PSSpecifier.h
@class NSMutableDictionary, NSDictionary, NSString, NSArray;

typedef enum PSCellType {
	PSGroupCell,
	PSLinkCell,
	PSLinkListCell,
	PSListItemCell,
	PSTitleValueCell,
	PSSliderCell,
	PSSwitchCell,
	PSStaticTextCell,
	PSEditTextCell,
	PSSegmentCell,
	PSGiantIconCell,
	PSGiantCell,
	PSSecureEditTextCell,
	PSButtonCell,
	PSEditTextViewCell,
} PSCellType;

@interface PSSpecifier : NSObject {
@public
	id target;
	SEL getter;
	SEL setter;
	SEL action;
	Class detailControllerClass;
	PSCellType cellType;
	Class editPaneClass;
	UIKeyboardType keyboardType;
	UITextAutocapitalizationType autoCapsType;
	UITextAutocorrectionType autoCorrectionType;
	int textFieldType;
@private
	NSString* _name;
	NSArray* _values;
	NSDictionary* _titleDict;
	NSDictionary* _shortTitleDict;
	id _userInfo;
	NSMutableDictionary* _properties;
}
@property(retain) NSMutableDictionary* properties;
@property(retain) NSString* name;
@property(retain) id userInfo;
@property(retain) id titleDictionary;
@property(retain) id shortTitleDictionary;
@property(retain) NSArray* values;
+(id)preferenceSpecifierNamed:(NSString*)title target:(id)target set:(SEL)set get:(SEL)get detail:(Class)detail cell:(PSCellType)cell edit:(Class)edit;
+(PSSpecifier*)groupSpecifierWithName:(NSString*)title;
+(PSSpecifier*)emptyGroupSpecifier;
+(UITextAutocapitalizationType)autoCapsTypeForString:(PSSpecifier*)string;
+(UITextAutocorrectionType)keyboardTypeForString:(PSSpecifier*)string;
// inherited: -(id)init;
-(id)propertyForKey:(NSString*)key;
-(void)setProperty:(id)property forKey:(NSString*)key;
-(void)removePropertyForKey:(NSString*)key;
-(void)loadValuesAndTitlesFromDataSource;
-(void)setValues:(NSArray*)values titles:(NSArray*)titles;
-(void)setValues:(NSArray*)values titles:(NSArray*)titles shortTitles:(NSArray*)shortTitles;
-(void)setupIconImageWithPath:(NSString*)path;
// inherited: -(void)dealloc;
// inherited: -(id)description;
-(NSString*)identifier;
-(void)setTarget:(id)target;
-(void)setKeyboardType:(UIKeyboardType)type autoCaps:(UITextAutocapitalizationType)autoCaps autoCorrection:(UITextAutocorrectionType)autoCorrection;
// -(int)titleCompare:(NSString*)compare;
@end

//PSTableCell.h
@class PSSpecifier;

@interface PSTableCell : UITableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier specifier:(PSSpecifier *)specifier;

@property (nonatomic, retain) id target;
@property SEL action;

@end


#import "PFHeaderCell.h"
//PFHeaderCell.mm by Pixel Fire http://pixelfire.baileyseymour.com

@interface PFHeaderCell()
{
	UIView *headerImageViewContainer;
	UIImageView *headerImageView;
}
- (void)prepareHeaderImage:(PSSpecifier *)specifier;
- (void)applyHeaderImage;
+ (UIColor *)colorFromHex:(NSString *)hexString;
@end

@implementation PFHeaderCell

+ (UIColor *)colorFromHex:(NSString *)hexString
{
	unsigned rgbValue = 0;
	if ([hexString hasPrefix:@"#"]) hexString = [hexString substringFromIndex:1];
	if (hexString) {
		NSScanner *scanner = [NSScanner scannerWithString:hexString];
		[scanner setScanLocation:0]; // bypass '#' character
		[scanner scanHexInt:&rgbValue];
		return [UIColor colorWithRed:((rgbValue & 0xFF0000) >> 16)/255.0 green:((rgbValue & 0xFF00) >> 8)/255.0 blue:(rgbValue & 0xFF)/255.0 alpha:1.0];
	}
	else return [UIColor grayColor];
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(id)identifier specifier:(PSSpecifier *)specifier
{
	self = [super initWithStyle:style reuseIdentifier:identifier specifier:specifier];
	
	[self prepareHeaderImage:specifier];
	[self applyHeaderImage];
	
	return self;
}

- (void)prepareHeaderImage:(PSSpecifier *)specifier
{
	headerImageViewContainer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
	headerImageViewContainer.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) headerImageViewContainer.layer.cornerRadius = 5;
	
	if(specifier.properties[@"image"] && specifier.properties[@"background"])
	{
		//NSString* imageString = [[NSString stringWithFormat:@"%@~%iw", specifier.properties[@"image"], [[UIScreen mainScreen].bounds.size.width/2] intValue]];
		NSString* imageString = [NSString stringWithFormat:@"%@~%iw", specifier.properties[@"image"], (int)[UIScreen mainScreen].bounds.size.width];
		
		headerImageView = [[UIImageView alloc] initWithImage:[[UIImage alloc] initWithContentsOfFile:imageString]];
 	
		headerImageViewContainer.backgroundColor = [PFHeaderCell colorFromHex:specifier.properties[@"background"]];
		
		[headerImageViewContainer addSubview:headerImageView];
	}
}

- (void)applyHeaderImage
{
	[self addSubview:headerImageViewContainer];
}

@end
