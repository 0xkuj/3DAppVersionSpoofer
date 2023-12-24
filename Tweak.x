#include "Tweak.h"
#import <mach-o/nlist.h>

@interface UITraitCollection ()
+(id)currentTraitCollection;
@end

BOOL isTweakEnabled, is3DMenu;
static void loadPrefs() { 
	NSMutableDictionary* mainPreferenceDict = [[NSMutableDictionary alloc] initWithContentsOfFile:SPOOF_VER_PLIST];
	// if we have one key that is string, we should migrate all setting once.
	// this will be called before any applaunch after respring.
	isTweakEnabled = [mainPreferenceDict objectForKey:@"isTweakEnabled"] ? [[mainPreferenceDict objectForKey:@"isTweakEnabled"] boolValue] : YES;
	is3DMenu = [mainPreferenceDict objectForKey:@"is3DMenu"] ? [[mainPreferenceDict objectForKey:@"is3DMenu"] boolValue] : YES;
}

%hook SBIconView
- (void)setApplicationShortcutItems:(NSArray *)shortcutItems {
	#define TDAVS_ASSET_DARK jbroot(ROOT_PATH_NS(@"/Library/Application Support/3DAppVersionSpoofer.bundle/fakeverblack@2x.png"))
	#define TDAVS_ASSET_WHITE jbroot(ROOT_PATH_NS(@"/Library/Application Support/3DAppVersionSpoofer.bundle/fakeverwhite@2x.png"))
	if (!is3DMenu) {
		return %orig;
	}

	NSMutableArray *editedItems = [NSMutableArray arrayWithArray:shortcutItems ? : @[]];
	if (![self.icon isKindOfClass:%c(SBFolderIcon)] && ![self.icon isKindOfClass:%c(SBWidgetIcon)]) { 
		SBSApplicationShortcutItem *shortcutItems = [[%c(SBSApplicationShortcutItem) alloc] init];
		shortcutItems.localizedTitle = @"Spoof App Version";
		shortcutItems.type = SPOOF_VER_TWEAK_BUNDLE;
		NSData *imgData = UIImagePNGRepresentation([UIImage imageNamed:TDAVS_ASSET_DARK]);
		//dark mode check
		NSOperatingSystemVersion versionToCheck;
        versionToCheck.majorVersion = 13;
        versionToCheck.minorVersion = 5;
        versionToCheck.patchVersion = 0;
		BOOL iosContainsDarkmode = [[NSProcessInfo processInfo] isOperatingSystemAtLeastVersion:versionToCheck];
		if (iosContainsDarkmode) {
			if ([[UITraitCollection currentTraitCollection] userInterfaceStyle] == UIUserInterfaceStyleDark) {
				imgData = UIImagePNGRepresentation([UIImage imageNamed:TDAVS_ASSET_WHITE]);
			}
		}
		if (imgData) {
			SBSApplicationShortcutCustomImageIcon *iconImage = [[%c(SBSApplicationShortcutCustomImageIcon) alloc] initWithImagePNGData:imgData];
			shortcutItems.icon = iconImage;
		}
		if (shortcutItems) {
			[editedItems addObject:shortcutItems];
		}
	}
 	%orig(editedItems);
}

