//
//  DPContentLabel.m
//  biubiu
//
//  Created by haowenliang on 15/1/31.
//  Copyright (c) 2015年 dpsoft. All rights reserved.
//

#import "DPContentLabel.h"

@implementation DPContentLabel

#pragma mark -Class Method
+ (NSMutableParagraphStyle*)centerContentStyle
{
    static NSMutableParagraphStyle* _centerStyle = nil;
    static dispatch_once_t onceTokenCenterStyle;
    dispatch_once(&onceTokenCenterStyle, ^{
        _centerStyle = [[NSMutableParagraphStyle alloc] init];
        [_centerStyle setLineSpacing:_size_S(8)];
        [_centerStyle setAlignment:NSTextAlignmentCenter];
        [_centerStyle setLineBreakMode:NSLineBreakByTruncatingTail];
    });
    return _centerStyle;
}

+ (NSMutableParagraphStyle*)leftContentStyle
{
    static NSMutableParagraphStyle* _leftStyle = nil;
    static dispatch_once_t onceTokenLeftStyle;
    dispatch_once(&onceTokenLeftStyle, ^{
        _leftStyle = [[NSMutableParagraphStyle alloc] init];
        [_leftStyle setLineSpacing:_size_S(8)];
        [_leftStyle setAlignment:NSTextAlignmentLeft];
        [_leftStyle setLineBreakMode:NSLineBreakByTruncatingTail];
    });
    return _leftStyle;
}

+ (DPContentLabel*)defaultLabelWithType:(ContentType)type
{
    static DPContentLabel* _labelInstance = nil;
    static dispatch_once_t onceTokenInstance;
    dispatch_once(&onceTokenInstance, ^{
        _labelInstance = [[DPContentLabel alloc] initWithFrame:CGRectZero];
    });
    
    _labelInstance.type = type;
    return _labelInstance;
}

+ (CGFloat)caculateHeightOfTxt:(NSString*)content contentType:(ContentType)type maxWidth:(CGFloat)width
{
    return [self caculateHeightOfTxt:content contentType:type maxWidth:width lines:0];
}


+ (CGFloat)caculateHeightOfTxt:(NSString*)content
                     contentType:(ContentType)type
                        maxWidth:(CGFloat)width
                           lines:(NSInteger)num
{
    if (![content length]) {
        return 0;
    }
    DPContentLabel* tmpLabel = [DPContentLabel defaultLabelWithType:type];
    tmpLabel.numberOfLines = num;
    tmpLabel.width = width;
    [tmpLabel setContentText:content];
    [tmpLabel sizeToFit];
    return tmpLabel.height;
}

#pragma mark -Instance Methods
- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        _type = ContentType_Center;
        [self setup];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame contentType:(ContentType)type
{
    if (self = [super initWithFrame:frame]) {
        _type = type;
        [self setup];
    }
    return self;
}

- (void)setType:(ContentType)type
{
    _type = type;
    [self setup];
}

- (void)setup
{
    switch (_type) {
        case ContentType_Center:
        {
            self.textAlignment = NSTextAlignmentCenter;
        }break;
        case ContentType_Left:
        {
            self.textAlignment = NSTextAlignmentLeft;
        }break;
        default:
            break;
    }
    self.backgroundColor = [UIColor clearColor];
    self.textColor = [UIColor colorWithColorType:ColorType_DeepTxt];
    self.font = [DPFont systemFontOfSize:FONT_SIZE_LARGE];
    self.numberOfLines = 3;
}

- (void)setContentText:(NSString *)content
{
    NSUInteger strLength = [content length];
    if(strLength < 1)return;
    NSMutableAttributedString* attributedText = [[NSMutableAttributedString alloc] initWithString:content];
    [attributedText addAttribute:NSParagraphStyleAttributeName
                           value:[self paragraphStyleOfType]
                           range:NSMakeRange(0, strLength)];
    
    self.attributedText = attributedText;
    [self sizeToFit];
}

#pragma mark -private methods
- (NSMutableParagraphStyle*)paragraphStyleOfType
{
    switch (_type) {
        case ContentType_Center:
        {
            return [DPContentLabel centerContentStyle];
        }break;
        default:
            break;
    }
    return [DPContentLabel leftContentStyle];
}

@end
