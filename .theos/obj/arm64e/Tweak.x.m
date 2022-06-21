#line 1 "Tweak.x"
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

@class SBSApplicationShortcutCustomImageIcon; @class SBFolderIcon; @class NSBundle; @class SBWidgetIcon; @class SBSApplicationShortcutItem; @class SBIconView; 
static void (*_logos_orig$_ungrouped$SBIconView$setApplicationShortcutItems$)(_LOGOS_SELF_TYPE_NORMAL SBIconView* _LOGOS_SELF_CONST, SEL, NSArray *); static void _logos_method$_ungrouped$SBIconView$setApplicationShortcutItems$(_LOGOS_SELF_TYPE_NORMAL SBIconView* _LOGOS_SELF_CONST, SEL, NSArray *); static void (*_logos_meta_orig$_ungrouped$SBIconView$activateShortcut$withBundleIdentifier$forIconView$)(_LOGOS_SELF_TYPE_NORMAL Class _LOGOS_SELF_CONST, SEL, SBSApplicationShortcutItem *, NSString *, SBIconView *); static void _logos_meta_method$_ungrouped$SBIconView$activateShortcut$withBundleIdentifier$forIconView$(_LOGOS_SELF_TYPE_NORMAL Class _LOGOS_SELF_CONST, SEL, SBSApplicationShortcutItem *, NSString *, SBIconView *); static NSDictionary * (*_logos_orig$_ungrouped$NSBundle$infoDictionary)(_LOGOS_SELF_TYPE_NORMAL NSBundle* _LOGOS_SELF_CONST, SEL); static NSDictionary * _logos_method$_ungrouped$NSBundle$infoDictionary(_LOGOS_SELF_TYPE_NORMAL NSBundle* _LOGOS_SELF_CONST, SEL); 
static __inline__ __attribute__((always_inline)) __attribute__((unused)) Class _logos_static_class_lookup$SBWidgetIcon(void) { static Class _klass; if(!_klass) { _klass = objc_getClass("SBWidgetIcon"); } return _klass; }static __inline__ __attribute__((always_inline)) __attribute__((unused)) Class _logos_static_class_lookup$SBSApplicationShortcutItem(void) { static Class _klass; if(!_klass) { _klass = objc_getClass("SBSApplicationShortcutItem"); } return _klass; }static __inline__ __attribute__((always_inline)) __attribute__((unused)) Class _logos_static_class_lookup$SBFolderIcon(void) { static Class _klass; if(!_klass) { _klass = objc_getClass("SBFolderIcon"); } return _klass; }static __inline__ __attribute__((always_inline)) __attribute__((unused)) Class _logos_static_class_lookup$SBSApplicationShortcutCustomImageIcon(void) { static Class _klass; if(!_klass) { _klass = objc_getClass("SBSApplicationShortcutCustomImageIcon"); } return _klass; }
#line 71 "Tweak.x"

static void _logos_method$_ungrouped$SBIconView$setApplicationShortcutItems$(_LOGOS_SELF_TYPE_NORMAL SBIconView* _LOGOS_SELF_CONST __unused self, SEL __unused _cmd, NSArray * ShortcutItems) {
	
	
	
	
	

	NSMutableArray *NewItems = [NSMutableArray arrayWithArray:ShortcutItems ? : @[]];
	if (![self.icon isKindOfClass:_logos_static_class_lookup$SBFolderIcon()] && ![self.icon isKindOfClass:_logos_static_class_lookup$SBWidgetIcon()]) { 
		SBSApplicationShortcutItem *ShortcutItems = [[_logos_static_class_lookup$SBSApplicationShortcutItem() alloc] init];
		ShortcutItems.localizedTitle = @"Spoof Version";
		ShortcutItems.type = @"com.0xkuj.spoofversion";
		NSData *ImageData = nil;
		ImageData = UIImagePNGRepresentation([UIImage imageNamed:@"/Library/Application Support/SpoofAppVersion.bundle/fakever@2x.png"]);
		if (ImageData) {
			SBSApplicationShortcutCustomImageIcon *IconImage = [[_logos_static_class_lookup$SBSApplicationShortcutCustomImageIcon() alloc] initWithImagePNGData:ImageData];
			ShortcutItems.icon = IconImage;
		}

		if (ShortcutItems) {
			[NewItems addObject:ShortcutItems];
		}
	}

 	_logos_orig$_ungrouped$SBIconView$setApplicationShortcutItems$(self, _cmd, NewItems);
}

