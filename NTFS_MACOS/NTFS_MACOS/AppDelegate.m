//
//  AppDelegate.m
//  NTFS_MACOS
//
//  Created by Master_K on 2019/3/16.
//  Copyright © 2019 付凯. All rights reserved.
//

#import "AppDelegate.h"
#import <ServiceManagement/ServiceManagement.h>

@interface AppDelegate ()

@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // Insert code here to initialize your application
    [[NTFSManager sharedManager] registerDA];
    [self addHelper];
}


- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}

- (BOOL)applicationShouldHandleReopen:(NSApplication *)sender hasVisibleWindows:(BOOL)flag{
    NSWindow * window = [[NSApplication sharedApplication].windows firstObject];
    if (window) {
        if (flag) {
            if (window.isMiniaturized) {
                [window deminiaturize:nil];
            }
            return NO;
        }else{
            [window makeKeyAndOrderFront:nil];
            return YES;
        }
    }else{
        return NO;
    }
}

- (IBAction)arrangeInFront:(id)sender {
    NSWindow *mainWindow = [NSApplication sharedApplication].windows.firstObject;
    if (mainWindow.isMiniaturized) {
        [mainWindow deminiaturize:nil];
    } else {
        [mainWindow makeKeyAndOrderFront:nil];
    }
}

/*
@IBAction func arrangeInFront(_ sender: Any) {
    if let mainWindow = NSApplication.shared.windows.first {
        if mainWindow.isMiniaturized{
            mainWindow.deminiaturize(nil)
        }else{
            mainWindow.makeKeyAndOrderFront(nil)
        }
    }
}
 */
#define kSMJobHelperBunldeID @"NTFSHelper"
- (void)addHelper
{
    NSDictionary *helperInfo = (__bridge NSDictionary*)SMJobCopyDictionary(kSMDomainSystemLaunchd,
                                                                           (__bridge CFStringRef)kSMJobHelperBunldeID);
//    BOOL status = SMLoginItemSetEnabled(((__bridge CFStringRef)kSMJobHelperBunldeID), true);
    if (!helperInfo)
    {
        AuthorizationItem authItem = { kSMRightBlessPrivilegedHelper, 0, NULL, 0 };
        AuthorizationRights authRights = { 1, &authItem };
        AuthorizationFlags flags = kAuthorizationFlagDefaults|
        kAuthorizationFlagInteractionAllowed|
        kAuthorizationFlagPreAuthorize|
        kAuthorizationFlagExtendRights;
        
        AuthorizationRef authRef = NULL;
        OSStatus status = AuthorizationCreate(&authRights, kAuthorizationEmptyEnvironment, flags, &authRef);
        if (status != errAuthorizationSuccess)
        {
            NSLog(@"Failed to create AuthorizationRef, return code %i", status);
        } else
        {
            CFErrorRef error = NULL;
            BOOL result = SMJobBless(kSMDomainSystemLaunchd, (__bridge CFStringRef)kSMJobHelperBunldeID, authRef, &error);
            if (!result)
            {
                NSLog(@"SMJobBless Failed, error : %@",error);
            }
        }
    }
}
@end
