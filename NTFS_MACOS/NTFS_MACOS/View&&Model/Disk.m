/*
 * The MIT License (MIT)
 *
 * Application: NTFS OS X
 * Copyright (c) 2015 Jeevanandam M. (jeeva@myjeeva.com)
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

//
//  Disk.m
//  NTFS-OSX
//
//  Created by Jeevanandam M. on 6/5/15.
//  Copyright (c) 2015 myjeeva.com. All rights reserved.
//


#import "Disk.h"
#import "CommandLine.h"
#import "STPrivilegedTask.h"


@implementation Disk

@synthesize BSDName = _BSDName;
@synthesize desc;
@synthesize volumeUUID = _volumeUUID;
@synthesize volumeName = _volumeName;
@synthesize volumePath = _volumePath;
@synthesize favoriteItem;


#pragma mark - Public Methods

+ (Disk *)getDiskForDARef:(DADiskRef)diskRef {
	for (Disk *disk in [[NTFSManager sharedManager]ntfsDisks]) {
		if (disk.hash == CFHash(diskRef)) {
			return disk;
		}
	}

	return nil;
}

+ (Disk *)getDiskForUserInfo:(NSDictionary *)userInfo {
	NSString *devicePath = [userInfo objectForKey:NSDevicePath];

	for (Disk *disk in [[NTFSManager sharedManager]ntfsDisks]) {
		if ([disk.volumePath isEqualToString:devicePath]) {
			return disk;
		}
	}

	return nil;
}


# pragma mark - Instance Methods

- (id)initWithDADiskRef:(DADiskRef)diskRef {

	NSAssert(diskRef, @"Disk reference cannot be NULL");

	// using existing reference
	Disk *foundOne = [Disk getDiskForDARef:diskRef];
	if (foundOne) {
		return foundOne;
	}

	self = [self init];
	if (self) {
		_diskRef = CFRetain(diskRef);

		CFDictionaryRef diskDesc = DADiskCopyDescription(diskRef);
		desc = CFRetain(diskDesc);

		_BSDName = [[NSString alloc] initWithUTF8String:DADiskGetBSDName(diskRef)];

		CFUUIDRef uuidRef = CFDictionaryGetValue(diskDesc, kDADiskDescriptionVolumeUUIDKey);
        if (uuidRef) {
            _volumeUUID = CFBridgingRelease(CFUUIDCreateString(kCFAllocatorDefault, uuidRef));
        }
        _volumeKindKey = CFDictionaryGetValue(diskDesc, kDADiskDescriptionVolumeKindKey);

		[[[NTFSManager sharedManager]ntfsDisks] addObject:self];
	}

	return self;
}

- (void)dealloc {
	Release(desc);
	Release(_diskRef);
	Release(favoriteItem);
}

- (void)disappeared {
	[[[NTFSManager sharedManager]ntfsDisks] removeObject:self];
}

- (void)enableNTFSWrite {
	NSString * cmd = [NSString stringWithFormat:@"echo \"%@\" | tee -a %@", [self ntfsConfig], FstabFile];
//  mount -t ntfs -o nosuid,noowners -w -v /dev/disk2s1 /common/wd/DATA1
    [STPrivilegedTask launchedPrivilegedTaskWithLaunchPath:@"/bin/sh" arguments:[NSArray arrayWithObjects: @"-c", cmd, nil]];
    
	LogInfo(@"Write mode enabled for disk '%@'", self.volumeName);
}

- (void)enableNTFSWrite1 {
    NSString * cmd = [NSString stringWithFormat:@"echo \"%@\" | tee -a %@", [self ntfsConfig1], FstabFile];
    //  mount -t ntfs -o nosuid,noowners -w -v /dev/disk2s1 /common/wd/DATA1
    [STPrivilegedTask launchedPrivilegedTaskWithLaunchPath:@"/bin/sh" arguments:[NSArray arrayWithObjects: @"-c", cmd, nil]];
    
//    [CommandLine run:cmd];
    LogInfo(@"Write mode enabled for disk '%@'", self.volumeName);
}

- (NSString *)mount {
	return [CommandLine run:[NSString stringWithFormat:@"diskutil mount /dev/%@", self.BSDName]];
}

- (NSString *)unmount {
    return [CommandLine run:[NSString stringWithFormat:@"diskutil unmount /dev/%@", self.BSDName]];
}

- (NSString *)sudoMount {
    return [CommandLine run:[NSString stringWithFormat:@"sudo mount /dev/%@", self.BSDName]];
}

- (NSString *)sudoMount_ntfs {
    [CommandLine run:@"mkdir mobileDevice"];
    return [CommandLine run:[NSString stringWithFormat:@"sudo mount_ntfs -o rw,nobrowse /dev/%@ mobileDevice", self.BSDName]];
}

- (NSString *)sudoUnmount {
    return [CommandLine run:[NSString stringWithFormat:@"sudo unmount /dev/%@", self.BSDName]];
}
#pragma mark - Properties

- (NSUInteger)hash {
	return CFHash(_diskRef);
}

- (BOOL)isEqual:(id)object {
	return (CFHash(_diskRef) == [object hash]);
}

- (void)setDesc:(CFDictionaryRef)descUpdate {
	if (descUpdate && descUpdate != desc) {
		Release(desc);
		desc = CFRetain(descUpdate);
	}
}

- (CFDictionaryRef)desc {
	return desc;
}

- (NSString *)volumeName {
    if (!_volumeName) {
        CFStringRef nameRef = CFDictionaryGetValue(desc, kDADiskDescriptionVolumeNameKey);
        if (nameRef) {
            _volumeName = (__bridge NSString *)nameRef;
        }else{
            _volumeName = @"Untitled";
        }
    }
	return _volumeName;
}

- (NSString *)volumePath {
	NSString *path = [NSString stringWithFormat:@"/Volumes/%@", self.volumeName];
	return path;
}

- (BOOL)isNTFS{
    return [self.volumeKindKey isEqualToString:@"ntfs"];
}

- (BOOL)isNTFSWritable {
	BOOL status = [[NSFileManager defaultManager] fileExistsAtPath:FstabFile];
	LogDebug(@"File '%@' exists: %@", FstabFile, status ? @"YES" : @"NO");

	if (status) {
        if (self.volumeUUID) {
            NSString *cmd = [NSString stringWithFormat:@"grep \"%@\" %@", self.volumeUUID, FstabFile];
            NSString *output = [CommandLine run:cmd];
            LogDebug(@"output: %@", output);
            if ([[self ntfsConfig] isEqualToString:output]) {
                return TRUE;
            }
        }else{
            NSString *cmd = [NSString stringWithFormat:@"grep \"%@\" %@", [self.volumeName stringByReplacingOccurrencesOfString:@" " withString:@"\\\\\\040"], FstabFile];
            NSString *output = [CommandLine run:cmd];
            LogDebug(@"output: %@", output);
            if ([[self ntfsConfig11] isEqualToString:output]) {
                return TRUE;
            }
        }
	}

	return FALSE;
}

- (void)setFavoriteItem:(CFTypeRef) inFavoriteItem {
	if (inFavoriteItem) {
		favoriteItem = CFRetain(inFavoriteItem);
	}
}

- (CFTypeRef) favoriteItem {
	return favoriteItem;
}


#pragma mark - Private Methods

- (NSString *)ntfsConfig {
    return [NSString stringWithFormat:@"UUID=%@ none ntfs rw,auto,nobrowse", self.volumeUUID];
}

- (NSString *)ntfsConfig1 {
    return [NSString stringWithFormat:@"LABEL=%@ none ntfs rw,auto,nobrowse", [self.volumeName stringByReplacingOccurrencesOfString:@" " withString:@"\\\\\\040"]];
}

- (NSString *)ntfsConfig11 {
    return [NSString stringWithFormat:@"LABEL=%@ none ntfs rw,auto,nobrowse", [self.volumeName stringByReplacingOccurrencesOfString:@" " withString:@"\\040"]];
}


@end