+ (void)activateShortcut:(SBSApplicationShortcutItem *)item withBundleIdentifier:(NSString *)bundleID forIconView:(SBIconView *)iconView {
    if ([item.type isEqualToString:SPOOF_VER_TWEAK_BUNDLE]) {
		//i have no idea why sometimes the apdefaultversion is null, the bundle is correct and works the same as in settings..
		NSURL *appFolderURL = [iconView applicationBundleURLForShortcuts];
		NSURL *infoPlistURL = [appFolderURL URLByAppendingPathComponent:@"Info.plist"];
		NSDictionary *infoDictionary = [NSDictionary dictionaryWithContentsOfFile:infoPlistURL.path];
		NSString *appDefaultVersion = infoDictionary[@"CFBundleShortVersionString"];
		NSString *appExecName = infoDictionary[@"CFBundleExecutable"];
		NSMutableDictionary *prefPlist = [NSMutableDictionary dictionary];
		[prefPlist addEntriesFromDictionary:[NSDictionary dictionaryWithContentsOfFile:SPOOF_VER_PLIST]];
		//support old prefs
		NSString *currentVer = prefPlist[appExecName] ? prefPlist[appExecName][SPOOF_APP_VERSION_KEY] : prefPlist[bundleID] ? prefPlist[bundleID] : nil;
		NSString *currentiOSSpoofedVersion = prefPlist[appExecName] ? prefPlist[appExecName][SPOOF_IOS_VERSION_KEY] : nil;
		UISwitch *experimentalSpoofSwitch = [[UISwitch alloc] init];

		if (currentVer == nil || [currentVer isEqualToString:@"0"]) {
			currentVer = @"Default";
		}

		if (currentiOSSpoofedVersion == nil || [currentiOSSpoofedVersion isEqualToString:@"0"]) {
			currentiOSSpoofedVersion = @"Default";
		}

	    UIAlertController* alertController = [UIAlertController alertControllerWithTitle:@"3DAppVersionSpoofer"
																	message:[NSString stringWithFormat:@"WARNING: This can cause unexpected behavior in your app.\nBundle ID: %@\nCurrent Spoofed Version: %@\nCurrent Spoofed iOS Version: %@\nDefault App Version: %@\n\nWhat is the version number you want to spoof?\n\n\n",bundleID,currentVer,currentiOSSpoofedVersion,appDefaultVersion]
																	preferredStyle:UIAlertControllerStyleAlert];

		[alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
			if ([currentVer isEqualToString:@"Default"]) {
				textField.placeholder = @"Enter Version Number"; 
			} else {
				textField.text = currentVer;
			}
			
			textField.keyboardType = UIKeyboardTypeDecimalPad;
		}];

		[alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
			if ([currentiOSSpoofedVersion isEqualToString:@"Default"]) {
				textField.placeholder = @"Enter iOS Version (Optional)"; 
			} else {
				textField.text = currentiOSSpoofedVersion;
			}
			
			textField.keyboardType = UIKeyboardTypeDecimalPad;
		}];

		UIAlertAction *setNewValue = [UIAlertAction actionWithTitle:@"Set Spoofed Version" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
			NSString *spoofedAppVersion = ([[alertController textFields][0] text].length > 0) ? [[alertController textFields][0] text] : prefPlist[bundleID] ? prefPlist[bundleID] : @"0";
			NSString *spoofediOSVersion = ([[alertController textFields][1] text].length > 0) ? [[alertController textFields][1] text] : @"0";
			//support regions that have comma instead of dot 0-0
			if (prefPlist[appExecName] == nil) {
				prefPlist[appExecName] = [NSMutableDictionary dictionary];
			}
			[prefPlist[appExecName] setObject:bundleID forKey:SPOOF_APP_BUNDLE_KEY];
			[prefPlist[appExecName] setObject:[spoofedAppVersion stringByReplacingOccurrencesOfString:@"," withString:@"."] forKey:SPOOF_APP_VERSION_KEY];
			[prefPlist[appExecName] setObject:spoofediOSVersion forKey:SPOOF_IOS_VERSION_KEY];
			[prefPlist[appExecName] setObject:@(experimentalSpoofSwitch.isOn) forKey:SPOOF_EXPERIMENTAL_KEY];
			if (prefPlist[bundleID] != nil) {
				[prefPlist removeObjectForKey:bundleID];
			}
			[prefPlist writeToFile:SPOOF_VER_PLIST atomically:YES]; 
		}];

		[alertController addAction:setNewValue];		

		BOOL isSwitchOn = [prefPlist[appExecName] objectForKey:SPOOF_EXPERIMENTAL_KEY] ? [[prefPlist[appExecName] objectForKey:SPOOF_EXPERIMENTAL_KEY] boolValue] : NO;
		if (isSwitchOn) {
			[experimentalSpoofSwitch setOn:YES animated:YES];
		} else {
			[experimentalSpoofSwitch setOn:NO animated:YES];
		}
		
		[alertController.view addSubview:experimentalSpoofSwitch];

		UILabel *switchLabel = [[UILabel alloc] init];
		switchLabel.text = @"EXPERIMENTAL SPOOFING";
		switchLabel.numberOfLines = 0;
		switchLabel.textAlignment = NSTextAlignmentLeft;
		switchLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleCaption1];
		switchLabel.font = [UIFont systemFontOfSize:12.0];

		[alertController.view addSubview:switchLabel];
		[experimentalSpoofSwitch setTranslatesAutoresizingMaskIntoConstraints:NO];
		[switchLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
		NSLayoutConstraint *leadingConstraint = [NSLayoutConstraint constraintWithItem:experimentalSpoofSwitch attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:alertController.view attribute:NSLayoutAttributeLeadingMargin multiplier:1.0 constant:0];
		NSLayoutConstraint *topConstraint = [NSLayoutConstraint constraintWithItem:experimentalSpoofSwitch attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:alertController.view attribute:NSLayoutAttributeTopMargin multiplier:1.0 constant:195];
		NSLayoutConstraint *labelLeadingConstraint = [NSLayoutConstraint constraintWithItem:switchLabel attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:experimentalSpoofSwitch attribute:NSLayoutAttributeTrailing multiplier:1.0 constant:8];
		NSLayoutConstraint *labelCenterYConstraint = [NSLayoutConstraint constraintWithItem:switchLabel attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:experimentalSpoofSwitch attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0];
		[alertController.view addConstraints:@[leadingConstraint, topConstraint, labelLeadingConstraint, labelCenterYConstraint]];

		UIAlertAction *setDefaultValue = [UIAlertAction actionWithTitle:@"Reset to Default Version" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
			//0 means use original version!
			CGFloat defaultValue = 0.0f;
			NSNumber *numberFromFloat = [NSNumber numberWithFloat:defaultValue];
			if (prefPlist[appExecName] == nil) {
				prefPlist[appExecName] = [NSMutableDictionary dictionary];
			}
			[prefPlist[appExecName] setObject:@(NO) forKey:SPOOF_EXPERIMENTAL_KEY];
			[prefPlist[appExecName] setObject:[numberFromFloat stringValue] forKey:SPOOF_APP_VERSION_KEY];
			[prefPlist[appExecName] setObject:[numberFromFloat stringValue] forKey:SPOOF_IOS_VERSION_KEY];
			//getting rid of old prefs
			if (prefPlist[bundleID] != nil) {
				[prefPlist removeObjectForKey:bundleID];
			}
			[prefPlist writeToFile:SPOOF_VER_PLIST atomically:YES];
		}];
		[alertController addAction:setDefaultValue];

		UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style: UIAlertActionStyleCancel handler:^(UIAlertAction * action) {}];

		[alertController addAction:cancelAction];

		//seriously shit hacks
		UIWindow *originalKeyWindow = [[UIApplication sharedApplication] keyWindow];
		UIResponder *responder = originalKeyWindow.rootViewController.view;
		while ([responder isKindOfClass:[UIView class]]) responder = [responder nextResponder];
		[(UIViewController *)responder presentViewController:alertController animated:YES completion:^{}];
	} else {
		%orig;
	}

}
%end

