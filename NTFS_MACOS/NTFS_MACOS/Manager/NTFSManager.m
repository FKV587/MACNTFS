//
//  NTFSManager.m
//  NTFS_MACOS
//
//  Created by Fukai on 2019/3/20.
//  Copyright © 2019 付凯. All rights reserved.
//

#import "NTFSManager.h"
#import <DiskArbitration/DiskArbitration.h>
#import "Disk.h"
#import <AppSandboxFileAccess/AppSandboxFileAccess.h>

@interface NTFSManager(){
    DASessionRef session;
    DASessionRef approvalSession;
}

BOOL Validate(DADiskRef diskRef);
void DiskAppearedCallback(DADiskRef diskRef, void *context);
void DiskDisappearedCallback(DADiskRef diskRef, void *context);
void DiskDescriptionChangedCallback(DADiskRef diskRef, CFArrayRef keys, void *context);
DADissenterRef DiskMountApprovalCallback(DADiskRef diskRef, void *context);
DADissenterRef DiskUnmountApprovalCallback(DADiskRef diskRef, void *context);

@end

@implementation NTFSManager

+ (instancetype)sharedManager {
    static NTFSManager * manager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[self alloc] init];
    });
    return manager;
}

- (void)registerDA{
    session = DASessionCreate(kCFAllocatorDefault);
    if (!session) {
        [NSException raise:NSGenericException format:@"Unable to create Disk Arbitration session."];
        return;
    }
    LogDebug(@"Disk Arbitration Session created");
    self.ntfsDisks = [NSMutableArray array];
    // Matching Conditions
    CFMutableDictionaryRef match = CFDictionaryCreateMutable(kCFAllocatorDefault, 0, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
    
    // Device matching criteria
    // 1. Of-course it shouldn't be internal device since
    CFDictionaryAddValue(match, kDADiskDescriptionDeviceInternalKey, kCFBooleanFalse);
    
    // Volume matching criteria
    // It should statisfy following
//    CFDictionaryAddValue(match, kDADiskDescriptionVolumeKindKey, (__bridge CFStringRef)DADiskDescriptionVolumeKindValue);
    CFDictionaryAddValue(match, kDADiskDescriptionVolumeMountableKey, kCFBooleanTrue);
    CFDictionaryAddValue(match, kDADiskDescriptionVolumeNetworkKey, kCFBooleanFalse);
    
    //CFDictionaryAddValue(match, kDADiskDescriptionDeviceProtocolKey, CFSTR(kIOPropertyPhysicalInterconnectTypeUSB));
    
    DASessionScheduleWithRunLoop(session, CFRunLoopGetMain(), kCFRunLoopCommonModes);
    
    // Registring callbacks
    DARegisterDiskAppearedCallback(session, match, DiskAppearedCallback, (__bridge void *)AppName);
    DARegisterDiskDisappearedCallback(session, match, DiskDisappearedCallback, (__bridge void *)AppName);
    DARegisterDiskDescriptionChangedCallback(session, match, NULL, DiskDescriptionChangedCallback, (__bridge void *)AppName);
    
    // Disk Arbitration Approval Session
    approvalSession = DAApprovalSessionCreate(kCFAllocatorDefault);
    if (!approvalSession) {
        LogDebug(@"Unable to create Disk Arbitration approval session.");
        return;
    }
    
    LogDebug(@"Disk Arbitration Approval Session created");
    DAApprovalSessionScheduleWithRunLoop(approvalSession, CFRunLoopGetMain(), kCFRunLoopCommonModes);
    
    // Same match condition for Approval session too
    DARegisterDiskMountApprovalCallback(approvalSession, match, DiskMountApprovalCallback, (__bridge void *)AppName);
    
    Release(match);

}

- (void)unregisterDA{
    // DA Session
    if (session) {
        DAUnregisterCallback(session, DiskAppearedCallback, (__bridge void *)AppName);
        DAUnregisterCallback(session, DiskDisappearedCallback, (__bridge void *)AppName);
        
        DASessionUnscheduleFromRunLoop(session, CFRunLoopGetMain(), kCFRunLoopCommonModes);
        Release(session);
        
        LogDebug(@"Disk Arbitration Session destoryed");
    }
    
    // DA Approval Session
    if (approvalSession) {
        DAUnregisterCallback(approvalSession, DiskMountApprovalCallback, (__bridge void *)AppName);
        
        DAApprovalSessionUnscheduleFromRunLoop(approvalSession, CFRunLoopGetMain(), kCFRunLoopCommonModes);
        Release(approvalSession);
        
        LogDebug(@"Disk Arbitration Approval Session destoryed");
    }
    [self.ntfsDisks removeAllObjects];
    _ntfsDisks = nil;
}

BOOL Validate(DADiskRef diskRef) {
    
    if (DADiskGetBSDName(diskRef) == NULL) {
        [NSException raise:NSInternalInconsistencyException format:@"NTFS Disk without BSDName"];
    }
    
    return TRUE;
}

void DiskAppearedCallback(DADiskRef diskRef, void *context) {
    LogDebug(@"DiskAppearedCallback called: %s", DADiskGetBSDName(diskRef));
    
    if (Validate(diskRef)) {
        Disk *disk = [[Disk alloc] initWithDADiskRef:diskRef];
        LogDebug(@"Name: %@ \tUUID: %@", disk.volumeName, disk.volumeUUID);
        [[NSNotificationCenter defaultCenter]postNotificationName:NTFSDiskAppearedNotification object:disk];
    }
}

void DiskDisappearedCallback(DADiskRef diskRef, void *context) {
    LogDebug(@"DiskDisappearedCallback called: %s", DADiskGetBSDName(diskRef));
    
    if (Validate(diskRef)) {
        Disk *disk = [Disk getDiskForDARef:diskRef];
        LogDebug(@"Name: %@ \tUUID: %@", disk.volumeName, disk.volumeUUID);
        [disk disappeared];
        [[NSNotificationCenter defaultCenter]postNotificationName:NTFSDiskAppearedNotification object:disk];
    }
}

void DiskDescriptionChangedCallback(DADiskRef diskRef, CFArrayRef keys, void *context) {
    LogDebug(@"DiskDescriptionChangedCallback called: %s", DADiskGetBSDName(diskRef));
    
    Disk *disk = [Disk getDiskForDARef:diskRef];
    
    if (disk) {
        CFDictionaryRef newDesc = DADiskCopyDescription(diskRef);
        disk.desc = newDesc;
        Release(newDesc);
    }
}

DADissenterRef DiskMountApprovalCallback(DADiskRef diskRef, void *context) {
    LogDebug(@"DiskMountApprovalCallback called: %s", DADiskGetBSDName(diskRef));
    
    if (Validate(diskRef)) {
        Disk *disk = [[Disk alloc] initWithDADiskRef:diskRef];
        LogDebug(@"Name: %@ \tUUID: %@", disk.volumeName, disk.volumeUUID);
    }
    
    return NULL;
}

- (BOOL)ntfsDiskAppeared:(Disk *)disk {
    LogInfo(@"DiskAppeared - %@", disk.BSDName);
    LogDebug(@"Disks Count - %lu", (unsigned long)[self.ntfsDisks count]);
    
    if (disk.isNTFSWritable) {
        LogInfo(@"Write mode already enabled for '%@'", disk.volumeName);
    } else {        
        [self bringToFront];
        if ([self isPath:disk.volumePath]) {
            if (disk.volumeUUID) {
<<<<<<< HEAD
<<<<<<< HEAD
<<<<<<< HEAD
                [disk unmount];
                __block Disk * disk1 = disk;
                [disk enableNTFSWriteError:^(int errorCode) {
                    if (errorCode != errAuthorizationSuccess) {
                        errorBlock(errorCode);
                    }else{
                        [disk1 mount];
                        sussce();
                    }
                }];
=======
=======
>>>>>>> parent of ebc048d... xx
=======
>>>>>>> parent of ebc048d... xx
                NSString * taskunMont = [disk unmount];
                NSLog(@"taskunMont -- %@",taskunMont);
                [disk enableNTFSWrite];
                NSString * taskMont = [disk mount];
                NSLog(@"taskMont -- %@",taskMont);
<<<<<<< HEAD
<<<<<<< HEAD
>>>>>>> parent of ebc048d... xx
=======
>>>>>>> parent of ebc048d... xx
=======
>>>>>>> parent of ebc048d... xx
            }else{
//                [disk sudoUnmount];
//                [disk sudoMount_ntfs];
//                [disk sudoMount];
//                csrutil status 检查是否打开SIP
<<<<<<< HEAD
<<<<<<< HEAD
<<<<<<< HEAD
                
                [disk unmount];
                __block Disk * disk1 = disk;
                [disk enableNTFSWrite1Error:^(int errorCode) {
                    if (errorCode != errAuthorizationSuccess) {
                        errorBlock(errorCode);
                    }else{
                        [disk1 mount];
                        sussce();
                    }
                }];
=======
=======
>>>>>>> parent of ebc048d... xx
=======
>>>>>>> parent of ebc048d... xx
                NSString * taskunMont = [disk unmount];
                NSLog(@"taskunMont -- %@",taskunMont);
                [disk enableNTFSWrite1];
                NSString * taskMont = [disk mount];
                NSLog(@"taskMont -- %@",taskMont);
<<<<<<< HEAD
<<<<<<< HEAD
>>>>>>> parent of ebc048d... xx
=======
>>>>>>> parent of ebc048d... xx
=======
>>>>>>> parent of ebc048d... xx
            }
        }else{
            errorBlock(0);
        }
    }
    
    return [self openVolumePath:disk];
}

- (void)bringToFront {
    [[NSRunningApplication currentApplication] activateWithOptions:NSApplicationActivateIgnoringOtherApps];
}

- (BOOL)openVolumePath:(Disk *)disk{
    NSString *volumePath = disk.volumePath;
    if ([self isPath:volumePath]) {
        BOOL isExits = [[NSFileManager defaultManager] fileExistsAtPath:volumePath];
        if (isExits) {
            LogDebug(@"Opening mounted NTFS Volume '%@'", volumePath);
            [[NSWorkspace sharedWorkspace] openURL:[NSURL fileURLWithPath:volumePath]];
        }
        return isExits;
    }
    return NO;
}

- (BOOL)isPath:(NSString *)path{
    AppSandboxFileAccess *fileAccess = [AppSandboxFileAccess fileAccess];
    [fileAccess persistPermissionPath:path];
    fileAccess.title = @"获取U盘权限";
    fileAccess.message = @"获取磁盘权限";
    BOOL accessAllowed = [fileAccess accessFilePath:path persistPermission:YES withBlock:^{
        NSLog(@"获取U盘权限成功");
    }];
    return accessAllowed;
}

@end
