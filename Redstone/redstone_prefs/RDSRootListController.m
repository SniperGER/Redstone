#include "RDSRootListController.h"

@implementation RDSRootListController

- (NSArray *)specifiers {
	if (!_specifiers) {
		_specifiers = [[self loadSpecifiersFromPlistName:@"Root" target:self] retain];
	}

	return _specifiers;
}

- (void)killSpringBoard {
	system("killall SpringBoard");
}

- (id)readPreferenceValue:(PSSpecifier*)specifier {
	id properties = [specifier properties];
	
	NSString *path = [NSString stringWithFormat:@"/var/mobile/Library/Preferences/%@.plist", properties[@"defaults"]];
	NSDictionary* settings = [NSDictionary dictionaryWithContentsOfFile:path];
	
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

- (void)resetHomeScreenLayout {
	UIAlertController *alertController = [UIAlertController
										  alertControllerWithTitle:@""
										  message:@"This will reset your Start Screen layout to factory defaults."
										  preferredStyle:UIAlertControllerStyleActionSheet];
	UIAlertAction *cancelAction = [UIAlertAction
								   actionWithTitle:@"Cancel"
								   style:UIAlertActionStyleCancel
								   handler:nil];
	
	UIAlertAction *okAction = [UIAlertAction
							   actionWithTitle:@"Reset Start Screen"
							   style:UIAlertActionStyleDestructive
							   handler:^(UIAlertAction *action) {
								   NSMutableDictionary* preferences = [NSMutableDictionary dictionaryWithContentsOfFile:@"/var/mobile/Library/Preferences/ml.festival.redstone.plist"];
								   //[preferences setObject:[NSArray arrayWithContentsOfFile:@"/var/mobile/Library/FESTIVAL/Redstone.bundle/2ColumnDefaultLayout.plist"] forKey:@"2ColumnLayout"];
								   [preferences setObject:[NSArray arrayWithContentsOfFile:@"/var/mobile/Library/FESTIVAL/Redstone/3ColumnDefaultLayout.plist"] forKey:@"3ColumnLayout"];
								   [preferences writeToFile:@"/var/mobile/Library/Preferences/ml.festival.redstone.plist" atomically:YES];
								   
								   system("killall backboardd");
							   }];
	[alertController addAction:cancelAction];
	[alertController addAction:okAction];
	[self presentViewController:alertController animated:YES completion:nil];
}

@end
