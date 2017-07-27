#import "RDSCreditsListController.h"
#import "RDSCreditsCell.h"

@implementation RDSCreditsListController

- (NSArray *)specifiers {
	if (!_specifiers) {
		_specifiers = [[self loadSpecifiersFromPlistName:@"Credits" target:self] retain];
	}
	
	return _specifiers;
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	
	settingsView = [[UIApplication sharedApplication] keyWindow];
	
	settingsView.tintColor = [UIColor redColor];
	self.navigationController.navigationBar.tintColor = [UIColor redColor];
}

- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
	
	settingsView.tintColor = nil;
	self.navigationController.navigationBar.tintColor = nil;
}

- (id)tableView:(id)arg1 cellForRowAtIndexPath:(NSIndexPath*)arg2 {
	UITableViewCell *cell = [super tableView:arg1 cellForRowAtIndexPath:arg2];
	RDSCreditsCell* newCell = [[RDSCreditsCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"RDSCreditsCell"];
	
	newCell.textLabel.text = cell.textLabel.text;
	newCell.textLabel.font = [UIFont boldSystemFontOfSize:16];
	newCell.detailTextLabel.numberOfLines = 0;
	newCell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	
	UIImage *image = [[UIImage alloc] init];
	
	if (arg2.section == 0) {
		switch (arg2.row) {
			case 0:
				newCell.detailTextLabel.text = @"Creator of metroUI, watchUI, LockWatch and Redstone. Co-founder of FESTIVAL Development";
				image = [UIImage imageWithContentsOfFile:[[[self bundle] bundlePath] stringByAppendingString:@"/People/Sniper_GER"]];
				break;
			default: break;
		}
	} else if (arg2.section == 1) {
		switch (arg2.row) {
			case 0:
				newCell.detailTextLabel.text = @"Tile Icons, responsible for features like Corner Badges and Parallax Wallpaper";
				break;
			case 1:
				newCell.detailTextLabel.text = @"This guy surely loves testing tweaks!";
				break;
			case 2:
				newCell.detailTextLabel.text = @"Extensive testing and Bug Reporting";
				break;
			case 3:
				newCell.detailTextLabel.text = @"Awesome guy, did a video on Redstone!";
				break;
			case 4:
				newCell.detailTextLabel.text = @"The guy who runs ModMyi. I hate rhymes by the way.";
				break;
			case 5:
				newCell.detailTextLabel.text = @"He also helped at some point where he sent me the bugs or told me about 😜😜";
				break;
			case 6:
			case 7:
			case 8:
			case 9:
				newCell.detailTextLabel.text = @"Testing and Bug Reporting";
				break;
			case 10:
				newCell.detailTextLabel.text = @"Requested the \"Plex\" tile icon";
				break;
			default: break;
		}
	}
	
	newCell.imageView.image = image;
	
	return newCell;
}

- (CGFloat)tableView:(id)arg1 heightForRowAtIndexPath:(id)arg2 {
	return 100.0;
}

@end
