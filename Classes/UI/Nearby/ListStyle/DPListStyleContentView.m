//
//  DPListStyleContentView.m
//  BiuBiu
//
//  Created by haowenliang on 15/1/16.
//  Copyright (c) 2015年 dpsoft. All rights reserved.
//

#import "DPListStyleContentView.h"
#import "DPContentLabel.h"

@interface DPListStyleContentView ()
@end

@implementation DPListStyleContentView

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self setup];
    }
    return self;
}

- (void)setup
{
    self.backgroundColor = [UIColor clearColor];
    
    [self initializeControls];
    [self layoutControls];
}

- (void)initializeControls
{
    CGFloat xpoint = _size_S(16);
    CGFloat ypoint = _size_S(16);
    CGFloat width = self.width - xpoint*2;
    
    _nickLabel = [DPListStyleContentView defaultNickLabelWithFrame:CGRectMake(xpoint, ypoint, width, 0)];
    [self addSubview:_nickLabel];

    _contentLabel = [[DPContentLabel alloc] initWithFrame:CGRectMake(xpoint, _nickLabel.bottom + _size_S(14), width, 0) contentType:ContentType_Left];
    _contentLabel.numberOfLines = 0;
    [self addSubview:_contentLabel];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    [self layoutControls];
}

- (void)layoutControls
{
    _nickLabel.width = self.width - 2*_nickLabel.origin.x;
    _contentLabel.width = self.width - 2*_contentLabel.origin.x;
}

- (void)setNickText:(NSString*)nick contentText:(NSString*)content
{
    if (![nick length]) {
        nick = NSLocalizedString(@"BB_TXTID_匿名", nil);
    }
    if (![content length]) {
        content = @"   ";
    }
    _nickLabel.text = nick;
    [_contentLabel setContentText:content];
}

- (void)markAsPolicyContent:(BOOL)marked
{
    if (marked) {
        _contentLabel.textColor = [UIColor colorWithColorType:ColorType_BlueTxt];
    }else{
        _contentLabel.textColor = [UIColor colorWithColorType:ColorType_DeepTxt];
    }
}

- (void)highlightContent:(BOOL)hightlight
{
    if (hightlight) {
        _nickLabel.textColor = [UIColor colorWithColorType:ColorType_HighlightTxt];
    }else{
        _nickLabel.textColor = RGBACOLOR(0x45, 0xb5, 0xe7, 1);
    }
}
#pragma mark -
+ (UILabel*)defaultNickLabelWithFrame:(CGRect)frame
{
    UILabel* tmpLabel = [[UILabel alloc] initWithFrame:frame];
    tmpLabel.text = NSLocalizedString(@"BB_TXTID_匿名", nil);
    tmpLabel.backgroundColor = [UIColor clearColor];
    tmpLabel.textAlignment = NSTextAlignmentLeft;
    tmpLabel.textColor = RGBACOLOR(0x45, 0xb5, 0xe7, 1);
    tmpLabel.font = [DPFont systemFontOfSize:FONT_SIZE_MIDDLE];
    [tmpLabel sizeToFit];
    return tmpLabel;
}

#pragma mark - get auto adjust height

+ (CGFloat)defaultHeight
{
    return _size_S(48);
}

+ (CGFloat)cellHeightForContentText:(NSString*)content
{
    CGFloat height = [self defaultHeight];
    
    if ([content length]) {
        height += [DPContentLabel caculateHeightOfTxt:content contentType:ContentType_Left maxWidth:(SCREEN_WIDTH - 2*_size_S(16))];
    }
    return height;
}

@end
