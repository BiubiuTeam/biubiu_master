//
//  UIImageAdditions.h
//  biubiu
//
//  Created by haowenliang on 15/1/31.
//  Copyright (c) 2015年 dpsoft. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (biubiu)

+ (UIImage *)imageWithColor:(UIColor *)color;
+ (UIImage*)resizeImageWithColor:(UIColor *)color;
+ (UIImage *)imageWithColor:(UIColor *)color size:(CGSize)size;

@end
