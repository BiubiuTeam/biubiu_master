//
//  DPTouchButton.m
//  BiuBiu
//
//  Created by haowenliang on 15/1/27.
//  Copyright (c) 2015年 dpsoft. All rights reserved.
//

#import "DPTouchButton.h"

#define BUTTON_LABEL_INSET _size_S(10)
#define BUTTON_SCALE _size_S(10)

@implementation DPTouchButton

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        self.contentMode = UIViewContentModeCenter;
        
        self.backgroundColor = [UIColor clearColor];
        _imageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        _imageView.backgroundColor = [UIColor clearColor];
        [self addSubview:_imageView];
        
        _msgLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _msgLabel.backgroundColor = [UIColor clearColor];
        _msgLabel.textColor = [UIColor colorWithColorType:ColorType_LightTxt];
        _msgLabel.font = [DPFont systemFontOfSize:FONT_SIZE_SMALL];
        [self addSubview:_msgLabel];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    _imageView.center = CGPointMake(_normalImage.size.width/2, self.height/2);
    _imageView.left = BUTTON_SCALE/2;
    _msgLabel.left = _imageView.right + BUTTON_LABEL_INSET;
    _msgLabel.centerY = _imageView.centerY = self.height/2;
}

- (void)setNormalImage:(UIImage *)nimage highlightImage:(UIImage *)himage message:(NSString*)message
{
    self.normalImage = nimage;
    self.highlightImage = himage;
    [self setImageViewContent];
    
    [_msgLabel setText:message];
    [_msgLabel sizeToFit];
    
    self.size = CGSizeMake(_normalImage.size.width + BUTTON_LABEL_INSET + _msgLabel.width + BUTTON_SCALE, MAX(_normalImage.size.height,_msgLabel.height) + BUTTON_SCALE);
}

- (void)setSelected:(BOOL)selected clickEnable:(BOOL)enable
{
    self.selected = selected;
    self.userInteractionEnabled = enable;
}

- (void)setMessageText:(NSString*)message
{
    [_msgLabel setText:message];
    [_msgLabel sizeToFit];

    self.size = CGSizeMake(_normalImage.size.width + BUTTON_LABEL_INSET + _msgLabel.width + BUTTON_SCALE, MAX(_normalImage.size.height,_msgLabel.height) + BUTTON_SCALE);
}

- (void)setSelected:(BOOL)selected
{
    [super setSelected:selected];
    [self setTouchSelected:selected];
    
//    [self setImageViewContent];
}

- (void)setTouchSelected:(BOOL)touchSelected
{
    _touchSelected = touchSelected;
    [self setImageViewContent];
}

- (void)setHighlighted:(BOOL)highlighted
{
    [super setHighlighted:highlighted];
    [self setImageViewContent];
}

- (void)setImageViewContent
{
    if (self.selected || self.highlighted) {
        [_imageView setImage:_highlightImage];
        _imageView.size = _highlightImage.size;
    }else{
        [_imageView setImage:_normalImage];
        _imageView.size = _normalImage.size;
    }
}

- (void)dealloc
{
    DPTrace("点赞按钮");
}
@end
