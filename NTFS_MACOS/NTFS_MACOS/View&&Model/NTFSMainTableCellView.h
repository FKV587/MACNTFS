//
//  NTFSMainTableCellView.h
//  NTFS_MACOS
//
//  Created by Fukai on 2019/3/20.
//  Copyright © 2019 付凯. All rights reserved.
//

#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN
@class Disk;
@protocol NTFSMainTableCellViewDelegate <NSObject>

- (void)mainTableCellViewReback:(Disk *)disk;
- (void)mainTableCellViewUnMount:(Disk *)disk;

@end

@interface NTFSMainTableCellView : NSTableCellView

@property (nonatomic , weak)id <NTFSMainTableCellViewDelegate> delegate;
@property (nonatomic , strong)Disk * disk;

@end

NS_ASSUME_NONNULL_END
