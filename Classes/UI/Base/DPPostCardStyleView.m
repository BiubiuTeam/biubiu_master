//
//  DPPostCardStyleView.m
//  BiuBiu
//
//  Created by haowenliang on 15/1/26.
//  Copyright (c) 2015年 dpsoft. All rights reserved.
//

#import "DPPostCardStyleView.h"
#import "DPLbsInformationView.h"
#import "NSDateAdditions.h"
#import "DPContentLabel.h"
#import "DPTouchButton.h"


#define POST_CARD_STYLE_TOPY _size_S(10) //默认13 + 7 = 20
#define POST_CARD_STYLE_TOPX _size_S(7)

#define POST_CARD_STYLE_INSET _size_S(20)
#define POST_CARD_STYLE_STROKE_HEIGHT _size_S(0.8)
#define POST_CARD_STYLE_STROKE_COLOR RGBACOLOR(0xe8, 0xe8, 0xe8, 1)

#define POST_CARD_STYLE_TOP_HEIGHT _size_S(32)

#define POST_CARD_STYLE_CONTENT_INSETX _size_S(42)
#define POST_CARD_STYLE_CONTENT_INSETY _size_S(27)

#define POST_CARD_BOTTOM_HEIGHT _size_S(45)
#define POST_CARD_BOTTOM_TOPX _size_S(14) //距离分割线距离

#define POST_CARD_BOTTOM_TXT_INSET _size_S(10)
#define POST_CARD_BOTTOM_ITEM_INSET _size_S(30)


@interface DPPostCardStyleView ()
{
    UIView* _strokeLine;
}

@property (nonatomic, strong) DPTouchButton* replyArea;
@property (nonatomic, strong) DPTouchButton* upvoteArea;
@property (nonatomic, strong) DPTouchButton* downvoteArea;

@property (nonatomic, strong) DPLbsInformationView* locationInfo;
@property (nonatomic, strong) UILabel* timeLabel;
@property (nonatomic, strong) DPContentLabel* contentLabel;

@end

@implementation DPPostCardStyleView

-(void)dealloc
{
    DPTrace("卡片模式");
    self.datasource = nil;
    self.btnClickBlock = nil;
    
    self.replyArea = nil;
    self.upvoteArea = nil;
    self.downvoteArea = nil;
    self.locationInfo = nil;
    self.timeLabel = nil;
    self.contentLabel = nil;
    _strokeLine = nil;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        self.btnClickBlock = nil;

        [self initializeLbsView];
        [self initializeTimeLabel];
        [self initializeContentLabel];
        
        CGRect strokeLineRect = CGRectMake(POST_CARD_STYLE_INSET, 0, SCREEN_WIDTH - 2*POST_CARD_STYLE_INSET, POST_CARD_STYLE_STROKE_HEIGHT);
        _strokeLine = [[UIView alloc] initWithFrame:strokeLineRect];
        _strokeLine.backgroundColor = POST_CARD_STYLE_STROKE_COLOR;
        [self addSubview:_strokeLine];
        
        [self initializeBottomImageViews];
    }
    return self;
}

- (void)initializeBottomImageViews
{
    UIImage* replyNormal = LOAD_ICON_USE_POOL_CACHE(@"bb_reply_gray.png");
    UIImage* replySelected = LOAD_ICON_USE_POOL_CACHE(@"bb_reply_gray.png");

    _replyArea = [[DPTouchButton alloc] initWithFrame:CGRectZero];
    [_replyArea setNormalImage:replyNormal highlightImage:replySelected message:@"0"];
    [_replyArea addTarget:self action:@selector(didPressedBtn) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_replyArea];

    UIImage* upNormal = LOAD_ICON_USE_POOL_CACHE(@"bb_upvote_normal.png");
    UIImage* upSelected = LOAD_ICON_USE_POOL_CACHE(@"bb_upvote_normal.png");
    _upvoteArea = [[DPTouchButton alloc] initWithFrame:CGRectZero];
    [_upvoteArea setNormalImage:upNormal highlightImage:upSelected message:@"0"];
    [_upvoteArea addTarget:self action:@selector(didPressedBtn) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_upvoteArea];
    
    UIImage* downNormal = LOAD_ICON_USE_POOL_CACHE(@"bb_downvote_normal.png");
    UIImage* downSelected = LOAD_ICON_USE_POOL_CACHE(@"bb_downvote_normal.png");
    _downvoteArea = [[DPTouchButton alloc] initWithFrame:CGRectZero];
    [_downvoteArea setNormalImage:downNormal highlightImage:downSelected message:@"0"];
    [_downvoteArea addTarget:self action:@selector(didPressedBtn) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_downvoteArea];

    [self layoutBottomViews];
}

