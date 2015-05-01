//
//  DPListStyleLeftView.m
//  BiuBiu
//
//  Created by haowenliang on 15/1/16.
//  Copyright (c) 2015年 dpsoft. All rights reserved.
//

#import "DPListStyleLeftView.h"

#define COLOR_AREA_WIDTH _size_S(4)

#pragma mark -
@implementation DPListStyleLeftView

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        _numberLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _numberLabel.textColor = [UIColor colorWithColorType:ColorType_LightTxt];
        _numberLabel.backgroundColor = [UIColor clearColor];
        _numberLabel.textAlignment = NSTextAlignmentCenter;
        _numberLabel.font = [DPFont systemFontOfSize:FONT_SIZE_MIDDLE];
        
        _infoLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _infoLabel.text = NSLocalizedString(@"BB_TXTID_回答", @"");
        _infoLabel.textColor = [UIColor colorWithColorType:ColorType_LightTxt];
        _infoLabel.backgroundColor = [UIColor clearColor];
        _infoLabel.textAlignment = NSTextAlignmentCenter;
        _infoLabel.font = [DPFont systemFontOfSize:FONT_SIZE_MIDDLE];
        [_infoLabel sizeToFit];
        
        [self addSubview:_numberLabel];
        [self addSubview:_infoLabel];
        
        _contentState = ListStyleViewState_None;
        
        _arrowView = [[UIImageView alloc] initWithImage:LOAD_ICON_USE_POOL_CACHE(@"bb_right_arrow.png")];
        [self addSubview:_arrowView];
        
        _colorArea = [[UIView alloc] initWithFrame:CGRectMake(0, 0, COLOR_AREA_WIDTH, self.height)];
        [self addSubview:_colorArea];
    }
    return self;
}

- (void)setColorAreaType:(NSInteger)type
{
    if (type%2) {
        self.backgroundColor = [UIColor colorWithColorType:ColorType_DeepGray];
    }else{
        self.backgroundColor = [UIColor colorWithColorType:ColorType_LightGray];
    }
    
    switch (type%3) {
        case 0:
            _colorArea.backgroundColor = [UIColor colorWithColorType:ColorType_Green];
            break;
        case 1:
            _colorArea.backgroundColor = [UIColor colorWithColorType:ColorType_Pink];
            break;
        case 2:
            _colorArea.backgroundColor = [UIColor colorWithColorType:ColorType_Yellow];
            break;
        default:
            break;
    }
}

- (void)setNumber:(NSInteger)number
{
    NSString* numStr = nil;
    if (number > 99) {
        numStr = @"99+";
    }else{
        numStr = [NSString stringWithFormat:@"%zd",number];
    }
    [_numberLabel setText:numStr];
    [_numberLabel sizeToFit];
}

- (void)displayArrowAndLabel
{
    _arrowView.hidden = NO;
    switch (_contentState) {
        case ListStyleViewState_Open:
        {
            _arrowView.center = CGPointMake((self.width-COLOR_AREA_WIDTH)/2, self.height/2);
            _infoLabel.hidden = _numberLabel.hidden = YES;
        }break;
        case ListStyleViewState_None:
        default:{
            _arrowView.hidden = YES;
            _infoLabel.hidden = _numberLabel.hidden = NO;
            _infoLabel.top = self.height/2;
            _numberLabel.bottom = self.height/2 - _size_S(5);
            _arrowView.centerX = _infoLabel.centerX = _numberLabel.centerX = (self.width-COLOR_AREA_WIDTH)/2;
            _arrowView.centerY = self.height/2;
        }break;
    }
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    _colorArea.right = self.width;
    _colorArea.height = self.height;
    [self displayArrowAndLabel];
}

@end
