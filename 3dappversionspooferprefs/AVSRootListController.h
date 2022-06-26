#import <Preferences/PSListController.h>
#import <Preferences/PSSpecifier.h>
#define SPOOF_VER_PLIST @"com.0xkuj.3dappversionspoofer"
#define SPOOF_VER_PLIST_WITH_PATH @"/var/mobile/Library/Preferences/com.0xkuj.3dappversionspoofer.plist"

@interface AVSRootListController : PSListController
{
    UILabel* _label;
	UILabel* _underLabel;
}
@end
