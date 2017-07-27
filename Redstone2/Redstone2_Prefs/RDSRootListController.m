#include "RDSRootListController.h"

@implementation RDSRootListController

- (NSArray *)specifiers {
	if (!_specifiers) {
		_specifiers = [[self loadSpecifiersFromPlistName:@"Root" target:self] retain];
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

- (id)readPreferenceValue:(PSSpecifier*)specifier {
	id properties = [specifier properties];
	
	NSString *path = [NSString stringWithFormat:@"/var/mobile/Library/Preferences/%@.plist", properties[@"defaults"]];
	NSDictionary* settings = [NSDictionary dictionaryWithContentsOfFile:path];
	
	if ([[specifier propertyForKey:@"key"] isEqualToString:@"showMoreTiles"] && [UIScreen mainScreen].bounds.size.width == 414) {
		[specifier setProperty:[NSNumber numberWithBool:NO] forKey:@"enabled"];
	}
	
	return (settings[properties[@"key"]]) ?: properties[@"default"];
}

- (void)setPreferenceValue:(id)value specifier:(PSSpecifier*)specifier {
	id properties = [specifier properties];
	
	NSString *path = [NSString stringWithFormat:@"/var/mobile/Library/Preferences/%@.plist", properties[@"defaults"]];
	NSMutableDictionary* settings = [NSMutableDictionary dictionaryWithContentsOfFile:path];
	
	[settings setObject:value forKey:properties[@"key"]];
	[settings writeToFile:path atomically:YES];
	CFStringRef notificationName = (CFStringRef)properties[@"PostNotification"];
	if (notificationName) {
		CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), notificationName, NULL, NULL, YES);
	}
}

- (void)donate {
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://www.paypal.me/SniperGER/1"] options:@{} completionHandler:nil];
}

#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wdeprecated-declarations"

- (void)killSpringBoard {
	UIAlertController* alertController = [UIAlertController alertControllerWithTitle:@""
																			 message:@"Restarting SpringBoard will apply all changed settings."
																	  preferredStyle:UIAlertControllerStyleActionSheet];
	
	UIAlertAction* cancelAction = [UIAlertAction actionWithTitle:@"Cancel"
														   style:UIAlertActionStyleCancel handler:nil];
	UIAlertAction* confirmAction = [UIAlertAction actionWithTitle:@"Restart SpringBoard"
															style:UIAlertActionStyleDestructive
														  handler:^(UIAlertAction* action) {
															  system("killall SpringBoard");
														  }];
	
	[alertController addAction:cancelAction];
	[alertController addAction:confirmAction];
	[self presentViewController:alertController animated:YES completion:nil];
}

- (void)resetHomeScreenLayout {
	UIAlertController* alertController = [UIAlertController alertControllerWithTitle:@""
																			 message:@"This will reset your Start Screen layout to factory defaults."
																	  preferredStyle:UIAlertControllerStyleActionSheet];
	UIAlertAction* cancelAction = [UIAlertAction actionWithTitle:@"Cancel"
														   style:UIAlertActionStyleCancel
														 handler:nil];
	
	UIAlertAction* confirmAction = [UIAlertAction actionWithTitle:@"Reset Start Screen"
													   style:UIAlertActionStyleDestructive
													 handler:^(UIAlertAction *action) {
														 NSMutableDictionary* preferences = [NSMutableDictionary dictionaryWithContentsOfFile:@"/var/mobile/Library/Preferences/ml.festival.redstone.plist"];
														 [preferences setObject:[NSArray arrayWithContentsOfFile:@"/var/mobile/Library/FESTIVAL/Redstone/2ColumnDefaultLayout.plist"] forKey:@"2ColumnLayout"];
														 [preferences setObject:[NSArray arrayWithContentsOfFile:@"/var/mobile/Library/FESTIVAL/Redstone/3ColumnDefaultLayout.plist"] forKey:@"3ColumnLayout"];
														 
														 [preferences writeToFile:@"/var/mobile/Library/Preferences/ml.festival.redstone.plist" atomically:YES];
														 
														 system("killall SpringBoard");
													 }];
	[alertController addAction:cancelAction];
	[alertController addAction:confirmAction];
	[self presentViewController:alertController animated:YES completion:nil];

}
#pragma GCC diagnostic pop

@end