%hook NSBundle
NSString *versionToSpoof = nil;
-(NSDictionary *)infoDictionary {
	NSDictionary *dictionary = %orig;
	NSMutableDictionary *moddedDictionary = [NSMutableDictionary dictionaryWithDictionary:dictionary];
	NSDictionary* modifiedBundlesDict = [[NSDictionary alloc] initWithContentsOfFile:SPOOF_VER_PLIST];
	if (!self || ![self isLoaded] || ![[self bundleURL].absoluteString containsString:@"Application"] || !isTweakEnabled) {
		return %orig;
	}

	NSString *appBundleID = moddedDictionary[@"CFBundleIdentifier"];
	if ((appBundleID) && 
	    ([modifiedBundlesDict objectForKey:appBundleID]) && 
		([[modifiedBundlesDict objectForKey:appBundleID] length] > 0) && 
		(![modifiedBundlesDict[appBundleID] isEqualToString:@"0"])) {
			//support old settings
			versionToSpoof = [[NSString alloc] init];
			versionToSpoof = modifiedBundlesDict[appBundleID];
			[moddedDictionary setValue:versionToSpoof forKey:@"CFBundleShortVersionString"];
			return moddedDictionary;
	} 
	
	if ([modifiedBundlesDict[[[NSProcessInfo processInfo] processName]][SPOOF_EXPERIMENTAL_KEY] boolValue] == YES) {
		versionToSpoof = modifiedBundlesDict[[[NSProcessInfo processInfo] processName]][SPOOF_APP_VERSION_KEY];
		[moddedDictionary setValue:versionToSpoof forKey:@"CFBundleShortVersionString"];
		return moddedDictionary;
	}

	if ((appBundleID) && 
		modifiedBundlesDict[[[NSProcessInfo processInfo] processName]] != nil && 
		[modifiedBundlesDict[[[NSProcessInfo processInfo] processName]][SPOOF_APP_BUNDLE_KEY] isEqualToString:appBundleID] &&
		![modifiedBundlesDict[[[NSProcessInfo processInfo] processName]][SPOOF_APP_VERSION_KEY] isEqualToString:@"0"]) {
				versionToSpoof = modifiedBundlesDict[[[NSProcessInfo processInfo] processName]][SPOOF_APP_VERSION_KEY];
				[moddedDictionary setValue:versionToSpoof forKey:@"CFBundleShortVersionString"];
				return moddedDictionary;
	}

	return %orig;
}
%end

%hook UIDevice
- (id)systemVersion {
	NSDictionary* modifiedBundlesDict = [[NSDictionary alloc] initWithContentsOfFile:SPOOF_VER_PLIST];
	if (modifiedBundlesDict[[[NSProcessInfo processInfo] processName]] != nil && ![modifiedBundlesDict[[[NSProcessInfo processInfo] processName]][SPOOF_IOS_VERSION_KEY] isEqualToString:@"0"]) {
		return modifiedBundlesDict[[[NSProcessInfo processInfo] processName]][SPOOF_IOS_VERSION_KEY];
	} 
	return %orig;
}
%end

%ctor{
	loadPrefs();
    CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, (CFNotificationCallback)loadPrefs, CFSTR("com.0xkuj.3dappversionspoofer.settingschanged"), NULL, CFNotificationSuspensionBehaviorCoalesce);
}