static void _logos_meta_method$_ungrouped$SBIconView$activateShortcut$withBundleIdentifier$forIconView$(_LOGOS_SELF_TYPE_NORMAL Class _LOGOS_SELF_CONST __unused self, SEL __unused _cmd, SBSApplicationShortcutItem * item, NSString * bundleID, SBIconView * iconView) {
    if ([item.type isEqualToString:@"com.0xkuj.spoofversion"]) {
		NSString *appName = [[NSBundle bundleWithIdentifier:@"il.co.migdal.customers"] infoDictionary][@"CFBundleShortVersionString"];
		NSMutableDictionary *prefPlist = [NSMutableDictionary dictionary];
		[prefPlist addEntriesFromDictionary:[NSDictionary dictionaryWithContentsOfFile:SPOOF_VER_PLIST]];
	    UIAlertController* alertController = [UIAlertController alertControllerWithTitle:@"Spoof Version"
																	message:[NSString stringWithFormat:@"Bundle ID: %@\nCurrent Spoofed Version: %@\nappname: %@\nWARNING: This can cause unexpected behavior in your app.\nWhat is the version number you want to spoof?",bundleID,prefPlist[bundleID],appName]
																	preferredStyle:UIAlertControllerStyleAlert];

		[alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {textField.placeholder = @"Enter Version Number"; textField.keyboardType = UIKeyboardTypeDecimalPad;}];
		UIAlertAction *setNewValue = [UIAlertAction actionWithTitle:@"Set Version" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
			[prefPlist setObject:[[alertController textFields][0] text] forKey:bundleID];
			[prefPlist writeToFile:SPOOF_VER_PLIST atomically:YES];
		}];

		[alertController addAction:setNewValue];

		UIAlertAction *setDefaultValue = [UIAlertAction actionWithTitle:@"Set Default Version" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
			
			CGFloat defaultValue = 0.0f;
			NSNumber *numberFromFloat = [NSNumber numberWithFloat:defaultValue];
			NSMutableDictionary* settingsFile = [[NSMutableDictionary alloc] init];
			[settingsFile setObject:[numberFromFloat stringValue] forKey:bundleID];
			[settingsFile writeToFile:SPOOF_VER_PLIST atomically:YES];
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

static __attribute__((constructor)) void _logosLocalInit() {
{Class _logos_class$_ungrouped$SBIconView = objc_getClass("SBIconView"); Class _logos_metaclass$_ungrouped$SBIconView = object_getClass(_logos_class$_ungrouped$SBIconView); { MSHookMessageEx(_logos_class$_ungrouped$SBIconView, @selector(setApplicationShortcutItems:), (IMP)&_logos_method$_ungrouped$SBIconView$setApplicationShortcutItems$, (IMP*)&_logos_orig$_ungrouped$SBIconView$setApplicationShortcutItems$);}{ MSHookMessageEx(_logos_metaclass$_ungrouped$SBIconView, @selector(activateShortcut:withBundleIdentifier:forIconView:), (IMP)&_logos_meta_method$_ungrouped$SBIconView$activateShortcut$withBundleIdentifier$forIconView$, (IMP*)&_logos_meta_orig$_ungrouped$SBIconView$activateShortcut$withBundleIdentifier$forIconView$);}Class _logos_class$_ungrouped$NSBundle = objc_getClass("NSBundle"); { MSHookMessageEx(_logos_class$_ungrouped$NSBundle, @selector(infoDictionary), (IMP)&_logos_method$_ungrouped$NSBundle$infoDictionary, (IMP*)&_logos_orig$_ungrouped$NSBundle$infoDictionary);}} }
#line 160 "Tweak.x"
