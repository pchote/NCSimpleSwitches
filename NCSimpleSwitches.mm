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
    UIView *_view;
    AVCaptureSession *flashlightSession;
    NCSwitch *flashlightSwitch;
    NCSwitch *orientationSwitch;
    NCSwitch *wifiSwitch;
    NCSwitch *bluetoothSwitch;
    NCSwitch *airplaneSwitch;
}

+ (void)initialize;
- (UIView *)view;

@end

@implementation ButtonTestController

+ (void)initialize
{
    
}

- (void)dealloc
{
    [flashlightSwitch release];
    [orientationSwitch release];
    [wifiSwitch release];
    [bluetoothSwitch release];
    [airplaneSwitch release];
    [_view release];
    [super dealloc];
}

CGSize margin = CGSizeMake(20, 4);
CGSize ss = CGSizeMake(74, 29);

- (UIView *)view 
{
    if (_view == nil)
    {
        _view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, [self viewHeight])];
        _view.autoresizingMask = UIViewAutoresizingFlexibleWidth;


        // Flashlight
        flashlightSwitch = [[NCSwitch alloc] initWithFrame:CGRectMake(margin.width, margin.height, ss.width, ss.height) thumbImage: [UIImage imageWithContentsOfFile:@"/System/Library/WeeAppPlugins/NCSimpleSwitches.bundle/icon_torch.png"]];
        flashlightSwitch.autoresizingMask = UIViewAutoresizingFlexibleRightMargin;
        [flashlightSwitch addTarget:self action: @selector(flashlightButtonSwitched:) forControlEvents:UIControlEventValueChanged];
        [_view addSubview:flashlightSwitch];

        // Orientation Lock
        orientationSwitch = [[NCSwitch alloc] initWithFrame:CGRectMake(160 - ss.width/2, margin.height, ss.width, ss.height) thumbImage: [UIImage imageWithContentsOfFile:@"/System/Library/WeeAppPlugins/NCSimpleSwitches.bundle/icon_rotate.png"]];
        orientationSwitch.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
        [orientationSwitch addTarget:self action: @selector(orientationButtonSwitched:) forControlEvents:UIControlEventValueChanged];
        [_view addSubview:orientationSwitch];

        // Enable Wifi
        wifiSwitch = [[NCSwitch alloc] initWithFrame:CGRectMake(320 - ss.width - margin.width, margin.height, ss.width, ss.height) thumbImage: [UIImage imageWithContentsOfFile:@"/System/Library/WeeAppPlugins/NCSimpleSwitches.bundle/icon_wifi.png"]];
        wifiSwitch.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
        [wifiSwitch addTarget:self action: @selector(wifiButtonSwitched:) forControlEvents:UIControlEventValueChanged];
        [_view addSubview:wifiSwitch];

        // Bluetooth
        bluetoothSwitch = [[NCSwitch alloc] initWithFrame:CGRectMake(margin.width, 3*margin.height+29, ss.width, ss.height) thumbImage: [UIImage imageWithContentsOfFile:@"/System/Library/WeeAppPlugins/NCSimpleSwitches.bundle/icon_bluetooth.png"]];
        bluetoothSwitch.autoresizingMask = UIViewAutoresizingFlexibleRightMargin;
        [bluetoothSwitch addTarget:self action: @selector(bluetoothButtonSwitched:) forControlEvents:UIControlEventValueChanged];
        [_view addSubview:bluetoothSwitch];

        // Airplane mode
        airplaneSwitch = [[NCSwitch alloc] initWithFrame:CGRectMake(160 - ss.width/2, 3*margin.height+29, ss.width, ss.height) thumbImage: [UIImage imageWithContentsOfFile:@"/System/Library/WeeAppPlugins/NCSimpleSwitches.bundle/icon_airplane.png"]];
        airplaneSwitch.autoresizingMask = UIViewAutoresizingFlexibleRightMargin;
        [airplaneSwitch addTarget:self action: @selector(airplaneButtonSwitched:) forControlEvents:UIControlEventValueChanged];
        [_view addSubview:airplaneSwitch];
    }
    
    return _view;
}

- (void)flashlightButtonSwitched:(id)sender
{
    NCSwitch *sw = (NCSwitch *)sender;
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    if (![device hasTorch])
        return;

    if ([sw isOn] && device.torchMode == AVCaptureTorchModeOff)
    {
        flashlightSession = [[AVCaptureSession alloc] init];
        [flashlightSession addInput:[AVCaptureDeviceInput deviceInputWithDevice:device error: nil]];
        [flashlightSession addOutput:[[[AVCaptureVideoDataOutput alloc] init] autorelease]];

        [flashlightSession beginConfiguration];
        [device lockForConfiguration:nil];
        [device setTorchMode:AVCaptureTorchModeOn];
        [device unlockForConfiguration];

        [flashlightSession commitConfiguration];
        [flashlightSession startRunning];
    }
    else if (![sw isOn] && device.torchMode == AVCaptureTorchModeOn)
    {
        [flashlightSession stopRunning];
        [flashlightSession release], flashlightSession = nil;
    }
}

- (void)orientationButtonSwitched:(id)sender
{
    [[objc_getClass("SBOrientationLockManager") sharedInstance] lock:[(NCSwitch *)sender isOn]];
}

- (void)wifiButtonSwitched:(id)sender
{
    [[objc_getClass("SBWiFiManager") sharedInstance] setWiFiEnabled:[(NCSwitch *)sender isOn]];
}

- (void)bluetoothButtonSwitched:(id)sender
{
    [(BluetoothManager *)[objc_getClass("BluetoothManager") sharedInstance] setEnabled:[(NCSwitch *)sender isOn]];
}

- (void)airplaneButtonSwitched:(id)sender
{
    [[objc_getClass("SBTelephonyManager") sharedTelephonyManager] setIsInAirplaneMode:[(NCSwitch *)sender isOn]];
}


- (void)viewDidAppear
{
    [wifiSwitch setOn:[[objc_getClass("SBWiFiManager") sharedInstance] wiFiEnabled] animated:NO];
    [orientationSwitch setOn:[[objc_getClass("SBOrientationLockManager") sharedInstance] isLocked] animated:NO];
    [bluetoothSwitch setOn:[[objc_getClass("BluetoothManager") sharedInstance] enabled] animated:NO];
    [airplaneSwitch setOn:[[objc_getClass("SBTelephonyManager") sharedTelephonyManager] isInAirplaneMode] animated:NO];
}

- (float)viewHeight
{
    return 2*29 + 4*margin.height;
}

@end