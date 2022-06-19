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

%hook SBIconView
- (void)setApplicationShortcutItems:(NSArray *)ShortcutItems {

SBApplication *sbApp = [self.icon valueForKey:@"_application"];

if (sbApp.isSystemApplication || [sbApp.bundleIdentifier containsString:@"com.apple"])
    return %orig;

NSMutableArray *NewItems = [NSMutableArray arrayWithArray:ShortcutItems ? : @[]];

if (![self.icon isKindOfClass:%c(SBFolderIcon)] && ![self.icon isKindOfClass:%c(SBWidgetIcon)]) { 
	SBSApplicationShortcutItem *ShortcutItems = [[%c(SBSApplicationShortcutItem) alloc] init];
	ShortcutItems.localizedTitle = @"Spoof Version";
	ShortcutItems.type = @"com.0xkuj.spoofversion";
	NSData *ImageData = nil;
	ImageData = UIImagePNGRepresentation([UIImage imageNamed:@"/Library/Application Support/JustRemoveIt.bundle/Remove@2x.png"]);
	if (ImageData) {
		SBSApplicationShortcutCustomImageIcon *IconImage = [[%c(SBSApplicationShortcutCustomImageIcon) alloc] initWithImagePNGData:ImageData];
		ShortcutItems.icon = IconImage;
	}

	if (ShortcutItems) {
		[NewItems insertObject:ShortcutItems atIndex:0];
	}
  }
  %orig(NewItems);
}

+ (void)activateShortcut:(SBSApplicationShortcutItem *)item withBundleIdentifier:(NSString *)bundleID forIconView:(SBIconView *)iconView {

    if ([item.type isEqualToString:@"com.0xkuj.spoofversion"]) {
	    UIAlertController* alertController = [UIAlertController alertControllerWithTitle:@"Spoof Version\n(bundleID: ...)"
																	message:@"Warning: This can cause unexpected behavior in your app.\nWhat is the version number you want to spoof?"
																	preferredStyle:UIAlertControllerStyleAlert];

		[alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {textField.placeholder = @"Enter Version Number"; textField.keyboardType = UIKeyboardTypeDecimalPad;}];
		UIAlertAction *setNewValue = [UIAlertAction actionWithTitle:@"Set Version" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {	
			NSMutableDictionary* settingsFile = [[NSMutableDictionary alloc] init];
			[settingsFile setObject:[[alertController textFields][0] text] forKey:bundleID];
			[settingsFile writeToFile:SPOOF_VER_PLIST atomically:YES];
		}];

	[alertController addAction:setNewValue];

	UIAlertAction *setDefaultValue = [UIAlertAction actionWithTitle:@"Set Default Version" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
		//0 means use original version!
		CGFloat defaultValue = 0.0f;
		NSNumber *numberFromFloat = [NSNumber numberWithFloat:defaultValue];
        NSMutableDictionary* settingsFile = [[NSMutableDictionary alloc] init];
        [settingsFile setObject:[numberFromFloat stringValue] forKey:bundleID];
        [settingsFile writeToFile:SPOOF_VER_PLIST atomically:YES];
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
    tempWindowForPrompt.tintColor = [[UIWindow valueForKey:@"keyWindow"] tintColor];
    //[tempWindowForPrompt _setSecure:YES];
	[tempWindowForPrompt.rootViewController presentViewController:alertController animated:YES completion:nil];
    //dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{

	//	[NSThread sleepForTimeInterval:0.10];

	//	dispatch_async(dispatch_get_main_queue(), ^{

			//popup with text field for version
			//3 options: cancel, set, back to default
			//logic: write the version to the file, and everytime this app loads, it will take the version from the
			//tweak plist file..
			//how will we validate the app and the file?
			//probably save dict, bundleid : version..
			//if the bundle matches, then take the version from plist, if not, take orig.
			//if using original then set the 
			//SBApplication *sbApp = [iconView.icon valueForKey:@"_application"];
			//[sbApp setUninstalled:YES];
			//[sbApp performSelector:@selector(iconCompleteUninstall:)];
    //	});
	//});

    } else {
		NSLog(@"omriku orig?");
       // %orig;
    }
}
%end

%hook FBProcessManager
- (id)_createProcessWithExecutionContext:(FBProcessExecutionContext*)executionContext
{
	//NSLog(@"omriku bundle is: %@", executionContext.identity.embeddedApplicationIdentifier);
	if ([executionContext.identity.embeddedApplicationIdentifier isEqualToString:@"il.co.migdal.customers"]) {
		startChecking = TRUE;
	}	
	return %orig;
}
%end

%hook NSBundle
BOOL shouldKeepChecking = TRUE;
NSString *versionToSpoof = nil;
-(NSDictionary *)infoDictionary {
	if (!startChecking) {
		return %orig;
	} else {
	    NSDictionary *dictionary = %orig;
	    NSMutableDictionary *moddedDictionary = [NSMutableDictionary dictionaryWithDictionary:dictionary];
		if ([[moddedDictionary objectForKey:@"CFBundleIdentifier"] isEqualToString:@"il.co.migdal.customers"])
		{
			NSLog(@"omriku started checking..");
			//shouldKeepChecking = [self isSelfBundleModified:[self bundleIdentifier]];
			NSLog(@"omriku version to spoof.. %@", versionToSpoof);
			//if (versionToSpoof) {
			NSString* vertosp = @"1.1";
			[moddedDictionary setValue:@"1.1" forKey:@"CFBundleShortVersionString"];
			//}
			return moddedDictionary;
		}
	}
	return %orig;
	//}
	//if (![[dictionary objectForKey:@"CFBundleName"] isEqualToString:@"customersProd"]) {
	//	return %orig;
	//}
	//check if inside modified bundle..
	// NSLog(@"omriku checking bundle.. %@ shouldkeep: %d", [self bundleIdentifier], shouldKeepChecking);
	// if (shouldKeepChecking) {
	// 	shouldKeepChecking = [self isSelfBundleModified:[self bundleIdentifier]];
	// 	NSLog(@"omriku version to spoof.. %@", versionToSpoof);
	// 	if (versionToSpoof) {
	// 		[moddedDictionary setValue:versionToSpoof forKey:@"CFBundleShortVersionString"];
	// 	}
	// 	return moddedDictionary;
	// } else {
	// 	return %orig;
	// }
	//return %orig;
}

%new
-(BOOL)isSelfBundleModified:(NSString *)bundleToSearch {
	NSDictionary* modifiedBundlesDict = [[NSDictionary alloc] initWithContentsOfFile:SPOOF_VER_PLIST];
	//this means the bundle was modified
	for (NSString *bundleKey in modifiedBundlesDict) {
		if ([bundleKey isEqualToString:bundleToSearch] && modifiedBundlesDict[bundleKey] != 0) {
			versionToSpoof = [[NSString alloc] init];
			versionToSpoof = modifiedBundlesDict[bundleKey];
			return TRUE;
		}
	}
	
	return FALSE;
}
%end

// %ctor
// {
// 	dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 25 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
// 		%init(classHookName = objc_getClass("NSBundle"));
// 	});
    
// }

%ctor { 
	[[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationDidFinishLaunchingNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *notification) 
	{ startChecking=TRUE; }];
}