THEOS_DEVICE_IP     ?= localhost
THEOS_DEVICE_PORT   ?= 2222
TARGET              := iphone:clang:latest:14.0
ARCHS               := arm64

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = YTKillerPlus

YTKillerPlus_FILES = \
	Tweak.x \
	src/AdBlock.x \
	src/Background.x \
	src/Downloads.x \
	src/SpeedControl.x \
	src/SponsorBlock.x \
	src/UITweaks.x

YTKillerPlus_CFLAGS          = -fobjc-arc -Wno-deprecated-declarations
YTKillerPlus_FRAMEWORKS      = UIKit AVFoundation AVKit MediaPlayer AudioToolbox CoreMedia
YTKillerPlus_LIBRARIES       = z

include $(THEOS_MAKE_PATH)/tweak.mk
