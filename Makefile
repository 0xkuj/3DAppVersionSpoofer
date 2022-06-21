INSTALL_TARGET_PROCESSES = SpringBoard
TARGET := iphone:clang:latest:14.4
ARCHS = arm64 arm64e
GO_EASY_ON_ME = 1
FINALPACKAGE = 1
DEBUG = 0

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = 3DAppVersionSpoofer

3DAppVersionSpoofer_FILES = Tweak.xm
3DAppVersionSpoofer_CFLAGS = -fobjc-arc

include $(THEOS_MAKE_PATH)/tweak.mk
