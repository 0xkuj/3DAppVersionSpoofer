#include "Tweak.h"

BOOL isTweakEnabled, is3DMenu;
static void loadPrefs() { 
	NSMutableDictionary* mainPreferenceDict = [[NSMutableDictionary alloc] initWithContentsOfFile:SPOOF_VER_PLIST];
	isTweakEnabled = [mainPreferenceDict objectForKey:@"isTweakEnabled"] ? [[mainPreferenceDict objectForKey:@"isTweakEnabled"] boolValue] : YES;
	is3DMenu = [mainPreferenceDict objectForKey:@"is3DMenu"] ? [[mainPreferenceDict objectForKey:@"is3DMenu"] boolValue] : YES;
}

%hook SBIconView
- (void)setApplicationShortcutItems:(NSArray *)shortcutItems {
	//bug with spotlight..
	//SBApplication *sbApp = [self.icon valueForKey:@"_application"];
	//SBApplication *sbApp = MSHookIvar<SBApplication *>((id)self.icon, "_application");
	//if (sbApp.isSystemApplication || [sbApp.bundleIdentifier containsString:@"com.apple"]) {
	//		return %orig;
	//}
	if (!is3DMenu) {
		return %orig;
	}

	NSMutableArray *editedItems = [NSMutableArray arrayWithArray:shortcutItems ? : @[]];
	if (![self.icon isKindOfClass:%c(SBFolderIcon)] && ![self.icon isKindOfClass:%c(SBWidgetIcon)]) { 
		SBSApplicationShortcutItem *shortcutItems = [[%c(SBSApplicationShortcutItem) alloc] init];
		shortcutItems.localizedTitle = @"Spoof App Version";
		shortcutItems.type = SPOOF_VER_TWEAK_BUNDLE;
		NSData *imgData = UIImagePNGRepresentation([UIImage imageNamed:@"/Library/Application Support/3DAppVersionSpoofer.bundle/fakeverblack@2x.png"]);
		//dark mode check
		//if (@available(iOS 13, *)) {
		if ([UITraitCollection currentTraitCollection].userInterfaceStyle == UIUserInterfaceStyleDark) {
			imgData = UIImagePNGRepresentation([UIImage imageNamed:@"/Library/Application Support/3DAppVersionSpoofer.bundle/fakeverwhite@2x.png"]);
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
		NSString *appDefaultVersion = [[NSBundle bundleWithIdentifier:bundleID] infoDictionary][@"CFBundleShortVersionString"];
		NSMutableDictionary *prefPlist = [NSMutableDictionary dictionary];
		[prefPlist addEntriesFromDictionary:[NSDictionary dictionaryWithContentsOfFile:SPOOF_VER_PLIST]];
		NSString *currentVer = prefPlist[bundleID];
		if (currentVer == nil || [currentVer isEqualToString:@"0"]) {
			currentVer = @"Default";
		}
	    UIAlertController* alertController = [UIAlertController alertControllerWithTitle:@"3DAppVersionSpoofer"
																	message:[NSString stringWithFormat:@"WARNING: This can cause unexpected behavior in your app.\nBundle ID: %@\nCurrent Spoofed Version: %@\nDefault App Version: %@\n\nWhat is the version number you want to spoof?",bundleID,currentVer,appDefaultVersion]
																	preferredStyle:UIAlertControllerStyleAlert];

		[alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {textField.placeholder = @"Enter Version Number"; textField.keyboardType = UIKeyboardTypeDecimalPad;}];
		UIAlertAction *setNewValue = [UIAlertAction actionWithTitle:@"Set Spoofed Version" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
			NSString *answerFromTextField = ([[alertController textFields][0] text].length > 0) ? [[alertController textFields][0] text] : @"0";
			//support regions that have comma instead of dot 0-0
			[prefPlist setObject:[answerFromTextField stringByReplacingOccurrencesOfString:@"," withString:@"."] forKey:bundleID];
			[prefPlist writeToFile:SPOOF_VER_PLIST atomically:YES];
		}];

		[alertController addAction:setNewValue];

		UIAlertAction *setDefaultValue = [UIAlertAction actionWithTitle:@"Reset to Default Version" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
			//0 means use original version!
			CGFloat defaultValue = 0.0f;
			NSNumber *numberFromFloat = [NSNumber numberWithFloat:defaultValue];
			[prefPlist setObject:[numberFromFloat stringValue] forKey:bundleID];
			[prefPlist writeToFile:SPOOF_VER_PLIST atomically:YES];
		}];
		[alertController addAction:setDefaultValue];

		UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style: UIAlertActionStyleCancel handler:^(UIAlertAction * action) {}];
		[alertController addAction:cancelAction];
		UIWindow* tempWindowForPrompt = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
		tempWindowForPrompt.rootViewController = [UIViewController new];
		tempWindowForPrompt.windowLevel = UIWindowLevelAlert+1;
		tempWindowForPrompt.hidden = NO;
		[tempWindowForPrompt makeKeyAndVisible];
		tempWindowForPrompt.tintColor = [[UIWindow valueForKey:@"keyWindow"] tintColor];
		[tempWindowForPrompt.rootViewController presentViewController:alertController animated:YES completion:nil];
	} else {
		%orig;
	}

}
%end

%hook NSBundle
NSString *versionToSpoof = nil;
-(NSDictionary *)infoDictionary {
	if (!self || ![self isLoaded] || ![[self bundleURL].absoluteString containsString:@"Application"] || !isTweakEnabled) {
		return %orig;
	} else {	
	    NSDictionary *dictionary = %orig;
	    NSMutableDictionary *moddedDictionary = [NSMutableDictionary dictionaryWithDictionary:dictionary];
		NSString *appBundleID = moddedDictionary[@"CFBundleIdentifier"];
		NSDictionary* modifiedBundlesDict = [[NSDictionary alloc] initWithContentsOfFile:SPOOF_VER_PLIST];
		if ((appBundleID) && ([modifiedBundlesDict objectForKey:appBundleID]) && ([[modifiedBundlesDict objectForKey:appBundleID] length] > 0) && (![modifiedBundlesDict[appBundleID] isEqualToString:@"0"])) {
			versionToSpoof = [[NSString alloc] init];
			versionToSpoof = modifiedBundlesDict[appBundleID];
			[moddedDictionary setValue:versionToSpoof forKey:@"CFBundleShortVersionString"];
		}
		return moddedDictionary;
	}
}
%end

%ctor{
	loadPrefs();
    CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, (CFNotificationCallback)loadPrefs, CFSTR("com.0xkuj.3dappversionspoofer.settingschanged"), NULL, CFNotificationSuspensionBehaviorCoalesce);
}