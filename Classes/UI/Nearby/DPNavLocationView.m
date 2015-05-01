//
//  DPNavLocationView.m
//  biubiu
//
//  Created by haowenliang on 15/3/30.
//  Copyright (c) 2015年 dpsoft. All rights reserved.
//

#import "DPNavLocationView.h"

@interface DPNavLocationView ()
@property (nonatomic, strong) CALayer* iconLayer;
@property (nonatomic, strong) UILabel* lbsLabel;
@end

@implementation DPNavLocationView

- (void)awakeFromNib
{
    [super awakeFromNib];
    [self setup];
}

- (void)setup
{
    _needsHighlightImage = NO;
    self.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
    self.backgroundColor = [UIColor clearColor];
    self.lbsLabel = ({
        UILabel* label = [[UILabel alloc] initWithFrame:CGRectZero];
        label.textColor = [UIColor colorWithColorType:ColorType_WhiteTxt];
        label.font = [DPFont boldSystemFontOfSize:FONT_SIZE_LARGE];
        label.textAlignment = NSTextAlignmentCenter;
        label.backgroundColor = [UIColor clearColor];
        label.lineBreakMode = NSLineBreakByTruncatingTail;
        label.numberOfLines = 1;
        label;
    });
    
    self.iconLayer = ({
        CALayer* layer = [CALayer layer];
        UIImage* image = LOAD_ICON_USE_POOL_CACHE(@"bb_navigation_lbs.png");
        layer.bounds = CGRectMake(0.0f,0.0f,image.size.width,image.size.height);
        layer.backgroundColor = [UIColor clearColor].CGColor;
        layer.contents = (id)image.CGImage;
        layer.anchorPoint = CGPointMake(0, 0);
        layer;
    });
    
    [self.layer addSublayer:self.iconLayer];
    [self addSubview:self.lbsLabel];
    self.height = CGRectGetHeight(self.iconLayer.frame);
}

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self setup];
    }
    return self;
}

- (void)setLbsLabelContent:(NSString*)content
{
    _lbsLabel.text = content;
    [_lbsLabel sizeToFit];
    _lbsLabel.height = self.height;
    
    _lbsLabel.left = CGRectGetWidth(self.iconLayer.frame) + _size_S(10);
    self.width = CGRectGetMaxX(_lbsLabel.frame);
}

- (void)updateLayerContent:(UIImage*)image
{
    CGRect frame = self.iconLayer.frame;
    frame.size.width = image.size.width;
    
    self.height =frame.size.height = image.size.height;
    self.iconLayer.contents = (id)image.CGImage;
    [self.iconLayer setFrame:frame];
    
    _lbsLabel.height = self.height;
    _lbsLabel.left = CGRectGetWidth(self.iconLayer.frame) + _size_S(10);
    self.width = CGRectGetMaxX(_lbsLabel.frame);
}

- (void)setHighlighted:(BOOL)highlighted
{
    [super setHighlighted:highlighted];
    if(_needsHighlightImage == NO)return;
    
    if (!highlighted) {
        UIImage* image = LOAD_ICON_USE_POOL_CACHE(@"bb_random_normal.png");
        _iconLayer.contents = (id)image.CGImage;
        _lbsLabel.textColor = [UIColor colorWithColorType:ColorType_WhiteTxt];
    }else{
        UIImage* image = LOAD_ICON_USE_POOL_CACHE(@"bb_random_pressed.png");
        _iconLayer.contents = (id)image.CGImage;
        _lbsLabel.textColor = RGBACOLOR(0x45, 0xb5, 0xe7, 1);
    }
}

@end
