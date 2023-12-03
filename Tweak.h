#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <rootless.h>
#include <roothide.h>

#define SPOOF_VER_PLIST jbroot(ROOT_PATH_NS(@"/var/mobile/Library/Preferences/com.0xkuj.3dappversionspoofer.plist"))
#define SPOOF_VER_TWEAK_BUNDLE @"com.0xkuj.3DAppVersionSpoofer"
#define SPOOF_APP_VERSION_KEY @"appVersionToSpoof"
#define SPOOF_IOS_VERSION_KEY @"iosVersionToSpoof"
#define SPOOF_EXPERIMENTAL_KEY @"ExperimentalSpoof"
#define SPOOF_APP_BUNDLE_KEY @"appBundle"

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
- (id)applicationBundleURLForShortcuts;
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