- (void)didPressedBtn
{
    if (_btnClickBlock) {
        _btnClickBlock(_datasource);
    }else{
        DPTrace("PostCard No btnClickBlock");
    }
}

- (void)layoutBottomViews
{
    _replyArea.centerY = _upvoteArea.centerY = _downvoteArea.centerY = self.height - POST_CARD_BOTTOM_HEIGHT/2;
    _upvoteArea.centerX = self.width/2;

    _replyArea.right = _upvoteArea.left - POST_CARD_BOTTOM_ITEM_INSET;
    _downvoteArea.left = _upvoteArea.right + POST_CARD_BOTTOM_ITEM_INSET;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    _contentLabel.top = POST_CARD_STYLE_TOP_HEIGHT + POST_CARD_STYLE_CONTENT_INSETY;
    _contentLabel.centerX = self.width/2;
    _strokeLine.bottom = _contentLabel.bottom + POST_CARD_STYLE_CONTENT_INSETY;
    
    [self layoutBottomViews];
    
    _timeLabel.right = SCREEN_WIDTH - POST_CARD_STYLE_INSET;
    _timeLabel.centerY = _locationInfo.centerY;
    _locationInfo.width = SCREEN_WIDTH - _timeLabel.left;
}

#pragma mark -init ui
- (void)initializeLbsView
{
    _locationInfo = [[DPLbsInformationView alloc] initWithFrame:CGRectMake(POST_CARD_STYLE_TOPX, POST_CARD_STYLE_TOPY, CGRectGetWidth(self.bounds) - _size_S(64), POST_CARD_STYLE_TOP_HEIGHT)];
    [_locationInfo setBackgroundColor:[UIColor clearColor]];
    
    [_locationInfo updateLabelTextColor:RGBACOLOR(0xff, 0xa2, 0x00, 1) font:[DPFont systemFontOfSize:FONT_SIZE_SMALL]];
    [_locationInfo resetLbsIcon:LOAD_ICON_USE_POOL_CACHE(@"bb_location_icon_hot.png")];
    [self addSubview:_locationInfo];
}

- (void)initializeTimeLabel
{
    _timeLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    _timeLabel.backgroundColor = [UIColor clearColor];
    _timeLabel.textAlignment = NSTextAlignmentLeft;
    _timeLabel.textColor = [UIColor colorWithColorType:ColorType_LightTxt];
    _timeLabel.font = [DPFont systemFontOfSize:FONT_SIZE_SMALL];
    _timeLabel.numberOfLines = 1;
    [self addSubview:_timeLabel];
}

- (void)initializeContentLabel
{
    _contentLabel = [[DPContentLabel alloc] initWithFrame:CGRectZero contentType:ContentType_Center];
    _contentLabel.width = SCREEN_WIDTH - 2*POST_CARD_STYLE_CONTENT_INSETX;
    [self addSubview:_contentLabel];
}

#pragma mark -数据设置

- (void)setTimeText:(NSString*)time locationInfo:(NSString*)lbsinfo content:(NSString*)content
{
    [self.timeLabel setText:time];
    [_timeLabel sizeToFit];
    
    [_locationInfo updateLbsInformationWithText:lbsinfo];
    
    [_contentLabel setContentText:content];
    _contentLabel.width = SCREEN_WIDTH - 2*POST_CARD_STYLE_CONTENT_INSETX;
}

- (void)setReplyNumber:(NSInteger)reply upvoteNumber:(NSInteger)upvote downVoteNumber:(NSInteger)downvote
{
    [_replyArea setMessageText:[NSString stringWithFormat:@"%zd",reply]];
    [_upvoteArea setMessageText:[NSString stringWithFormat:@"%zd",upvote]];
    [_downvoteArea setMessageText:[NSString stringWithFormat:@"%zd",downvote]];
}

+ (CGFloat)otherControlHeight
{
    CGFloat height = POST_CARD_STYLE_TOP_HEIGHT + POST_CARD_STYLE_CONTENT_INSETY;
    height += POST_CARD_STYLE_CONTENT_INSETY;
    height += POST_CARD_BOTTOM_HEIGHT;
    return height;
}

+ (CGFloat)adjustHeightWhenFillWithContent:(NSString*)content
{
    if([content length])
    {
        return [DPContentLabel caculateHeightOfTxt:content contentType:ContentType_Center maxWidth:(SCREEN_WIDTH - 2*POST_CARD_STYLE_CONTENT_INSETX) lines:3] + [self otherControlHeight];
    }
    return [self otherControlHeight];
}

@end
