//
//  DPEmptyView.m
//  BiuBiu
//
//  Created by haowenliang on 15/1/26.
//  Copyright (c) 2015年 dpsoft. All rights reserved.
//

#import "DPEmptyView.h"
#import <NIAttributedLabel.h>

@interface DPEmptyView()
{
    UIImageView* _logoImgView;
    NIAttributedLabel* _emptyInfoLabel;
}

@end

@implementation DPEmptyView

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor colorWithColorType:ColorType_EmptyViewBg];
        
        _logoImgView = [[UIImageView alloc] initWithFrame:CGRectZero];
        _logoImgView.backgroundColor = [UIColor clearColor];
        _logoImgView.contentMode = UIViewContentModeScaleAspectFit;
        [self addSubview:_logoImgView];
        
        _emptyInfoLabel = [[NIAttributedLabel alloc] initWithFrame:CGRectZero];
        _emptyInfoLabel.textAlignment = NSTextAlignmentCenter;
        _emptyInfoLabel.numberOfLines = 0;
        _emptyInfoLabel.lineHeight = _size_S(23);
        _emptyInfoLabel.textColor = [self normalTextColor];
        _emptyInfoLabel.font = [DPFont systemFontOfSize:FONT_SIZE_LARGE];
        _emptyInfoLabel.width = self.width - _size_S(100);
        [self addSubview:_emptyInfoLabel];
    }
    return self;
}

- (void)setEmptyLogoName:(NSString *)emptyLogoName
{
    _emptyLogoName = emptyLogoName;
    
    UIImage* img = LOAD_ICON_USE_POOL_CACHE(emptyLogoName);
    _logoImgView.image = img;
    _logoImgView.size = img.size;
}

- (void)setEmptyInformation:(NSString *)emptyInformation
{
    _emptyInformation = emptyInformation;
    
    [_emptyInfoLabel setText:_emptyInformation];
    [_emptyInfoLabel sizeToFit];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    if (_viewType == DPEmptyViewType_BiuHelper) {
        _logoImgView.top = _size_S(32);
        _emptyInfoLabel.top = _logoImgView.bottom + _size_S(8);
        _emptyInfoLabel.centerX = _logoImgView.centerX = self.width/2;
    }else{
        _logoImgView.bottom = self.height/2;
        _emptyInfoLabel.top = self.height/2 + _size_S(8);
        _emptyInfoLabel.centerX = _logoImgView.centerX = self.width/2;
    }
}

- (UIColor*)normalTextColor
{
    return [UIColor colorWithColorType:ColorType_BlueTxt];
}

- (UIColor*)highlightTextColor
{
    return [UIColor colorWithColorType:ColorType_MediumTxt];
}

- (void)highlightKeyText:(NSString*)keyText
{
    if ([_emptyInformation length] && [keyText length]) {
        NSRange range = [_emptyInformation rangeOfString:keyText];
        if (range.location != NSNotFound) {
            [_emptyInfoLabel setTextColor:[self highlightTextColor] range:range];
        }
    }
}

@end


@implementation DPEmptyView (ViewType)

+ (DPEmptyView*)getEmptyViewWithFrame:(CGRect)frame viewType:(DPEmptyViewType)type
{
    DPEmptyView* emptyView = [[DPEmptyView alloc] initWithFrame:frame];
    emptyView.viewType = type;
    [emptyView setEmptyLogoName:[self logoWithViewType:type]];
    [emptyView setEmptyInformation:[self msgWithViewType:type]];
    NSString* keyword = [self keywordWithViewType:type];
    if ([keyword length]) {
        [emptyView highlightKeyText:keyword];
    }
    
    return emptyView;
}

+ (NSString*)logoWithViewType:(DPEmptyViewType)type
{
    NSString* logo = @"";
    switch (type) {
        case DPEmptyViewType_LocationError:{
            logo = @"empty/bb_empty_lbs.png";
        }break;
        case DPEmptyViewType_NetworkError:{
            logo = @"empty/bb_empty_network.png";
        }break;
        case DPEmptyViewType_TopicListEmpty:
        case DPEmptyViewType_UnionPostNone:
        case DPEmptyViewType_NearbyNone:{
            logo = @"empty/bb_empty_nearby.png";
        }break;
        case DPEmptyViewType_MessageNone:{
            logo = @"empty/bb_empty_message.png";
        }break;
        case DPEmptyViewType_PostNone:{
            logo = @"empty/bb_empty_question.png";
        }break;
        case DPEmptyViewType_ReplyNone:{
            logo = @"empty/bb_empty_answer.png";
        }break;
        case DPEmptyViewType_BiuHelper:{
            logo = @"empty/bb_empty_network.png";
        }break;
        case DPEmptyViewType_DefaultError:
        default:{
            logo = @"empty/bb_empty_nearby.png";
        }break;
    }
    return logo;
}

+ (NSString*)msgWithViewType:(DPEmptyViewType)type
{
    NSString* msg = @"";
    switch (type) {
        case DPEmptyViewType_LocationError:{
            msg = NSLocalizedString(@"BB_TXTID_定位权限提示", @"");
        }break;
        case DPEmptyViewType_NetworkError:{
            msg = NSLocalizedString(@"BB_TXTID_网络错误提示", @"");
        }break;
        case DPEmptyViewType_NearbyNone:{
            msg = NSLocalizedString(@"BB_TXTID_附近无数据", @"");
        }break;
        case DPEmptyViewType_MessageNone:{
            msg = NSLocalizedString(@"BB_TXTID_消息无数据", @"");
        }break;
        case DPEmptyViewType_PostNone:{
            msg = NSLocalizedString(@"BB_TXTID_我的提问无数据", @"");
        }break;
        case DPEmptyViewType_ReplyNone:{
            msg = NSLocalizedString(@"BB_TXTID_我的回答无数据", @"");
        }break;
        case DPEmptyViewType_UnionPostNone:{
            msg = NSLocalizedString(@"BB_TXTID_版块内提问无数据", @"");
        }break;
        case DPEmptyViewType_BiuHelper:{
            msg = NSLocalizedString(@"BB_TXTID_biubiu助手提示语", @"");
        }break;
        case DPEmptyViewType_TopicListEmpty:{
            msg = NSLocalizedString(@"BB_TXTID_无版块数据", @"");
        }break;
        case DPEmptyViewType_DefaultError:
        default:{
            msg = NSLocalizedString(@"BB_TXTID_默认错误", @"");
        }break;
    }
    return msg;
}

+ (NSString*)keywordWithViewType:(DPEmptyViewType)type
{
    NSString* msg = nil;
    switch (type) {
        case DPEmptyViewType_LocationError:{
            msg = NSLocalizedString(@"BB_TXTID_定位高亮", @"");
        }break;
        case DPEmptyViewType_NetworkError:{
        }break;
        case DPEmptyViewType_NearbyNone:{
        }break;
        case DPEmptyViewType_MessageNone:{
        }break;
        case DPEmptyViewType_PostNone:{
        }break;
        case DPEmptyViewType_ReplyNone:{
        }break;
        case DPEmptyViewType_DefaultError:
        default:{
        }break;
    }
    return msg;
}

@end