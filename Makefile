INSTALL_TARGET_PROCESSES = SpringBoard
export TARGET = iphone:clang:12.2:12.2
ARCHS = arm64 arm64e
GO_EASY_ON_ME = 1
FINALPACKAGE = 1
DEBUG = 0

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = 3DAppVersionSpoofer

3DAppVersionSpoofer_FILES = Tweak.xm
3DAppVersionSpoofer_CFLAGS = -fobjc-arc

include $(THEOS_MAKE_PATH)/tweak.mk
SUBPROJECTS += 3dappversionspooferprefs
include $(THEOS_MAKE_PATH)/aggregate.mk
