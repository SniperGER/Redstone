#import "RDSRootListController.h"
#import <objc/runtime.h>

@implementation RDSRootListController

- (NSArray *)specifiers {
	if (!_specifiers) {
		_specifiers = [[self loadSpecifiersFromPlistName:@"Root" target:self] retain];
	}

	return _specifiers;
}

#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wdeprecated-declarations"
-(void)killSpringBoard {
	system("killall backboardd");
}

-(NSDictionary*)getLocalization {
	NSString* langKey = [[NSLocale currentLocale] objectForKey:NSLocaleLanguageCode];
	NSDictionary* langDict = [NSDictionary dictionaryWithContentsOfFile:[NSString stringWithFormat:@"/Library/PreferenceBundles/redstone_prefs.bundle/%@.lproj/Root.strings", langKey]];
	
	if (![langDict objectForKey:@"TWEAK_ENABLED"]) {
		langDict = [NSDictionary dictionaryWithContentsOfFile:[NSString stringWithFormat:@"/Library/PreferenceBundles/redstone_prefs.bundle/%@.lproj/Root.strings", @"en"]];
	}

	return langDict;
}


-(void)resetHomeScreenLayout {
	/*UIAlertView *reminderAlert = [[UIAlertView alloc ] initWithTitle:@"RESET_LAYOUT"
																			 message:@"RESET_LAYOUT_MESSAGE"
																			delegate:self
																   cancelButtonTitle:@"RESET_CANCEL"
																   otherButtonTitles:@"RESET_OK", nil];

	[reminderAlert show];*/
	UIAlertController *alertController = [UIAlertController
			   alertControllerWithTitle:[[self getLocalization] objectForKey:@"RESET_LAYOUT"]
								message:[[self getLocalization] objectForKey:@"RESET_LAYOUT_MESSAGE"]
						 preferredStyle:UIAlertControllerStyleActionSheet];
	UIAlertAction *cancelAction = [UIAlertAction 
			actionWithTitle:[[self getLocalization] objectForKey:@"RESET_CANCEL"]
					  style:UIAlertActionStyleCancel
					handler:nil];

	UIAlertAction *okAction = [UIAlertAction 
			actionWithTitle:[[self getLocalization] objectForKey:@"RESET_OK"]
					  style:UIAlertActionStyleDestructive
					handler:^(UIAlertAction *action) {
						NSMutableDictionary* preferences = [NSMutableDictionary dictionaryWithContentsOfFile:@"/var/mobile/Library/Preferences/ml.festival.redstone.plist"];
						[preferences setObject:[NSArray arrayWithContentsOfFile:@"/var/mobile/Library/FESTIVAL/Redstone.bundle/2ColumnDefaultLayout.plist"] forKey:@"2ColumnLayout"];
						[preferences setObject:[NSArray arrayWithContentsOfFile:@"/var/mobile/Library/FESTIVAL/Redstone.bundle/3ColumnDefaultLayout.plist"] forKey:@"3ColumnLayout"];
						[preferences writeToFile:@"/var/mobile/Library/Preferences/ml.festival.redstone.plist" atomically:YES];

						system("killall backboardd");
					}];
	[alertController addAction:cancelAction];
	[alertController addAction:okAction];
	[self presentViewController:alertController animated:YES completion:nil];

	//[[%c(RSStartScreenController) sharedInstance] loadTiles];
}

/*- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
	switch(buttonIndex) {
		case 0:
			break;
		case 1: {
			NSMutableDictionary* preferences = [NSMutableDictionary dictionaryWithContentsOfFile:@"/var/mobile/Library/Preferences/ml.festival.redstone.plist"];
			[preferences setObject:[NSArray arrayWithContentsOfFile:@"/var/mobile/Library/FESTIVAL/Redstone.bundle/2ColumnDefaultLayout.plist"] forKey:@"2ColumnLayout"];
			[preferences setObject:[NSArray arrayWithContentsOfFile:@"/var/mobile/Library/FESTIVAL/Redstone.bundle/3ColumnDefaultLayout.plist"] forKey:@"3ColumnLayout"];
			[preferences writeToFile:@"/var/mobile/Library/Preferences/ml.festival.redstone.plist" atomically:YES];

			system("killall backboardd");
			break;
		}
	}
}*/

#pragma GCC diagnostic pop

@end
