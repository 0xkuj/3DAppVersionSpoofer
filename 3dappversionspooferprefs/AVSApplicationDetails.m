#import "AVSApplicationDetails.h"
@interface NSWorkspace
-(id)sharedWorkspace;
-(NSString *)fullPathForApplication:(NSString *)appName;
@end

@implementation  AVSApplicationDetails
- (NSArray *)specifiers {
	if (!_specifiers) {
		_specifiers = [self loadSpecifiersFromPlistName:@"Apps" target:self];
		NSDictionary *spoofedPlistValues = [NSDictionary dictionaryWithContentsOfFile:SPOOF_VER_PLIST_WITH_PATH];
		NSString *currentAppVersion = spoofedPlistValues[[self specifier].identifier];
		if (currentAppVersion == nil || !([currentAppVersion length] > 0) || [currentAppVersion isEqualToString:@"0"]) {
			currentAppVersion = @"Default";
		}

		PSSpecifier *bundleID = [PSSpecifier preferenceSpecifierNamed:[NSString stringWithFormat:@"Bundle ID: %@",[self specifier].identifier]
						  target:self
						  set:Nil
						  get:Nil
						  detail:Nil
						  cell:PSStaticTextCell
						  edit:Nil];

		PSSpecifier *currentVersion = [PSSpecifier preferenceSpecifierNamed:[NSString stringWithFormat:@"Current Spoofed Version: %@",currentAppVersion]
						  target:self
						  set:Nil
						  get:Nil
						  detail:Nil
						  cell:PSStaticTextCell
						  edit:Nil];

		PSSpecifier *defaultAppVersion = [PSSpecifier preferenceSpecifierNamed:[NSString stringWithFormat:@"Default App Version: %@", [[NSBundle bundleWithIdentifier:[self specifier].identifier] infoDictionary][@"CFBundleShortVersionString"]]
						  target:self
						  set:Nil
						  get:Nil
						  detail:Nil
						  cell:PSStaticTextCell
						  edit:Nil];

		PSSpecifier *groupCell = [PSSpecifier preferenceSpecifierNamed:@"Spoof App Version"
						  target:self
						  set:Nil
						  get:Nil
						  detail:Nil
						  cell:PSGroupCell
						  edit:Nil];

		PSSpecifier *versionToSpoof = [PSSpecifier preferenceSpecifierNamed:@"Enter Version Number:"
						  target:self
						  set:@selector(setPreferenceValue:specifier:)
						  get:@selector(readPreferenceValue:)
						  detail:Nil
						  cell:PSEditTextCell
						  edit:Nil];
		
		PSSpecifier *defaultVersionButton = [PSSpecifier preferenceSpecifierNamed:@"Reset to Default Version" target:self set:Nil get:Nil detail:Nil cell:PSButtonCell edit:Nil];
   		[defaultVersionButton setButtonAction:@selector(resetToDefaultVersion)];

		[versionToSpoof setProperty:@YES forKey:PSEnabledKey];		
		[versionToSpoof setProperty:SPOOF_VER_PLIST forKey:@"defaults"];
		[versionToSpoof setProperty:@YES forKey:PSNumberKeyboardKey];				  
		[versionToSpoof setProperty:[self specifier].identifier forKey:@"key"];
		[_specifiers addObject:bundleID];
		[_specifiers addObject:currentVersion];
		[_specifiers addObject:defaultAppVersion];
		[_specifiers addObject:groupCell];
		[_specifiers addObject:versionToSpoof];
		[_specifiers addObject:defaultVersionButton];
	}
	return _specifiers;
}

-(void)_returnKeyPressed:(id)arg1 {
    [self.view endEditing:YES];
	[self reloadSpecifiers];
}

-(void)resetToDefaultVersion {
	//0 means use original version!
	NSMutableDictionary *prefPlist = [NSMutableDictionary dictionary];
	[prefPlist addEntriesFromDictionary:[NSDictionary dictionaryWithContentsOfFile:SPOOF_VER_PLIST_WITH_PATH]];
	CGFloat defaultValue = 0.0f;
	NSNumber *numberFromFloat = [NSNumber numberWithFloat:defaultValue];
	[prefPlist setObject:[numberFromFloat stringValue] forKey:[self specifier].identifier];
	[prefPlist writeToFile:SPOOF_VER_PLIST_WITH_PATH atomically:YES];
	[self reloadSpecifiers];
}
@end