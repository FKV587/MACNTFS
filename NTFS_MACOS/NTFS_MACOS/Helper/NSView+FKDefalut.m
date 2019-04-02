//
//  NSView+FKDefalut.m
//  NTFS_MACOS
//
//  Created by Fukai on 2019/3/21.
//  Copyright © 2019 付凯. All rights reserved.
//

#import "NSView+FKDefalut.h"

@implementation NSView (FKDefalut)

- (void)setBackGroundColor:(NSColor *)color{
    self.wantsLayer = YES;
    self.layer.backgroundColor = color.CGColor;
}

@end
