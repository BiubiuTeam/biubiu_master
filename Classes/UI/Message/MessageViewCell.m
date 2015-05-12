//
//  MessageViewCell.m
//  biubiu
//
//  Created by haowenliang on 15/2/13.
//  Copyright (c) 2015年 dpsoft. All rights reserved.
//

#import "MessageViewCell.h"
#import "NSDateAdditions.h"
#import "DPContentLabel.h"

#define MESSAGE_MARGIN_Y _size_S(13)
#define MESSAGE_MARGIN_X _size_S(13)
#define MESSAGE_INSET_X _size_S(11)

#define MESSAGE_IMG_WIDTH _size_S(48)
#define MESSAGE_IMG_HEIGHT _size_S(63)

#define MESSAGE_INFO_RADIUS _size_S(63)

#define MESSAGE_CONTENT_YPOINT _size_S(18)

#define MESSAGE_TIME_MARGIN_CONTENT _size_S(18)

#define MESSAGE_TIME_MARGIN_LOGO _size_S(12)

@interface InsetsLabel : UILabel
@property(nonatomic) UIEdgeInsets insets;
-(id) initWithFrame:(CGRect)frame andInsets: (UIEdgeInsets) insets;
-(id) initWithInsets: (UIEdgeInsets) insets;
@end

@implementation InsetsLabel
@synthesize insets=_insets;
-(id) initWithFrame:(CGRect)frame andInsets:(UIEdgeInsets)insets {
    self = [super initWithFrame:frame];
    if(self){
        self.insets = insets;
    }
    return self;
}
-(id) initWithInsets:(UIEdgeInsets)insets {
    self = [super init];
    if(self){
        self.insets = insets;
    }
    return self;
}
-(void) drawTextInRect:(CGRect)rect {
    return [super drawTextInRect:UIEdgeInsetsInsetRect(rect, self.insets)];
}
@end

@interface InfoView : UIView

@property (nonatomic, strong) InsetsLabel* infoLabel;
- (void)setText:(NSString*)text;
@end

@implementation InfoView

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        _infoLabel = [[InsetsLabel alloc] initWithFrame:self.bounds];
        [_infoLabel setInsets:UIEdgeInsetsMake(5, 5, 5, 5)];
        _infoLabel.textAlignment = NSTextAlignmentCenter;
        _infoLabel.layer.borderWidth = 0.0;
        _infoLabel.backgroundColor = [UIColor clearColor];
        _infoLabel.textColor = [UIColor colorWithColorType:ColorType_MediumTxt];
        _infoLabel.font = [DPFont systemFontOfSize:FONT_SIZE_SMALL];
        _infoLabel.numberOfLines = 3;
        _infoLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        [self addSubview:_infoLabel];
    }
    return self;
}

- (void)setText:(NSString*)text
{
    _infoLabel.text = text;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.backgroundColor = [UIColor colorWithColorType:ColorType_WhiteBg];
    
}

@end


@interface MessageViewCell ()
{
    UIView* _maskView;
}
@property (nonatomic, strong) UIImageView* messageLogo;
@property (nonatomic, strong) UILabel* contentLabel;
@property (nonatomic, strong) UILabel* timeLabel;
@property (nonatomic, strong) InfoView* infoView;

@end


@implementation MessageViewCell


- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        _messageLogo = [[UIImageView alloc] initWithFrame:CGRectMake(MESSAGE_MARGIN_X, MESSAGE_MARGIN_Y, MESSAGE_IMG_WIDTH, MESSAGE_IMG_HEIGHT)];
        _messageLogo.backgroundColor = [UIColor clearColor];
        _messageLogo.contentMode = UIViewContentModeScaleAspectFit;
        [self.contentView addSubview:_messageLogo];
        
        CGFloat x = MESSAGE_MARGIN_X + MESSAGE_INSET_X + MESSAGE_IMG_WIDTH;
        CGFloat y = MESSAGE_CONTENT_YPOINT;
        CGFloat width = SCREEN_WIDTH - x - MESSAGE_INFO_RADIUS - MESSAGE_MARGIN_X - MESSAGE_INSET_X;
        
        _contentLabel = [[UILabel alloc] initWithFrame:CGRectMake(x, y, width, 0)];
        _contentLabel.font = [DPFont systemFontOfSize:FONT_SIZE_MIDDLE];
        _contentLabel.numberOfLines = 2;
        _contentLabel.textAlignment = NSTextAlignmentLeft;
        [_contentLabel setTextColor:[UIColor colorWithColorType:ColorType_DeepTxt]];
        [self.contentView addSubview:_contentLabel];

        _timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(x, 0, 0, 0)];
        _timeLabel.text = @"00:00";
        _timeLabel.font = [DPFont systemFontOfSize:FONT_SIZE_SMALL];
        _timeLabel.textColor = [UIColor colorWithColorType:ColorType_LightTxt];
        [_timeLabel sizeToFit];
        [self.contentView addSubview:_timeLabel];
        
        _infoView = [[InfoView alloc] initWithFrame:CGRectMake(0, 0, MESSAGE_INFO_RADIUS, MESSAGE_INFO_RADIUS)];
        _infoView.right = SCREEN_WIDTH - MESSAGE_MARGIN_X;
        [self.contentView addSubview:_infoView];
    }
    return self;
}

