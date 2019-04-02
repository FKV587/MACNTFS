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
//  Disk.h
//  NTFS-OSX
//
//  Created by Jeevanandam M. on 6/5/15.
//  Copyright (c) 2015 myjeeva.com. All rights reserved.
//


@interface Disk : NSObject {
	CFTypeRef _diskRef;
}

@property (readonly, strong) NSString *BSDName;
@property CFDictionaryRef desc;
@property (readonly, strong) NSString *volumeUUID;
@property (readonly, strong) NSString *volumeName;
@property (nonatomic, strong) NSString *volumePath;
@property (nonatomic, strong) NSString *volumeKindKey;
@property (nonatomic, assign) BOOL isNTFSWritable;
@property CFTypeRef favoriteItem;

- (BOOL)isNTFS;
+ (Disk *)getDiskForDARef:(DADiskRef)diskRef;
+ (Disk *)getDiskForUserInfo:(NSDictionary *)userInfo;
- (id)initWithDADiskRef:(DADiskRef)diskRef;
- (void)disappeared;
- (void)enableNTFSWrite;
- (void)enableNTFSWrite1;
- (NSString *)mount;
- (NSString *)unmount;
- (NSString *)sudoMount;
- (NSString *)sudoMount_ntfs;
- (NSString *)sudoUnmount;
@end

