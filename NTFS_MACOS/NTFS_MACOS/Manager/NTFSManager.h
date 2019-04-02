//
//  NTFSManager.h
//  NTFS_MACOS
//
//  Created by Fukai on 2019/3/20.
//  Copyright © 2019 付凯. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
@class Disk;
@interface NTFSManager : NSObject

@property (nonatomic , strong)NSMutableArray *ntfsDisks;

+ (instancetype)sharedManager;
- (void)registerDA;
- (void)unregisterDA;
//手动挂载打开NTFS挂载盘
- (BOOL)ntfsDiskAppeared:(Disk *)disk;
//打开挂载好了的U盘地址
- (BOOL)openVolumePath:(Disk *)disk;
@end

NS_ASSUME_NONNULL_END
