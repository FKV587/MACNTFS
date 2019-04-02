//
//  NSColor+HexColor.m
//  NTFS_MACOS
//
//  Created by Fukai on 2019/3/21.
//  Copyright © 2019 付凯. All rights reserved.
//

#import "NSColor+HexColor.h"

@implementation NSColor (HexColor)

+ (NSColor *)colorWithHex:(long)hexColor
{
    return [self colorWithHex:hexColor alpha:1.0];
}

+ (NSColor *)colorWithHex:(long)hexColor alpha:(CGFloat)a
{
    float red = ((float)((hexColor & 0xFF0000) >> 16))/255.0;
    float green = ((float)((hexColor & 0xFF00) >> 8))/255.0;
    float blue = ((float)(hexColor & 0xFF))/255.0;
    
    return [NSColor colorWithRed:red green:green blue:blue alpha:a];
}

@end
