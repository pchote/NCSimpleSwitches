#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "BBWeeAppController-Protocol.h"
#import "NCSwitch.h"
#import <AVFoundation/AVFoundation.h>
#import "SBOrientationLockManager.h"
#import "SBWifiManager.h"

#import <objc/runtime.h>
@interface ButtonTestController : NSObject <BBWeeAppController>
{
    UIView *_view;
    AVCaptureSession *flashlightSession;
    NCSwitch *flashlightSwitch;
    NCSwitch *orientationSwitch;
    NCSwitch *wifiSwitch;
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
    [_view release];
    [super dealloc];
}

- (UIView *)view 
{
    if (_view == nil)
    {
        _view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 30)];
        _view.autoresizingMask = UIViewAutoresizingFlexibleWidth;

        CGSize ss = CGSizeMake(74, 29);
        // Flashlight
        flashlightSwitch = [[NCSwitch alloc] initWithFrame:CGRectMake(20, 0, ss.width, ss.height) thumbImage: [UIImage imageWithContentsOfFile:@"/System/Library/WeeAppPlugins/ButtonTest.bundle/icon_torch.png"]];
        flashlightSwitch.autoresizingMask = UIViewAutoresizingFlexibleRightMargin;
        [flashlightSwitch addTarget:self action: @selector(flashlightButtonSwitched:) forControlEvents:UIControlEventValueChanged];
        [_view addSubview:flashlightSwitch];

        // Orientation Lock
        orientationSwitch = [[NCSwitch alloc] initWithFrame:CGRectMake(160 - ss.width/2, 0, ss.width, ss.height) thumbImage: [UIImage imageWithContentsOfFile:@"/System/Library/WeeAppPlugins/ButtonTest.bundle/icon_rotate.png"]];
        orientationSwitch.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
        [orientationSwitch addTarget:self action: @selector(orientationButtonSwitched:) forControlEvents:UIControlEventValueChanged];
        [_view addSubview:orientationSwitch];
        
        // Enable Wifi
        wifiSwitch = [[NCSwitch alloc] initWithFrame:CGRectMake(320 - ss.width - 20, 0, ss.width, ss.height) thumbImage: [UIImage imageWithContentsOfFile:@"/System/Library/WeeAppPlugins/ButtonTest.bundle/icon_wifi.png"]];
        wifiSwitch.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
        [wifiSwitch addTarget:self action: @selector(wifiButtonSwitched:) forControlEvents:UIControlEventValueChanged];
        [_view addSubview:wifiSwitch];
        [wifiSwitch release];
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


- (void)viewDidAppear
{
    [wifiSwitch setOn:[[objc_getClass("SBWiFiManager") sharedInstance] wiFiEnabled] animated:NO];
    [orientationSwitch setOn:[[objc_getClass("SBOrientationLockManager") sharedInstance] isLocked] animated:NO];

    //NSNumber *val = (NSNumber*)CFPreferencesCopyAppValue(CFSTR("SBBacklightLevel2" ), CFSTR("com.apple.springboard"));
    //slider.value = [val floatValue];
}

- (float)viewHeight
{
    return 30.0f;
}

@end