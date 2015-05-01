//
//  ProgressTool.m
//  biubiu
//
//  Created by haowenliang on 15/2/11.
//  Copyright (c) 2015年 dpsoft. All rights reserved.
//

#import "ProgressTool.h"

#ifdef DEBUG
#define ShowHUD_DLog(fmt, ...) NSLog((@"ShowHUD.m:%s:%d" fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__);
#else
#define ShowHUD_DLog(...)
#endif

@interface ProgressTool ()<MBProgressHUDDelegate>
{
    MBProgressHUD   *_hud;
}
@property (nonatomic, strong) MBProgressHUD   *hud;
@end

@implementation ProgressTool

- (instancetype)initWithView:(UIView *)view
{
    if (view == nil) {
        return nil;
    }
    
    self = [super init];
    if (self) {
        _hud = [[MBProgressHUD alloc] initWithView:view];
        _hud.delegate                  = self;                       // 设置代理
        _hud.animationType             = MBProgressHUDAnimationZoom; // 默认动画样式
        _hud.removeFromSuperViewOnHide = YES;                        // 该视图隐藏后则自动从父视图移除掉
        [view addSubview:_hud];
    }
    return self;
}

- (instancetype)init
{
    if (self = [super init]) {
        _hud = [[MBProgressHUD alloc] initWithView:[[UIApplication sharedApplication] keyWindow]];
        _hud.delegate                  = self;                       // 设置代理
        _hud.animationType             = MBProgressHUDAnimationZoom; // 默认动画样式
        _hud.removeFromSuperViewOnHide = YES;                        // 该视图隐藏后则自动从父视图移除掉
        _hud.dimBackground = NO;
    }
    return self;
}

- (void)hide:(BOOL)hide afterDelay:(NSTimeInterval)delay
{
    [_hud hide:hide afterDelay:delay];
}

- (void)hide
{
    [_hud hide:YES];
}

- (void)show:(BOOL)show
{
    // 根据属性判断是否要显示文本
    if (_text != nil && _text.length != 0) {
        _hud.labelText = _text;
    }
    
    // 设置文本字体
    if (_textFont) {
        _hud.labelFont = _textFont;
    }
    
    // 如果设置这个属性,则只显示文本
    if (_showTextOnly == YES && _text != nil && _text.length != 0) {
        _hud.mode = MBProgressHUDModeText;
    }
    
    // 设置背景色
    if (_backgroundColor) {
        _hud.color = _backgroundColor;
    }
    
//    // 文本颜色
//    if (_labelColor) {
//        _hud.labelColor = _labelColor;
//    }
//    
//    // 设置圆角
//    if (_cornerRadius) {
//        _hud.cornerRadius = _cornerRadius;
//    }
    
    // 设置透明度
    if (_opacity) {
        _hud.opacity = _opacity;
    }
    
    // 自定义view
    if (_customView) {
        _hud.mode = MBProgressHUDModeCustomView;
        _hud.customView = _customView;
    }
    
    // 边缘留白
    if (_margin > 0) {
        _hud.margin = _margin;
    }
    
    [_hud show:show];
}

#pragma mark - HUD代理方法
- (void)hudWasHidden:(MBProgressHUD *)hud
{
    [_hud removeFromSuperview];
    _hud = nil;
}

#pragma mark - 重写setter方法
@synthesize animationStyle = _animationStyle;
- (void)setAnimationStyle:(HUDAnimationType)animationStyle
{
    _animationStyle    = animationStyle;
    _hud.animationType = (MBProgressHUDAnimation)_animationStyle;
}
- (HUDAnimationType)animationStyle
{
    return _animationStyle;
}


#pragma mark - 02-11
+ (void)showLoadingWithText:(NSString*)text inView:(UIView *)view
{
    ProgressTool *hud = [[ProgressTool alloc] init];
    hud.hud.labelText = @"正在努力发表中...";
    
    [view addSubview:hud.hud];
}


#pragma mark - 便利的方法
+ (void)showTextOnly:(NSString *)text
     configParameter:(ConfigShowHUDBlock)config
            duration:(NSTimeInterval)sec
              inView:(UIView *)view
{
    if (nil == view) {
        view = [UIApplication sharedApplication].keyWindow;
    }
    ProgressTool *hud = [[ProgressTool alloc] initWithView:view];
    hud.text         = text;
    hud.showTextOnly = YES;
    hud.margin       = 10.f;
    
    // 配置额外的参数
    config(hud);
    
    // 显示
    [hud show:YES];
    
    // 延迟sec后消失
    [hud hide:YES afterDelay:sec];
}

+ (void)showText:(NSString *)text
 configParameter:(ConfigShowHUDBlock)config
        duration:(NSTimeInterval)sec
          inView:(UIView *)view
{
    if (nil == view) {
        view = [UIApplication sharedApplication].keyWindow;
    }
    ProgressTool *hud     = [[ProgressTool alloc] initWithView:view];
    hud.text         = text;
    hud.margin       = 10.f;
    
    // 配置额外的参数
    config(hud);
    
    // 显示
    [hud show:YES];
    
    // 延迟sec后消失
    [hud hide:YES afterDelay:sec];
}


