//
//  UIImageAdditions.m
//  biubiu
//
//  Created by haowenliang on 15/1/31.
//  Copyright (c) 2015年 dpsoft. All rights reserved.
//

#import "UIImageAdditions.h"

@implementation UIImage (biubiu)

+ (UIImage *)imageWithColor:(UIColor *)color
{
    return [self imageWithColor:color size:CGSizeMake(4.0, 4.0)];
}

+ (UIImage*)resizeImageWithColor:(UIColor *)color
{
    UIColor *bgColor = color;
    if(!bgColor)  //默认
        bgColor = [UIColor colorWithRed:229.0/255.0 green:230.0/255.0 blue:231.0/255.0 alpha:1];
    
    UIImage *_selectedImg = [UIImage imageWithColor:bgColor];
    CGFloat leftCap = floorf(_selectedImg.size.height/2);
    CGFloat topCap = floorf(_selectedImg.size.height/2);
    UIEdgeInsets capInset = UIEdgeInsetsMake(leftCap,topCap, _selectedImg.size.height - topCap - 1, _selectedImg.size.width -leftCap - 1);
    UIImage *_stretchSelectedImg = [_selectedImg resizableImageWithCapInsets:capInset];
    return _stretchSelectedImg;
}

+ (UIImage *)imageWithColor:(UIColor *)color size:(CGSize)size
{
    @autoreleasepool {
        CGRect rect = CGRectMake(0, 0, size.width, size.height);
        
        UIGraphicsBeginImageContext(rect.size);
        
        CGContextRef context = UIGraphicsGetCurrentContext();
        CGContextSetFillColorWithColor(context, color.CGColor);
        
        CGContextFillRect(context, rect);
        UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        return img;
    }
}

@end
