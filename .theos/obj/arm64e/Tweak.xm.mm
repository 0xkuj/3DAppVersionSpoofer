#line 1 "Tweak.xm"
#include "Tweak.h"


#include <substrate.h>
#if defined(__clang__)
#if __has_feature(objc_arc)
#define _LOGOS_SELF_TYPE_NORMAL __unsafe_unretained
#define _LOGOS_SELF_TYPE_INIT __attribute__((ns_consumed))
#define _LOGOS_SELF_CONST const
#define _LOGOS_RETURN_RETAINED __attribute__((ns_returns_retained))
#else
#define _LOGOS_SELF_TYPE_NORMAL
#define _LOGOS_SELF_TYPE_INIT
#define _LOGOS_SELF_CONST
#define _LOGOS_RETURN_RETAINED
#endif
#else
#define _LOGOS_SELF_TYPE_NORMAL
#define _LOGOS_SELF_TYPE_INIT
#define _LOGOS_SELF_CONST
#define _LOGOS_RETURN_RETAINED
#endif

@class SBIconView; @class SBSApplicationShortcutItem; @class SBSApplicationShortcutCustomImageIcon; @class SBWidgetIcon; @class SBFolderIcon; @class NSBundle; 
static void (*_logos_orig$_ungrouped$SBIconView$setApplicationShortcutItems$)(_LOGOS_SELF_TYPE_NORMAL SBIconView* _LOGOS_SELF_CONST, SEL, NSArray *); static void _logos_method$_ungrouped$SBIconView$setApplicationShortcutItems$(_LOGOS_SELF_TYPE_NORMAL SBIconView* _LOGOS_SELF_CONST, SEL, NSArray *); static void (*_logos_meta_orig$_ungrouped$SBIconView$activateShortcut$withBundleIdentifier$forIconView$)(_LOGOS_SELF_TYPE_NORMAL Class _LOGOS_SELF_CONST, SEL, SBSApplicationShortcutItem *, NSString *, SBIconView *); static void _logos_meta_method$_ungrouped$SBIconView$activateShortcut$withBundleIdentifier$forIconView$(_LOGOS_SELF_TYPE_NORMAL Class _LOGOS_SELF_CONST, SEL, SBSApplicationShortcutItem *, NSString *, SBIconView *); static NSDictionary * (*_logos_orig$_ungrouped$NSBundle$infoDictionary)(_LOGOS_SELF_TYPE_NORMAL NSBundle* _LOGOS_SELF_CONST, SEL); static NSDictionary * _logos_method$_ungrouped$NSBundle$infoDictionary(_LOGOS_SELF_TYPE_NORMAL NSBundle* _LOGOS_SELF_CONST, SEL); 
static __inline__ __attribute__((always_inline)) __attribute__((unused)) Class _logos_static_class_lookup$SBWidgetIcon(void) { static Class _klass; if(!_klass) { _klass = objc_getClass("SBWidgetIcon"); } return _klass; }static __inline__ __attribute__((always_inline)) __attribute__((unused)) Class _logos_static_class_lookup$SBFolderIcon(void) { static Class _klass; if(!_klass) { _klass = objc_getClass("SBFolderIcon"); } return _klass; }static __inline__ __attribute__((always_inline)) __attribute__((unused)) Class _logos_static_class_lookup$SBSApplicationShortcutItem(void) { static Class _klass; if(!_klass) { _klass = objc_getClass("SBSApplicationShortcutItem"); } return _klass; }static __inline__ __attribute__((always_inline)) __attribute__((unused)) Class _logos_static_class_lookup$SBSApplicationShortcutCustomImageIcon(void) { static Class _klass; if(!_klass) { _klass = objc_getClass("SBSApplicationShortcutCustomImageIcon"); } return _klass; }
#line 3 "Tweak.xm"

static void _logos_method$_ungrouped$SBIconView$setApplicationShortcutItems$(_LOGOS_SELF_TYPE_NORMAL SBIconView* _LOGOS_SELF_CONST __unused self, SEL __unused _cmd, NSArray * shortcutItems) {
	
	
	
	
	
	

	NSMutableArray *editedItems = [NSMutableArray arrayWithArray:shortcutItems ? : @[]];
	if (![self.icon isKindOfClass:_logos_static_class_lookup$SBFolderIcon()] && ![self.icon isKindOfClass:_logos_static_class_lookup$SBWidgetIcon()]) { 
		SBSApplicationShortcutItem *shortcutItems = [[_logos_static_class_lookup$SBSApplicationShortcutItem() alloc] init];
		shortcutItems.localizedTitle = @"Spoof App Version";
		shortcutItems.type = SPOOF_VER_TWEAK_BUNDLE;
		NSData *imgData = UIImagePNGRepresentation([UIImage imageNamed:@"/Library/Application Support/3DAppVersionSpoofer.bundle/fakeverblack@2x.png"]);
		
		
		if ([UITraitCollection currentTraitCollection].userInterfaceStyle == UIUserInterfaceStyleDark) {
			imgData = UIImagePNGRepresentation([UIImage imageNamed:@"/Library/Application Support/3DAppVersionSpoofer.bundle/fakeverwhite@2x.png"]);
		}
		if (imgData) {
			SBSApplicationShortcutCustomImageIcon *iconImage = [[_logos_static_class_lookup$SBSApplicationShortcutCustomImageIcon() alloc] initWithImagePNGData:imgData];
			shortcutItems.icon = iconImage;
		}
		if (shortcutItems) {
			[editedItems addObject:shortcutItems];
		}
	}
 	_logos_orig$_ungrouped$SBIconView$setApplicationShortcutItems$(self, _cmd, editedItems);
}

