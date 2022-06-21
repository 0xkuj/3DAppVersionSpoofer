#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>



#pragma GCC diagnostic ignored "-Wunused-variable"
#pragma GCC diagnostic ignored "-Wprotocol"
#pragma GCC diagnostic ignored "-Wmacro-redefined"
#pragma GCC diagnostic ignored "-Wdeprecated-declarations"
#pragma GCC diagnostic ignored "-Wincomplete-implementation"
#pragma GCC diagnostic ignored "-Wunknown-pragmas"
#pragma GCC diagnostic ignored "-Wformat"
#pragma GCC diagnostic ignored "-Wunknown-warning-option"
#pragma GCC diagnostic ignored "-Wincompatible-pointer-types"
#define SPOOF_VER_PLIST @"/var/mobile/Library/Preferences/com.0xkuj.spoofappversion.plist"
BOOL startChecking = FALSE;
@interface NSBundle ()
-(BOOL)isSelfBundleModified:(NSString *)bundleToSearch;
@end

@interface SpringBoard
-(id)_accessibilityFrontMostApplication;
@end


@interface RBSProcessIdentity : NSObject
@property(readonly, copy, nonatomic) NSString *executablePath;
@property(readonly, copy, nonatomic) NSString *embeddedApplicationIdentifier;
@end

@interface FBProcessExecutionContext : NSObject
@property (nonatomic,copy) NSDictionary* environment;
@property (nonatomic,copy) RBSProcessIdentity* identity;
@end


@interface SBApplication : NSObject

@property BOOL isSystemApplication;
@property NSString *bundleIdentifier;
-(void) setUninstalled:(BOOL)arg;
-(BOOL) iconCompleteUninstall:(id)arg;


@end

@interface SBIcon : NSObject


@end

@interface SBIconView : UIView

@property SBIcon *icon;

@end

@interface SBSApplicationShortcutItem : NSObject

@property (nonatomic,copy) NSString *type;
@property (nonatomic,copy) NSString *localizedTitle;
@property (nonatomic,copy) id icon;
@end

@interface SBSApplicationShortcutCustomImageIcon : NSObject
- (id)initWithImagePNGData:(id)arg1;
@end

//ADD ICON! organize this mess! 
%hook SBIconView
- (void)setApplicationShortcutItems:(NSArray *)ShortcutItems {
	//bug with spotlight..
	//SBApplication *sbApp = [self.icon valueForKey:@"_application"];
	//SBApplication *sbApp = MSHookIvar<SBApplication *>((id)self.icon, "_application");
	//if (sbApp.isSystemApplication || [sbApp.bundleIdentifier containsString:@"com.apple"]) {
	//		return %orig;
	//}

	NSMutableArray *editedItems = [NSMutableArray arrayWithArray:ShortcutItems ? : @[]];
	if (![self.icon isKindOfClass:%c(SBFolderIcon)] && ![self.icon isKindOfClass:%c(SBWidgetIcon)]) { 
		SBSApplicationShortcutItem *ShortcutItems = [[%c(SBSApplicationShortcutItem) alloc] init];
		ShortcutItems.localizedTitle = @"Spoof Version";
		ShortcutItems.type = @"com.0xkuj.spoofversion";
		NSData *ImageData = nil;
		ImageData = UIImagePNGRepresentation([UIImage imageNamed:@"/Library/Application Support/SpoofAppVersion.bundle/fakever@2x.png"]);
		if (ImageData) {
			SBSApplicationShortcutCustomImageIcon *IconImage = [[%c(SBSApplicationShortcutCustomImageIcon) alloc] initWithImagePNGData:ImageData];
			ShortcutItems.icon = IconImage;
		}
		if (ShortcutItems) {
			[editedItems addObject:ShortcutItems];
		}
	}
 	%orig(editedItems);
}

+ (void)activateShortcut:(SBSApplicationShortcutItem *)item withBundleIdentifier:(NSString *)bundleID forIconView:(SBIconView *)iconView {
    if ([item.type isEqualToString:@"com.0xkuj.spoofversion"]) {
		NSString *appName = [[NSBundle bundleWithIdentifier:bundleID] infoDictionary][@"CFBundleShortVersionString"];
		NSMutableDictionary *prefPlist = [NSMutableDictionary dictionary];
		[prefPlist addEntriesFromDictionary:[NSDictionary dictionaryWithContentsOfFile:SPOOF_VER_PLIST]];
	    UIAlertController* alertController = [UIAlertController alertControllerWithTitle:@"Spoof Version"
																	message:[NSString stringWithFormat:@"WARNING: This can cause unexpected behavior in your app.\nBundle ID: %@\nCurrent Spoofed Version: %@\nDefault Version: %@\n\nWhat is the version number you want to spoof?",bundleID,prefPlist[bundleID],appName]
																	preferredStyle:UIAlertControllerStyleAlert];

		[alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {textField.placeholder = @"Enter Version Number"; textField.keyboardType = UIKeyboardTypeDecimalPad;}];
		UIAlertAction *setNewValue = [UIAlertAction actionWithTitle:@"Set Version" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
			[prefPlist setObject:[[alertController textFields][0] text] forKey:bundleID];
			[prefPlist writeToFile:SPOOF_VER_PLIST atomically:YES];
		}];

		[alertController addAction:setNewValue];

		UIAlertAction *setDefaultValue = [UIAlertAction actionWithTitle:@"Set Default Version" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
			//0 means use original version!
			CGFloat defaultValue = 0.0f;
			NSNumber *numberFromFloat = [NSNumber numberWithFloat:defaultValue];
			[prefPlist setObject:[numberFromFloat stringValue] forKey:bundleID];
			[prefPlist writeToFile:SPOOF_VER_PLIST atomically:YES];
		}];
		[alertController addAction:setDefaultValue];

		UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style: UIAlertActionStyleCancel handler:^(UIAlertAction * action) {}];
		/* actually assign those actions to the buttons */
		[alertController addAction:cancelAction];
		/* present the dialog and wait for an answer */
		UIWindow* tempWindowForPrompt = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
		tempWindowForPrompt.rootViewController = [UIViewController new];
		tempWindowForPrompt.windowLevel = UIWindowLevelAlert+1;
		tempWindowForPrompt.hidden = NO;
		[tempWindowForPrompt makeKeyAndVisible];
		tempWindowForPrompt.tintColor = [[UIWindow valueForKey:@"keyWindow"] tintColor];
		[tempWindowForPrompt.rootViewController presentViewController:alertController animated:YES completion:nil];
	}
}
%end

%hook NSBundle
NSString *versionToSpoof = nil;
-(NSDictionary *)infoDictionary {
	if (!self || ![self isLoaded] || ![[self bundleURL].absoluteString containsString:@"Application"]) {
		return %orig;
	} else {	
	    NSDictionary *dictionary = %orig;
	    NSMutableDictionary *moddedDictionary = [NSMutableDictionary dictionaryWithDictionary:dictionary];
		NSString *mybundle = moddedDictionary[@"CFBundleIdentifier"];
		NSDictionary* modifiedBundlesDict = [[NSDictionary alloc] initWithContentsOfFile:SPOOF_VER_PLIST];
		if (mybundle && [modifiedBundlesDict objectForKey:mybundle] && ![modifiedBundlesDict[mybundle] isEqualToString:@"0"]) {
			versionToSpoof = [[NSString alloc] init];
			versionToSpoof = modifiedBundlesDict[mybundle];
			[moddedDictionary setValue:versionToSpoof forKey:@"CFBundleShortVersionString"];
		}
		return moddedDictionary;
	}
}
%end