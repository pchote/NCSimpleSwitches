/*
* Copyright (c) 2012, Paul Chote
* All rights reserved.
*
* Redistribution and use in source and binary forms, with or without
* modification, are permitted provided that the following conditions are met:
*
* 1. Redistributions of source code must retain the above copyright notice, this
* list of conditions and the following disclaimer.
* 2. Redistributions in binary form must reproduce the above copyright notice,
* this list of conditions and the following disclaimer in the documentation
* and/or other materials provided with the distribution.
*
* THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
* ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
* WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
* DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR
* ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
* (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
* LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
* ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
* (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
* SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "BBWeeAppController-Protocol.h"
#import "NCSwitch.h"
#import <AVFoundation/AVFoundation.h>
#import "SBOrientationLockManager.h"
#import "SBWifiManager.h"
#import "BluetoothManager.h"
#import "SBTelephonyManager.h"
#import <objc/runtime.h>

@interface ButtonTestController : NSObject <BBWeeAppController>
{
    UIView *mainView;
    NCSwitch *flashlightSwitch;
    NCSwitch *orientationSwitch;
    NCSwitch *wifiSwitch;
    NCSwitch *bluetoothSwitch;
    NCSwitch *airplaneSwitch;

    SBOrientationLockManager *orientationLockManager;
    SBWiFiManager *wifiManager;
    BluetoothManager *bluetoothManager;
    SBTelephonyManager *telephonyManager;
}

+ (void)initialize;
- (UIView *)view;

@end

@implementation ButtonTestController

CGSize margin = CGSizeMake(20, 4);
CGSize ss = CGSizeMake(74, 29);

+ (void)initialize {}
- (float)viewHeight { return 2*29 + 4*margin.height; }
- (UIView *)view 
{

    if (mainView == nil)
    {
        orientationLockManager = [objc_getClass("SBOrientationLockManager") sharedInstance];
        wifiManager = [objc_getClass("SBWiFiManager") sharedInstance];
        bluetoothManager = [objc_getClass("BluetoothManager") sharedInstance];
        telephonyManager = [objc_getClass("SBTelephonyManager") sharedTelephonyManager];

        mainView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, [self viewHeight])];
        mainView.autoresizingMask = UIViewAutoresizingFlexibleWidth;

        // Flashlight
        {
            AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];

            if ([device hasTorch] && [device hasFlash])
            {
                flashlightSwitch = [[NCSwitch alloc] initWithFrame:CGRectMake(margin.width, margin.height, ss.width, ss.height) thumbImage: [UIImage imageWithContentsOfFile:@"/System/Library/WeeAppPlugins/NCSimpleSwitches.bundle/icon_torch.png"]];
                flashlightSwitch.autoresizingMask = UIViewAutoresizingFlexibleRightMargin;
                [flashlightSwitch addTarget:self action: @selector(flashlightButtonSwitched:) forControlEvents:UIControlEventValueChanged];
                [mainView addSubview:flashlightSwitch];
            }
        }

        // Orientation Lock
        orientationSwitch = [[NCSwitch alloc] initWithFrame:CGRectMake(160 - ss.width/2, margin.height, ss.width, ss.height) thumbImage: [UIImage imageWithContentsOfFile:@"/System/Library/WeeAppPlugins/NCSimpleSwitches.bundle/icon_rotate.png"]];
        orientationSwitch.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
        [orientationSwitch addTarget:self action: @selector(orientationButtonSwitched:) forControlEvents:UIControlEventValueChanged];
        [mainView addSubview:orientationSwitch];

        // Enable Wifi
        wifiSwitch = [[NCSwitch alloc] initWithFrame:CGRectMake(320 - ss.width - margin.width, margin.height, ss.width, ss.height) thumbImage: [UIImage imageWithContentsOfFile:@"/System/Library/WeeAppPlugins/NCSimpleSwitches.bundle/icon_wifi.png"]];
        wifiSwitch.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
        [wifiSwitch addTarget:self action: @selector(wifiButtonSwitched:) forControlEvents:UIControlEventValueChanged];
        [mainView addSubview:wifiSwitch];

        // Bluetooth
        bluetoothSwitch = [[NCSwitch alloc] initWithFrame:CGRectMake(margin.width, 3*margin.height+29, ss.width, ss.height) thumbImage: [UIImage imageWithContentsOfFile:@"/System/Library/WeeAppPlugins/NCSimpleSwitches.bundle/icon_bluetooth.png"]];
        bluetoothSwitch.autoresizingMask = UIViewAutoresizingFlexibleRightMargin;
        [bluetoothSwitch addTarget:self action: @selector(bluetoothButtonSwitched:) forControlEvents:UIControlEventValueChanged];
        [mainView addSubview:bluetoothSwitch];

        // Airplane mode
        airplaneSwitch = [[NCSwitch alloc] initWithFrame:CGRectMake(160 - ss.width/2, 3*margin.height+29, ss.width, ss.height) thumbImage: [UIImage imageWithContentsOfFile:@"/System/Library/WeeAppPlugins/NCSimpleSwitches.bundle/icon_airplane.png"]];
        airplaneSwitch.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
        [airplaneSwitch addTarget:self action: @selector(airplaneButtonSwitched:) forControlEvents:UIControlEventValueChanged];
        [mainView addSubview:airplaneSwitch];
    }

    return mainView;
}

- (void)dealloc
{
    [orientationSwitch release];
    [wifiSwitch release];
    [bluetoothSwitch release];
    [airplaneSwitch release];
    [mainView release];
    [super dealloc];
}

- (void)viewDidAppear
{
    [wifiSwitch setOn:[wifiManager wiFiEnabled] animated:NO];
    [orientationSwitch setOn:[orientationLockManager isLocked] animated:NO];
    [bluetoothSwitch setOn:[bluetoothManager enabled] animated:NO];
    [airplaneSwitch setOn:[telephonyManager isInAirplaneMode] animated:NO];
}

- (void)flashlightButtonSwitched:(NCSwitch *)sw
{
    BOOL isOn = [sw isOn];
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    [device lockForConfiguration:nil];
    [device setTorchMode: isOn ? AVCaptureTorchModeOn : AVCaptureTorchModeOff];
    [device setFlashMode: isOn ? AVCaptureFlashModeOn : AVCaptureFlashModeOff];
    [device unlockForConfiguration];
}

- (void)orientationButtonSwitched:(NCSwitch *)sw
{
    [orientationLockManager lock:[sw isOn]];
}

- (void)wifiButtonSwitched:(NCSwitch *)sw
{
    [wifiManager setWiFiEnabled:[sw isOn]];
}

- (void)bluetoothButtonSwitched:(NCSwitch *)sw
{
    [bluetoothManager setEnabled:[sw isOn]];
}

- (void)airplaneButtonSwitched:(NCSwitch *)sw
{
    [telephonyManager setIsInAirplaneMode:[sw isOn]];
    [wifiSwitch setOn:[wifiManager wiFiEnabled] animated:YES];
    [bluetoothSwitch setOn:[bluetoothManager enabled] animated:YES];
}

@end