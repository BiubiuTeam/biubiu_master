//
//  DPLbsInformationView.m
//  BiuBiu
//
//  Created by haowenliang on 14/12/10.
//  Copyright (c) 2014年 dpsoft. All rights reserved.
//

#import "DPLbsInformationView.h"

@interface DPLbsInformationView ()
@property (nonatomic, strong) UIImageView* lbsIcon;
@property (nonatomic, strong) UILabel* lbsInfo;
@end

@implementation DPLbsInformationView

- (void)dealloc
{
    DPTrace("地理位置区域");
    self.lbsIcon = nil;
    self.lbsInfo = nil;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor clearColor];
        _lbsIcon = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, LBS_ICON_RADIUS, LBS_ICON_RADIUS)];
        _lbsIcon.contentMode = UIViewContentModeCenter;
        _lbsIcon.backgroundColor = [UIColor clearColor];
        _lbsIcon.clipsToBounds = YES;
        _lbsIcon.image = LOAD_ICON_USE_POOL_CACHE(@"bb_lbs_icon.png");
        [self addSubview:_lbsIcon];
        
        _lbsInfo = [[UILabel alloc] initWithFrame:CGRectZero];
        _lbsInfo.backgroundColor = [UIColor clearColor];
        _lbsInfo.lineBreakMode = NSLineBreakByTruncatingTail;
        _lbsInfo.font = [DPFont systemFontOfSize:FONT_SIZE_LARGE];
        _lbsInfo.numberOfLines = 1;
        _lbsInfo.textColor = [UIColor colorWithColorType:ColorType_DeepTxt];
        [self addSubview:_lbsInfo];
        
        _lbsIcon.left = LBS_ICON_LEFT;
        _lbsIcon.centerY = CGRectGetHeight(self.bounds)/2.0;
        _lbsInfo.left = _lbsIcon.right + LBS_ICON_RIGHT;
        _lbsInfo.height = CGRectGetHeight(self.bounds);
        _lbsInfo.width = CGRectGetWidth(self.bounds) - LBS_ICON_LEFT - _lbsInfo.left;
        _lbsInfo.centerY = CGRectGetHeight(self.bounds)/2.0;
    }
    return self;
}

- (void)updateLbsInformationWithText:(NSString*)locationText
{
    _lbsInfo.text = locationText;
}

- (void)updateLabelTextColor:(UIColor*)color font:(UIFont*)font
{
    _lbsInfo.font = font;
    _lbsInfo.textColor = color;
}

- (void)resetLbsIcon:(UIImage*)icon
{
    if (nil == icon) {
        return;
    }
    [_lbsIcon setImage:icon];
}

- (void)centerOpt
{
    [_lbsInfo sizeToFit];
    _lbsInfo.width = MIN(CGRectGetWidth(self.bounds) - LBS_ICON_LEFT - _lbsInfo.left, _lbsInfo.width);
    CGFloat width = _lbsInfo.right - _lbsIcon.left;
    _lbsIcon.left = (self.width - width)/2.0f;
    _lbsInfo.left = _lbsIcon.right + LBS_ICON_RIGHT;
    _lbsInfo.height = self.height;
}
@end