- (void)setMessageType:(UNREAD_MESSAGETYPE)type
{
    NSString* imageName = nil;
    switch (type) {
        case UNREAD_MESSAGETYPE_QUESTION:
            imageName = NSLocalizedString(@"BB_SRCID_MSG_Quest", nil);
            break;
        case UNREAD_MESSAGETYPE_FLOOR:
        case UNREAD_MESSAGETYPE_ANSWER:
            imageName = NSLocalizedString(@"BB_SRCID_MSG_Answer", nil);
            break;
        case UNREAD_MESSAGETYPE_VOTE:
            imageName = NSLocalizedString(@"BB_SRCID_MSG_Vote", nil);
            break;
        case UNREAD_MESSAGETYPE_NOTIFICATION:
            imageName = NSLocalizedString(@"BB_SRCID_MSG_Notification", nil);
            break;
        default:
            break;
    }
    _messageLogo.image = LOAD_ICON_USE_POOL_CACHE(imageName);
}

- (void)setMaskOnView:(BOOL)withMask
{
    [_maskView removeFromSuperview];
    if (withMask == NO) {
        return;
    }
    
    if (nil == _maskView) {
        _maskView = [[UIView alloc] initWithFrame:self.bounds];
        _maskView.width = SCREEN_WIDTH;
        _maskView.backgroundColor = [UIColor colorWithColorType:ColorType_MaskColor];

    }
    [self addSubview:_maskView];
    [self bringSubviewToFront:_maskView];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    _infoView.centerY = self.height/2;

    _timeLabel.bottom = _infoView.bottom - _size_S(2);//_contentLabel.bottom + MESSAGE_TIME_MARGIN_CONTENT;
    
    _maskView.height = self.height;
    UIView* sep = [self findSubview:@"_UITableViewCellSeparatorView" resursion:YES];
    CGRect frame = sep.frame;
    frame.size.width += frame.origin.x;
    frame.origin.x = 0;
    sep.frame = frame;
    [self bringSubviewToFront:sep];
}

- (void)setContentText:(NSString*)content info:(NSString*)info date:(NSDate*)date
{
    [_contentLabel setText:content];
    [_contentLabel sizeToFit];
    CGFloat x = MESSAGE_MARGIN_X + MESSAGE_INSET_X + MESSAGE_IMG_WIDTH;
    CGFloat width = SCREEN_WIDTH - x - MESSAGE_INFO_RADIUS - MESSAGE_MARGIN_X - MESSAGE_INSET_X;
    _contentLabel.width = width;
    
    [_infoView setText:info];
    _timeLabel.text = [NSDate formatterDateForHM:date];
    
    [self setNeedsLayout];
}

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

+ (CGFloat)miniHeight
{
    return MESSAGE_IMG_HEIGHT + MESSAGE_MARGIN_Y*2;
}

+ (CGFloat)changableHeight:(NSString*)content
{
    CGFloat x = MESSAGE_MARGIN_X + MESSAGE_INSET_X + MESSAGE_IMG_WIDTH;
    CGFloat width = SCREEN_WIDTH - x - MESSAGE_INFO_RADIUS - MESSAGE_MARGIN_X - MESSAGE_INSET_X;
    
    CGFloat height = MESSAGE_CONTENT_YPOINT + MESSAGE_TIME_MARGIN_CONTENT + MESSAGE_MARGIN_Y;
    //时间区域高度
    height += MESSAGE_MARGIN_Y;
    
    height += [DPContentLabel caculateHeightOfTxt:content contentType:ContentType_Left maxWidth:width];
   
    return ceil(MAX([self miniHeight], height));
}

+ (CGFloat)limitedHeight
{
    CGFloat height = MESSAGE_CONTENT_YPOINT + MESSAGE_TIME_MARGIN_CONTENT + MESSAGE_MARGIN_Y;
    //时间区域高度
    height += MESSAGE_MARGIN_Y;
    return ceil(MAX([self miniHeight], height));
}

@end
