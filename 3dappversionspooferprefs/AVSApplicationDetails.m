#import "AVSApplicationDetails.h"
#define SPOOF_APP_VERSION_KEY @"appVersionToSpoof"
#define SPOOF_APP_BUNDLE_KEY @"appBundle"
#define SPOOF_IOS_VERSION_KEY @"iosVersionToSpoof"
#define SPOOF_EXPERIMENTAL_KEY @"ExperimentalSpoof"

@interface NSWorkspace
-(id)sharedWorkspace;
-(NSString *)fullPathForApplication:(NSString *)appName;
@end

@interface AVSApplicationDetails ()
@property (nonatomic, strong) NSString *currentAppVersion;
@property (nonatomic, strong) NSString *currentiOSSpoofedVersion;
@property (nonatomic) BOOL experimentalSpoofing;
@end

@implementation  AVSApplicationDetails
- (NSArray *)specifiers {
	if (!_specifiers) {
		_specifiers = [self loadSpecifiersFromPlistName:@"Apps" target:self];
		NSDictionary *spoofedPlistValues = [NSDictionary dictionaryWithContentsOfFile:SPOOF_VER_PLIST_WITH_PATH];
		_currentAppVersion = spoofedPlistValues[[self specifier].identifier];
		_currentiOSSpoofedVersion = nil;
		_experimentalSpoofing = NO;
		
		for (NSDictionary *key in spoofedPlistValues) {
			if (([spoofedPlistValues[key] isKindOfClass:[NSString class]] && [(NSString *)key isEqualToString:[self specifier].identifier])) {
				// this means old settings was found.. only until i remove it
				_currentAppVersion = spoofedPlistValues[key];
			} else if ([spoofedPlistValues[key] isKindOfClass:[NSDictionary class]] && [spoofedPlistValues[key][SPOOF_APP_BUNDLE_KEY] isEqualToString:[self specifier].identifier]) {
				_currentAppVersion = spoofedPlistValues[key][SPOOF_APP_VERSION_KEY];
				_currentiOSSpoofedVersion = spoofedPlistValues[key][SPOOF_IOS_VERSION_KEY];
				_experimentalSpoofing = [spoofedPlistValues[key][SPOOF_EXPERIMENTAL_KEY] boolValue];
			}
		}

		_currentAppVersion = [self checkIfDefaultVersion:_currentAppVersion];
		_currentiOSSpoofedVersion = [self checkIfDefaultVersion:_currentiOSSpoofedVersion];
		PSSpecifier *bundleID = [PSSpecifier preferenceSpecifierNamed:[NSString stringWithFormat:@"Bundle ID: %@",[self specifier].identifier]
						  target:self
						  set:Nil
						  get:Nil
						  detail:Nil
						  cell:PSStaticTextCell
						  edit:Nil];

		PSSpecifier *currentVersion = [PSSpecifier preferenceSpecifierNamed:[NSString stringWithFormat:@"Current Spoofed Version: %@", _currentAppVersion]
						  target:self
						  set:Nil
						  get:Nil
						  detail:Nil
						  cell:PSStaticTextCell
						  edit:Nil];

		PSSpecifier *currentiOSVersion = [PSSpecifier preferenceSpecifierNamed:[NSString stringWithFormat:@"Current Spoofed iOS Version: %@", _currentiOSSpoofedVersion]
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

		PSSpecifier *versionToSpoof = [PSSpecifier preferenceSpecifierNamed:@"Spoof Version Number:"
						  target:self
						  set:@selector(setPreferenceValueLocal:specifier:)
						  get:@selector(readPreferenceValueLocal:)
						  detail:Nil
						  cell:PSEditTextCell
						  edit:Nil];

		PSSpecifier *iOSversionToSpoof = [PSSpecifier preferenceSpecifierNamed:@"Spoof iOS Version:"
						  target:self
						  set:@selector(setPreferenceValueLocal:specifier:)
						  get:@selector(readPreferenceValueLocal:)
						  detail:Nil
						  cell:PSEditTextCell
						  edit:Nil];

		// i had to add readpreferencevaluelocal because without that, no changes are made using the setter.. idk why
		PSSpecifier *spoofSwitchSpecifier = [PSSpecifier preferenceSpecifierNamed:@"Experimental Spoofing"
                        target:self
                    	set:@selector(setPreferenceValueLocal:specifier:)
                        get:@selector(readPreferenceValueLocal:)
                        detail:Nil
                        cell:PSSwitchCell
                        edit:Nil];
		
		PSSpecifier *defaultVersionButton = [PSSpecifier preferenceSpecifierNamed:@"Reset to Default Version" target:self set:Nil get:Nil detail:Nil cell:PSButtonCell edit:Nil];
   		[defaultVersionButton setButtonAction:@selector(resetToDefaultVersion)];

		[versionToSpoof setProperty:@YES forKey:PSEnabledKey];		
		[versionToSpoof setProperty:SPOOF_VER_PLIST forKey:@"defaults"];
		[versionToSpoof setProperty:@YES forKey:PSNumberKeyboardKey];				  
		[versionToSpoof setProperty:[self specifier].identifier forKey:@"key"];
		[_specifiers addObject:bundleID];
		[_specifiers addObject:currentVersion];
		[_specifiers addObject:currentiOSVersion];
		[_specifiers addObject:defaultAppVersion];
		[_specifiers addObject:groupCell];
		[_specifiers addObject:versionToSpoof];
		[_specifiers addObject:iOSversionToSpoof];
		[_specifiers addObject:spoofSwitchSpecifier];
		[_specifiers addObject:defaultVersionButton];
	}
	return _specifiers;
}

- (id)readPreferenceValueLocal:(PSSpecifier*)specifier {
	if ([specifier.name isEqualToString:@"Experimental Spoofing"]) {
		NSNumber *result = @(self.experimentalSpoofing);
		return result;
	}
	return nil;
}

/* set the value immediately when needed */
- (void)setPreferenceValueLocal:(id)value specifier:(PSSpecifier*)specifier {
	NSMutableDictionary *settings = [NSMutableDictionary dictionary];
	[settings addEntriesFromDictionary:[NSDictionary dictionaryWithContentsOfFile:SPOOF_VER_PLIST_WITH_PATH]];
	if (!settings) {
		settings = [NSMutableDictionary dictionary];
	} else {
		if ([self checkIfValueExists] == NO) {
			NSString *appExecName = [NSBundle bundleWithIdentifier:[self specifier].identifier].infoDictionary[@"CFBundleExecutable"];
			settings[appExecName] = [NSMutableDictionary dictionary];
			[settings[appExecName] setObject:[self specifier].identifier forKey:SPOOF_APP_BUNDLE_KEY];
			[settings[appExecName] setObject:self.currentAppVersion forKey:SPOOF_APP_VERSION_KEY];
			[settings[appExecName] setObject:@"0" forKey:SPOOF_IOS_VERSION_KEY];
			[settings[appExecName] setObject:@(NO) forKey:SPOOF_EXPERIMENTAL_KEY];
		}

		for (NSDictionary *key in settings) {
			if ([settings[key] isKindOfClass:[NSDictionary class]] && [settings[key][SPOOF_APP_BUNDLE_KEY] isEqualToString:[self specifier].identifier]) {
				if ([specifier.name isEqualToString:@"Experimental Spoofing"]) {
					[settings[key] setObject:value forKey:SPOOF_EXPERIMENTAL_KEY];
				} else if ([specifier.name isEqualToString:@"Spoof iOS Version:"]) {
					[settings[key] setObject:value forKey:SPOOF_IOS_VERSION_KEY];
				} else if ([specifier.name isEqualToString:@"Spoof Version Number:"]) {
					[settings[key] setObject:value forKey:SPOOF_APP_VERSION_KEY];
				}
				//a match was found, nothing else to look for
				break;
			}
		}
	}

	if (settings[[self specifier].identifier] != nil) {
		[settings removeObjectForKey:[self specifier].identifier];
	}

	[settings writeToFile:SPOOF_VER_PLIST_WITH_PATH atomically:YES];
	CFStringRef notificationName = (__bridge CFStringRef)specifier.properties[@"PostNotification"];
	if (notificationName) {
		CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), notificationName, NULL, NULL, YES);
	}
}

- (BOOL)checkIfValueExists {
	NSMutableDictionary *settings = [NSMutableDictionary dictionary];
	[settings addEntriesFromDictionary:[NSDictionary dictionaryWithContentsOfFile:SPOOF_VER_PLIST_WITH_PATH]];
	for (NSDictionary *key in settings) {
		if ([settings[key] isKindOfClass:[NSDictionary class]] && [settings[key][SPOOF_APP_BUNDLE_KEY] isEqualToString:[self specifier].identifier]) {
			return YES;
		}
	}
	return NO;
}
- (NSString *)checkIfDefaultVersion:(NSString *)str {
	if (str == nil || !([str length] > 0) || [str isEqualToString:@"0"]) {
		return @"Default";
	}
	return str;
}

- (void)_returnKeyPressed:(id)arg1 {
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