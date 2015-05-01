//
//  DPTouchButton.h
//  BiuBiu
//
//  Created by haowenliang on 15/1/27.
//  Copyright (c) 2015年 dpsoft. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DPTouchButton : UIButton
{
    UIImageView* _imageView;
    UILabel* _msgLabel;
    BOOL _touchSelected;
    CGFloat _contentWidth;
}
@property (nonatomic, assign) BOOL touchSelected;
@property (nonatomic, strong) UIImage* normalImage;
@property (nonatomic, strong) UIImage* highlightImage;

- (void)setNormalImage:(UIImage *)nimage highlightImage:(UIImage *)himage message:(NSString*)message;
- (void)setMessageText:(NSString*)message;

- (void)setSelected:(BOOL)selected clickEnable:(BOOL)enable;
@end
