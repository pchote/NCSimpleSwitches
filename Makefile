export THEOS_DEVICE_IP=172.18.0.161
SDKVERSION = 5.0
include /usr/local/theos/makefiles/common.mk

LIBRARY_NAME = NCSimpleSwitches
NCSimpleSwitches_FILES = NCSimpleSwitches.mm NCSwitch.m
NCSimpleSwitches_INSTALL_PATH = /System/Library/WeeAppPlugins/NCSimpleSwitches.bundle
NCSimpleSwitches_FRAMEWORKS = Foundation UIKit CoreGraphics AVFoundation
NCSimpleSwitches_PRIVATE_FRAMEWORKS = BulletinBoard

include $(THEOS_MAKE_PATH)/library.mk

after-stage::
	mv _/System/Library/WeeAppPlugins/NCSimpleSwitches.bundle/NCSimpleSwitches.dylib _/System/Library/WeeAppPlugins/NCSimpleSwitches.bundle/NCSimpleSwitches
	cp -a *.png _/System/Library/WeeAppPlugins/NCSimpleSwitches.bundle/
	cp Info.plist _/System/Library/WeeAppPlugins/NCSimpleSwitches.bundle/
	cp *.strings _/System/Library/WeeAppPlugins/NCSimpleSwitches.bundle/