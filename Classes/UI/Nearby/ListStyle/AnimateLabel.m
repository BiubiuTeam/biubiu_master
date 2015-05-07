//
//  AnimateLabel.m
//  DanmuFun
//
//  Created by haowenliang on 15/5/7.
//  Copyright (c) 2015年 dpsoft. All rights reserved.
//

#import "AnimateLabel.h"
#import "UIViewAdditions.h"

@interface AnimateLabel ()
{
    CGFloat _offsetInfps;
}
@property (nonatomic, strong) CADisplayLink* link;

@end

@implementation AnimateLabel

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self animationInit];
    }
    return self;
}

- (void)awakeFromNib
{
    [self animationInit];
}

- (void)disappearFromSuperview
{
    [self stopAnimation];
    [self removeFromSuperview];
    
//    [UIView animateWithDuration:0.3 animations:^{
//        self.alpha = 0;
//    } completion:^(BOOL finished) {
//        if (finished) {
//            [self removeFromSuperview];
//        }
//    }];
}

- (void)animationInit
{
    _animateType = AnimationType_ToLeft;
    self.backgroundColor = [UIColor clearColor];
    _offsetInfps = (float)(random()%5)/10.0 + 1.0;//随机速度
}

- (void)startAnimation
{
    switch (_animateType) {
        case AnimationType_ToLeft:
        {
//            self.left = SCREEN_WIDTH + random()%20;
        }break;
        case AnimationType_ToRight:{
            
        }break;
        case AnimationType_Fade:{
            
        }break;
        default:
            break;
    }
    [self.link addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
}

- (void)stopAnimation
{
    if (_link) {
        [_link invalidate];
        self.link = nil;
    }
}

- (CADisplayLink *)link
{
    if (nil == _link) {
        _link = [CADisplayLink displayLinkWithTarget:self selector:@selector(handleDisplayLink:)];
    }
    return _link;
}

- (void)handleDisplayLink:(CADisplayLink *)displayLink
{
    switch (_animateType) {
        case AnimationType_ToLeft:
        {
            self.left = self.left - _offsetInfps;
            if ( - self.left > self.width) {
                [self stopAnimation];
                [self removeFromSuperview];
            }
        }break;
        case AnimationType_ToRight:{
            
        }break;
        case AnimationType_Fade:{
            
        }break;
        default:
            break;
    }
}

- (void)dealloc
{
    [self stopAnimation];
    NSLog(@"\n--------------销毁--------------");
}

@end
