export TARGET = iphone:clang:12.2:12.2
ARCHS = arm64 arm64e

include $(THEOS)/makefiles/common.mk

BUNDLE_NAME = 3DAppVersionSpooferPrefs

3DAppVersionSpooferPrefs_FILES = $(wildcard AVS*.*m)
3DAppVersionSpooferPrefs_FRAMEWORKS = UIKit
3DAppVersionSpooferPrefs_PRIVATE_FRAMEWORKS = Preferences
3DAppVersionSpooferPrefs_INSTALL_PATH = /Library/PreferenceBundles
3DAppVersionSpooferPrefs_EXTRA_FRAMEWORKS = AltList
3DAppVersionSpooferPrefs_CFLAGS = -fobjc-arc

include $(THEOS_MAKE_PATH)/bundle.mk
