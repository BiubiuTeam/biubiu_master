//
//  DPListStyleContentView.h
//  BiuBiu
//
//  Created by haowenliang on 15/1/16.
//  Copyright (c) 2015年 dpsoft. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DPContentLabel;

@interface DPListStyleContentView : UIButton
{
    UILabel* _nickLabel;
    DPContentLabel* _contentLabel;
}

@property (nonatomic, strong) UILabel* nickLabel;
@property (nonatomic, strong) DPContentLabel* contentLabel;

- (void)setNickText:(NSString*)nick contentText:(NSString*)content;

- (void)highlightContent:(BOOL)hightlight;
- (void)markAsPolicyContent:(BOOL)marked;

+ (CGFloat)cellHeightForContentText:(NSString*)content;

@end