+ (void)showCustomView:(ConfigShowHUDCustomViewBlock)viewBlock
       configParameter:(ConfigShowHUDBlock)config
              duration:(NSTimeInterval)sec
                inView:(UIView *)view
{
    if (nil == view) {
        view = [UIApplication sharedApplication].keyWindow;
    }
    ProgressTool *hud     = [[ProgressTool alloc] initWithView:view];
    hud.margin       = 10.f;
    
    // 配置额外的参数
    config(hud);
    
    // 自定义View
    hud.customView   = viewBlock();
    
    // 显示
    [hud show:YES];
    
    [hud hide:YES afterDelay:sec];
}


+ (instancetype)showTextOnly:(NSString *)text
             configParameter:(ConfigShowHUDBlock)config
                      inView:(UIView *)view
{
    if (nil == view) {
        view = [UIApplication sharedApplication].keyWindow;
    }
    ProgressTool *hud     = [[ProgressTool alloc] initWithView:view];
    hud.text         = text;
    hud.showTextOnly = YES;
    hud.margin       = 10.f;
    
    // 配置额外的参数
    config(hud);
    
    // 显示
    [hud show:YES];
    
    return hud;
}

+ (instancetype)showText:(NSString *)text
         configParameter:(ConfigShowHUDBlock)config
                  inView:(UIView *)view
{
    if (nil == view) {
        view = [UIApplication sharedApplication].keyWindow;
    }
    ProgressTool *hud     = [[ProgressTool alloc] initWithView:view];
    hud.text         = text;
    hud.margin       = 10.f;
    
    // 配置额外的参数
    config(hud);
    
    // 显示
    [hud show:YES];
    
    return hud;
}

+ (instancetype)showCustomView:(ConfigShowHUDCustomViewBlock)viewBlock
               configParameter:(ConfigShowHUDBlock)config
                        inView:(UIView *)view
{
    if (nil == view) {
        view = [UIApplication sharedApplication].keyWindow;
    }
    ProgressTool *hud     = [[ProgressTool alloc] initWithView:view];
    hud.margin       = 10.f;
    
    // 配置额外的参数
    config(hud);
    
    // 自定义View
    hud.customView   = viewBlock();
    
    // 显示
    [hud show:YES];
    
    return hud;
}

- (void)dealloc
{
    ShowHUD_DLog(@"资源释放了,没有泄露^_^");
}


- (void)showHUD
{
    UIWindow *window =  [UIApplication sharedApplication].keyWindow;
    
    switch (1) {
        case 1: {
            [ProgressTool showText:@"message"
              configParameter:^(ProgressTool *config) {
                  config.margin          = 10.f;    // 边缘留白
                  config.opacity         = 0.7f;    // 设定透明度
                  config.cornerRadius    = 1.f;     // 设定圆角
                  config.textFont        = [UIFont systemFontOfSize:11.f];
              } duration:3 inView:window];
        } break;
        case 2: {
            [ProgressTool showTextOnly:@"message"
                  configParameter:^(ProgressTool *config) {
                      config.animationStyle  = ZoomOut;  // 设置动画方式
                      config.margin          = 20.f;     // 边缘留白
                      config.opacity         = 0.8f;     // 设定透明度
                      config.cornerRadius    = 0.1f;     // 设定圆角
                      config.backgroundColor = [[UIColor redColor] colorWithAlphaComponent:0.8];  // 设置背景色
                      config.labelColor      = [[UIColor whiteColor] colorWithAlphaComponent:1.0];// 设置文本颜色
                  } duration:3 inView:window];
        } break;
//        case 3: {
//            BackgroundView *backView = [[BackgroundView alloc] initInView:window];
//            backView.startDuration = 0.25;
//            backView.endDuration   = 0.25;
//            [backView addToView];
//
//            ProgressTool *hud = [ProgressTool showCustomView:^UIView *{
//                // 返回一个自定义view即可,hud会自动根据你返回的view调整空间
//                MulticolorView *showView = [[MulticolorView alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
//                showView.lineWidth       = 1.f;
//                showView.sec             = 1.5f;
//                showView.colors          = @[(id)[UIColor cyanColor].CGColor,
//                                             (id)[UIColor yellowColor].CGColor,
//                                             (id)[UIColor cyanColor].CGColor];
//                [showView startAnimation];
//                return showView;
//            } configParameter:^(ProgressTool *config) {
//                config.animationStyle  = Zoom;   // 设定动画方式
//                config.margin          = 10.f;   // 边缘留白
//                config.cornerRadius    = 2.f;    // 边缘圆角
//                config.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.4f];
//            } inView:window];
//
//            // 延迟5秒后消失
//            [GCDQueue executeInMainQueue:^{
//                [hud hide];
//                [backView removeSelf];
//            } afterDelaySecs:5];
//        } break;
        default:
            break;
    }
}

+ (void)showHUD:(NSString *)text andView:(UIView *)view andHUD:(MBProgressHUD *)hud
{
    [view addSubview:hud];
    hud.labelText = text;//显示提示
    hud.dimBackground = NO;//使背景成黑灰色，让MBProgressHUD成高亮显示
    hud.square = YES;//设置显示框的高度和宽度一样
    [hud show:YES];
}

@end
