//
//  AnimateLabel.h
//  DanmuFun
//
//  Created by haowenliang on 15/5/7.
//  Copyright (c) 2015年 dpsoft. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 *  动画支持类型：向左滚动、向右滚动、淡入淡出
 */
typedef NS_ENUM(NSUInteger, AnimationType) {
    AnimationType_ToLeft = 0,
    AnimationType_ToRight = 1,
    AnimationType_Fade = 2,
};

@protocol AnimateLabelDatasource <NSObject>


@end

@interface AnimateLabel : UILabel
{
    CADisplayLink* _link;
}

@property (nonatomic) NSInteger duration; //动画时间
@property (nonatomic) AnimationType animateType; //动画类型

- (void)startAnimation;
- (void)stopAnimation;

- (void)disappearFromSuperview;

@end
