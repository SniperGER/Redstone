#include "RDSRootListController.h"

@implementation RDSRootListController

- (NSArray *)specifiers {
	if (!_specifiers) {
		_specifiers = [[self loadSpecifiersFromPlistName:@"Root" target:self] retain];
	}

	return _specifiers;
}

-(void)killSpringBoard {
    system("killall backboardd");
}

@end
