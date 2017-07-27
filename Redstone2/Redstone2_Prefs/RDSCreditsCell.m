//
//  RDSCreditsCell.m
//  Redstone2
//
//  Created by Janik Schmidt on 25.07.17.
//  Copyright © 2017 Janik Schmidt. All rights reserved.
//

#import "RDSCreditsCell.h"

@implementation RDSCreditsCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
	self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
	if (self) {
		// Initialization code
	}
	return self;
}

-(void)layoutSubviews {
	[super layoutSubviews];
	
	self.imageView.frame = CGRectMake(0, 0, 60, 60);
	self.imageView.center = CGPointMake(self.textLabel.frame.origin.x / 2, self.frame.size.height / 2);
	self.imageView.layer.cornerRadius = 30.0;
}

@end