static void _logos_meta_method$_ungrouped$SBIconView$activateShortcut$withBundleIdentifier$forIconView$(_LOGOS_SELF_TYPE_NORMAL Class _LOGOS_SELF_CONST __unused self, SEL __unused _cmd, SBSApplicationShortcutItem * item, NSString * bundleID, SBIconView * iconView) {
    if ([item.type isEqualToString:SPOOF_VER_TWEAK_BUNDLE]) {
		NSString *appName = [[NSBundle bundleWithIdentifier:bundleID] infoDictionary][@"CFBundleShortVersionString"];
		NSMutableDictionary *prefPlist = [NSMutableDictionary dictionary];
		[prefPlist addEntriesFromDictionary:[NSDictionary dictionaryWithContentsOfFile:SPOOF_VER_PLIST]];
		NSString *currentVer = prefPlist[bundleID];
		if (currentVer == nil || [currentVer isEqualToString:@"0"]) {
			currentVer = @"Default";
		}
	    UIAlertController* alertController = [UIAlertController alertControllerWithTitle:@"3DAppVersionSpoofer"
																	message:[NSString stringWithFormat:@"WARNING: This can cause unexpected behavior in your app.\nBundle ID: %@\nCurrent Spoofed Version: %@\nDefault App Version: %@\n\nWhat is the version number you want to spoof?",bundleID,currentVer,appName]
																	preferredStyle:UIAlertControllerStyleAlert];

		[alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {textField.placeholder = @"Enter Version Number"; textField.keyboardType = UIKeyboardTypeDecimalPad;}];
		UIAlertAction *setNewValue = [UIAlertAction actionWithTitle:@"Set Spoofed Version" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
			[prefPlist setObject:[[alertController textFields][0] text] forKey:bundleID];
			[prefPlist writeToFile:SPOOF_VER_PLIST atomically:YES];
		}];

		[alertController addAction:setNewValue];

		UIAlertAction *setDefaultValue = [UIAlertAction actionWithTitle:@"Set Default Version" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
			
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
	}
}



NSString *versionToSpoof = nil;
static NSDictionary * _logos_method$_ungrouped$NSBundle$infoDictionary(_LOGOS_SELF_TYPE_NORMAL NSBundle* _LOGOS_SELF_CONST __unused self, SEL __unused _cmd) {
	if (!self || ![self isLoaded] || ![[self bundleURL].absoluteString containsString:@"Application"]) {
		return _logos_orig$_ungrouped$NSBundle$infoDictionary(self, _cmd);
	} else {	
	    NSDictionary *dictionary = _logos_orig$_ungrouped$NSBundle$infoDictionary(self, _cmd);
	    NSMutableDictionary *moddedDictionary = [NSMutableDictionary dictionaryWithDictionary:dictionary];
		NSString *appBundleID = moddedDictionary[@"CFBundleIdentifier"];
		NSDictionary* modifiedBundlesDict = [[NSDictionary alloc] initWithContentsOfFile:SPOOF_VER_PLIST];
		if (appBundleID && [modifiedBundlesDict objectForKey:appBundleID] && ![modifiedBundlesDict[appBundleID] isEqualToString:@"0"]) {
			versionToSpoof = [[NSString alloc] init];
			versionToSpoof = modifiedBundlesDict[appBundleID];
			[moddedDictionary setValue:versionToSpoof forKey:@"CFBundleShortVersionString"];
		}
		return moddedDictionary;
	}
}

static __attribute__((constructor)) void _logosLocalInit() {
{Class _logos_class$_ungrouped$SBIconView = objc_getClass("SBIconView"); Class _logos_metaclass$_ungrouped$SBIconView = object_getClass(_logos_class$_ungrouped$SBIconView); { MSHookMessageEx(_logos_class$_ungrouped$SBIconView, @selector(setApplicationShortcutItems:), (IMP)&_logos_method$_ungrouped$SBIconView$setApplicationShortcutItems$, (IMP*)&_logos_orig$_ungrouped$SBIconView$setApplicationShortcutItems$);}{ MSHookMessageEx(_logos_metaclass$_ungrouped$SBIconView, @selector(activateShortcut:withBundleIdentifier:forIconView:), (IMP)&_logos_meta_method$_ungrouped$SBIconView$activateShortcut$withBundleIdentifier$forIconView$, (IMP*)&_logos_meta_orig$_ungrouped$SBIconView$activateShortcut$withBundleIdentifier$forIconView$);}Class _logos_class$_ungrouped$NSBundle = objc_getClass("NSBundle"); { MSHookMessageEx(_logos_class$_ungrouped$NSBundle, @selector(infoDictionary), (IMP)&_logos_method$_ungrouped$NSBundle$infoDictionary, (IMP*)&_logos_orig$_ungrouped$NSBundle$infoDictionary);}} }
#line 96 "Tweak.xm"
