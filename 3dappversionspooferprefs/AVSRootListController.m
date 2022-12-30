#include "AVSRootListController.h"
#import <spawn.h>

@implementation AVSRootListController

- (NSArray *)specifiers {
	if (!_specifiers) {
		_specifiers = [self loadSpecifiersFromPlistName:@"Root" target:self];
	}

	return _specifiers;
}

- (void)loadView {
    [super loadView];
	[self headerCell];
}

- (void)headerCell
{
	@autoreleasepool {
	UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 140)];
	int width = [[UIScreen mainScreen] bounds].size.width;
	CGRect frame = CGRectMake(0, 20, width, 60);
	CGRect botFrame = CGRectMake(0, 55, width, 60);
 
		_label = [[UILabel alloc] initWithFrame:frame];
		[_label setNumberOfLines:1];
		_label.font = [UIFont fontWithName:@"HelveticaNeue-UltraLight" size:35];
		[_label setText:@"3DAppVersionSpoofer"];
		[_label setBackgroundColor:[UIColor clearColor]];
		_label.textAlignment = NSTextAlignmentCenter;
		_label.alpha = 1;

		_underLabel = [[UILabel alloc] initWithFrame:botFrame];
		[_underLabel setNumberOfLines:4];
		_underLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:14];
		[_underLabel setText:@"\nSpoof Any App Version\n\n Created by 0xkuj"];
		[_underLabel setBackgroundColor:[UIColor clearColor]];
		_underLabel.textColor = [UIColor grayColor];
		_underLabel.textAlignment = NSTextAlignmentCenter;
		_underLabel.alpha = 1;
		
		[headerView addSubview:_label];
		[headerView addSubview:_underLabel];
		
		[[self table] setTableHeaderView:headerView];		
	}
}

/* read values from preferences */
- (id)readPreferenceValue:(PSSpecifier*)specifier {
	NSString *path = [NSString stringWithFormat:@"/var/mobile/Library/Preferences/%@.plist", specifier.properties[@"defaults"]];
	NSMutableDictionary *settings = [NSMutableDictionary dictionary];
	[settings addEntriesFromDictionary:[NSDictionary dictionaryWithContentsOfFile:path]];
	return (settings[specifier.properties[@"key"]]) ?: specifier.properties[@"default"];
}

/* set the value immediately when needed */
- (void)setPreferenceValue:(id)value specifier:(PSSpecifier*)specifier {
	NSString *path = [NSString stringWithFormat:@"/var/mobile/Library/Preferences/%@.plist", specifier.properties[@"defaults"]];
	NSMutableDictionary *settings = [NSMutableDictionary dictionary];
	[settings addEntriesFromDictionary:[NSDictionary dictionaryWithContentsOfFile:path]];
	[settings setObject:value forKey:specifier.properties[@"key"]];
	[settings writeToFile:path atomically:YES];
	CFStringRef notificationName = (__bridge CFStringRef)specifier.properties[@"PostNotification"];
	if (notificationName) {
		CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), notificationName, NULL, NULL, YES);
	}
}

/* default settings and repsring right after. files to be deleted are specified in this function */
-(void)defaultsettings:(PSSpecifier*)specifier {
	UIAlertController* alertController = [UIAlertController alertControllerWithTitle:@"Confirmation"
    									                    message:@"This will restore 3DAppVersionSpoofer Settings to default\nAre you sure?" 
    														preferredStyle:UIAlertControllerStyleAlert];
	/* prepare function for "yes" button */
	UIAlertAction* OKAction = [UIAlertAction actionWithTitle:@"Yes" style:UIAlertActionStyleDefault
    		handler:^(UIAlertAction * action) {
				[[NSFileManager defaultManager] removeItemAtURL: [NSURL fileURLWithPath:SPOOF_VER_PLIST_WITH_PATH] error: nil];
    			[self reload];
				UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Notice"
				message:@"Settings restored to default\nPlease respring your device" 
				preferredStyle:UIAlertControllerStyleAlert];
				UIAlertAction* DoneAction =  [UIAlertAction actionWithTitle:@"Respring" style:UIAlertActionStyleDefault
    			handler:^(UIAlertAction * action) {
					pid_t pid;
					const char* args[] = {"killall", "backboardd", NULL};
					posix_spawn(&pid, "/usr/bin/killall", NULL, NULL, (char* const*)args, NULL);
				}];
				[alert addAction:DoneAction];
				[self presentViewController:alert animated:YES completion:nil];
	}];
	/* prepare function for "no" button" */
	UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"No" style: UIAlertActionStyleCancel handler:^(UIAlertAction * action) { return; }];
	/* actually assign those actions to the buttons */
	[alertController addAction:OKAction];
    [alertController addAction:cancelAction];
	/* present the dialog and wait for an answer */
	[self presentViewController:alertController animated:YES completion:nil];
	return;
}

-(void)openTwitter {
	UIApplication *application = [UIApplication sharedApplication];
	NSURL *URL = [NSURL URLWithString:@"https://www.twitter.com/omrkujman"];
	[application openURL:URL options:@{} completionHandler:^(BOOL success) {return;}];
}

-(void)donationLink {
	UIApplication *application = [UIApplication sharedApplication];
	NSURL *URL = [NSURL URLWithString:@"https://www.paypal.me/0xkuj"];
	[application openURL:URL options:@{} completionHandler:^(BOOL success) {return;}];
}

-(void)openGithub {
	UIApplication *application = [UIApplication sharedApplication];
	NSURL *URL = [NSURL URLWithString:@"https://github.com/0xkuj/3DAppVersionSpoofer"];
	[application openURL:URL options:@{} completionHandler:^(BOOL success) {return;}];
}
@end
