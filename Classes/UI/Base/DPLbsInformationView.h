//
//  DPLbsInformationView.h
//  BiuBiu
//
//  Created by haowenliang on 14/12/10.
//  Copyright (c) 2014年 dpsoft. All rights reserved.
//
//  地理位置信息UI
#import <UIKit/UIKit.h>

#define LBS_ICON_RADIUS _size_S(22)
#define LBS_ICON_LEFT _size_S(13)
#define LBS_ICON_RIGHT _size_S(7)

@interface DPLbsInformationView : UIButton

- (void)updateLbsInformationWithText:(NSString*)locationText;

- (void)updateLabelTextColor:(UIColor*)color font:(UIFont*)font;

- (void)resetLbsIcon:(UIImage*)icon;
- (void)centerOpt;
@end
