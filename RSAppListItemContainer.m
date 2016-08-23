#import "RSAppListItemContainer.h"
#import "RSAppListItem.h"

@implementation RSAppListItemContainer

-(id)initWithFrame:(CGRect)frame withBundleIdentifier:(NSString*)appBundleIdentifier {
    bundleIdentifier = appBundleIdentifier;
	self = [super initWithFrame:frame];

	cellInnerView = [[RSAppListItem alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height) withBundleIdentifier:bundleIdentifier];
	[self addSubview:cellInnerView];

	return self;
}

-(RSAppListItem*)getAppListItem {
	return cellInnerView;
}

-(void)setBackgroundColor:(UIColor *)backgroundColor {
    [super setBackgroundColor:backgroundColor];
    
    [cellInnerView setTileBackgroundColor:[RSAesthetics accentColorForApp:bundleIdentifier]];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    if (selected){
        [cellInnerView setTileBackgroundColor:[RSAesthetics accentColorForApp:bundleIdentifier]];
    }
}

-(void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated{
    [super setHighlighted:highlighted animated:animated];
    
    if (highlighted){
        [cellInnerView setTileBackgroundColor:[RSAesthetics accentColorForApp:bundleIdentifier]];
    }
}

@end