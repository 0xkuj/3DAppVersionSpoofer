#import <Preferences/PSListController.h>
#import <Preferences/PSSpecifier.h>
#import <rootless.h>
#include <roothide.h>

#define SPOOF_VER_PLIST @"com.0xkuj.3dappversionspoofer"
#define SPOOF_VER_PLIST_WITH_PATH jbroot(ROOT_PATH_NS(@"/var/mobile/Library/Preferences/com.0xkuj.3dappversionspoofer.plist"))

@interface AVSRootListController : PSListController
{
    UILabel* _label;
	UILabel* _underLabel;
}
@end
