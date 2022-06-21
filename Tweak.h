#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

#define SPOOF_VER_PLIST @"/var/mobile/Library/Preferences/com.0xkuj.3dappversionspoofer.plist"
#define SPOOF_VER_TWEAK_BUNDLE @"com.0xkuj.3DAppVersionSpoofer"

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
