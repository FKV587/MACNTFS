//
//  NSColor+HexColor.h
//  NTFS_MACOS
//
//  Created by Fukai on 2019/3/21.
//  Copyright © 2019 付凯. All rights reserved.
//

#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSColor (HexColor)

+ (NSColor *)colorWithHex:(long)hexColor;

+ (NSColor *)colorWithHex:(long)hexColor alpha:(CGFloat)a;
@end

NS_ASSUME_NONNULL_END
