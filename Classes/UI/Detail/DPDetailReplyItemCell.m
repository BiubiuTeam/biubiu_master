//
//  DPDetailReplyItemCell.m
//  BiuBiu
//
//  Created by haowenliang on 15/1/27.
//  Copyright (c) 2015年 dpsoft. All rights reserved.
//

#import "DPDetailReplyItemCell.h"
#import "DPTouchButton.h"
#import "DPContentLabel.h"
#import "NSDateAdditions.h"
#import "BackSourceInfo_2005.h"
#import "DPAnswerUpdateService.h"

#define REPLYITEM_CONTENT_INSETX _size_S(23)
#define REPLYITEM_CONTENT_MARGINY _size_S(21)
#define REPLYITEM_CONTENT_MARGIN_BOTTOM _size_S(44)

#define REPLYITEM_BOTTOM_MARGIN _size_S(12)
#define REPLYITEM_BOTTOM_INSETX _size_S(23)
#define REPLYITEM_BOTTOM_ITEM_INSET _size_S(30)

#define REPLYITEM_FLOOR_RADIUS _size_S(30)
#define REPLYITEM_MARGIN_LEFT _size_S(15)
#define REPLYITEM_INSET_HOR _size_S(15)
#define REPLYITEM_FLOOR_TOP _size_S(20)
#define REPLYITEM_MARGIN_RIGHT _size_S(12)

@interface DPDetailReplyItemCell ()

@property (nonatomic, strong) DPTouchButton* upvoteArea;
@property (nonatomic, strong) DPTouchButton* downvoteArea;
@property (nonatomic, strong) DPContentLabel* contentLabel;

@property (nonatomic, strong) UILabel* timeLabel;
@property (nonatomic, strong) UILabel* floorLabel;//楼层

@property (nonatomic, strong) UIButton* followFloorBtn;//回复内容提示
@end

@implementation DPDetailReplyItemCell

- (void)dealloc
{
    DPTrace("释放回复Cell单元");
    self.delegate = nil;
    self.upvoteArea = nil;
    self.downvoteArea = nil;
    self.contentLabel = nil;
    self.timeLabel = nil;
    self.floorLabel = nil;
}

- (UILabel *)floorLabel
{
    if (nil == _floorLabel) {
        _floorLabel = [[UILabel alloc] initWithFrame:CGRectMake(REPLYITEM_MARGIN_LEFT, REPLYITEM_FLOOR_TOP, REPLYITEM_FLOOR_RADIUS, REPLYITEM_FLOOR_RADIUS)];
        _floorLabel.textAlignment = NSTextAlignmentCenter;
        _floorLabel.layer.cornerRadius = REPLYITEM_FLOOR_RADIUS/2;
        _floorLabel.layer.masksToBounds = YES;
        _floorLabel.font = [UIFont systemFontOfSize:FONT_SIZE_SMALL];
        _floorLabel.textColor = [UIColor colorWithColorType:ColorType_WhiteTxt];
    }
    return _floorLabel;
}

- (UIButton *)followFloorBtn
{
    if (nil == _followFloorBtn) {
        _followFloorBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 0, REPLYITEM_FOLLOW_HEIGHT)];
        _followFloorBtn.titleLabel.textAlignment = NSTextAlignmentLeft;
        _followFloorBtn.backgroundColor = [UIColor clearColor];//RGBACOLOR(0xda, 0xda, 0xda, 1);
        _followFloorBtn.titleLabel.font = [UIFont systemFontOfSize:FONT_SIZE_SMALL];
        _followFloorBtn.titleLabel.numberOfLines = 1;
        UIImage* image = LOAD_ICON_USE_POOL_CACHE(@"bb_detail_reply.png");
        image = [image stretchableImageWithLeftCapWidth:20 topCapHeight:14];
        [_followFloorBtn setBackgroundImage:image forState:UIControlStateNormal];
        [_followFloorBtn setBackgroundImage:image forState:UIControlStateHighlighted];
        _followFloorBtn.titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        [_followFloorBtn setTitleColor:[UIColor colorWithColorType:ColorType_MediumTxt] forState:UIControlStateNormal];
        
        UIEdgeInsets insets = {7, 8, 0, 8};
        _followFloorBtn.contentEdgeInsets = insets;
    }
    return _followFloorBtn;
}

- (void)setFollowFloorNumber:(NSInteger)number followMsg:(NSString*)msg
{
    NSString* text = [NSString stringWithFormat:@"回复%zd楼：%@",number,msg];
    [_followFloorBtn setTitle:text forState:UIControlStateNormal];
    [_followFloorBtn sizeToFit];

    _followFloorBtn.width = MIN(_contentLabel.width, _followFloorBtn.width);
    _followFloorBtn.height = REPLYITEM_FOLLOW_HEIGHT;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        CGRect cframe = CGRectMake(REPLYITEM_CONTENT_INSETX, REPLYITEM_FLOOR_TOP + _size_S(5), SCREEN_WIDTH - 2*REPLYITEM_CONTENT_INSETX , 0);
        cframe.origin.x = REPLYITEM_MARGIN_LEFT + REPLYITEM_INSET_HOR + REPLYITEM_FLOOR_RADIUS;
        cframe.size.width = SCREEN_WIDTH - cframe.origin.x - REPLYITEM_MARGIN_RIGHT;
        _contentLabel = [[DPContentLabel alloc] initWithFrame:cframe contentType:ContentType_Left];
        _contentLabel.numberOfLines = 0;
        _contentLabel.font = [DPFont systemFontOfSize:FONT_SIZE_MIDDLE];
        [_contentLabel setTextColor:[UIColor colorWithColorType:ColorType_MediumTxt]];
        [self.contentView addSubview:_contentLabel];
        
        [self.contentView addSubview:self.floorLabel];
        [self initializeBottomViews];
    }
    return self;
}

- (void)setFloorNumber:(NSInteger)number
{
    switch (number%3) {
        case 0:
            _floorLabel.backgroundColor = [UIColor colorWithColorType:ColorType_Green];
            break;
        case 1:
            _floorLabel.backgroundColor = [UIColor colorWithColorType:ColorType_Pink];
            break;
        case 2:
            _floorLabel.backgroundColor = [UIColor colorWithColorType:ColorType_Yellow];
            break;
        default:
            break;
    }
    _floorLabel.text = [NSString stringWithFormat:@"%zd",number];
}

- (void)initializeBottomViews
{
    _timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(REPLYITEM_BOTTOM_INSETX, 0, 0, 0)];
    _timeLabel.backgroundColor = [UIColor clearColor];
    _timeLabel.textAlignment = NSTextAlignmentLeft;
    _timeLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    _timeLabel.textColor = [UIColor colorWithColorType:ColorType_LightTxt];
    _timeLabel.font = [DPFont systemFontOfSize:FONT_SIZE_SMALL];
    _timeLabel.numberOfLines = 1;
    [self.contentView addSubview:_timeLabel];
    
    UIImage* upNormal = LOAD_ICON_USE_POOL_CACHE(@"bb_upvote_normal.png");
    UIImage* upSelected = LOAD_ICON_USE_POOL_CACHE(@"bb_upvote_selected.png");
    _upvoteArea = [[DPTouchButton alloc] initWithFrame:CGRectZero];
    [_upvoteArea setNormalImage:upNormal highlightImage:upSelected message:@"0"];
    [_upvoteArea addTarget:self action:@selector(didPressedUpvoteBtn) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:_upvoteArea];
    
    UIImage* downNormal = LOAD_ICON_USE_POOL_CACHE(@"bb_downvote_normal.png");
    UIImage* downSelected = LOAD_ICON_USE_POOL_CACHE(@"bb_downvote_selected.png");
    _downvoteArea = [[DPTouchButton alloc] initWithFrame:CGRectZero];
    [_downvoteArea setNormalImage:downNormal highlightImage:downSelected message:@"0"];
    [_downvoteArea addTarget:self action:@selector(didPressedDownvoteBtn) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:_downvoteArea];
}

- (void)didPressedUpvoteBtn
{
    DPTrace("PostCard %s",__FUNCTION__);
    DPAnswerModel* model = [self replyModel];
    if ([model.likeFlag integerValue]) {
        return;
    }
    if (_upvoteArea.selected == YES) {
        return;
    }
    _upvoteArea.selected = YES;
    if (_delegate && [_delegate respondsToSelector:@selector(voteAnswerUpOrDown:voteModel:)]) {
        [_delegate voteAnswerUpOrDown:1 voteModel:model];
    }
    [self updateViewWithReplyModel];
}

- (void)didPressedDownvoteBtn
{
    DPTrace("PostCard %s",__FUNCTION__);
    DPAnswerModel* model = [self replyModel];
    if ([model.likeFlag integerValue]) {
        return;
    }
    if (_downvoteArea.selected == YES) {
        return;
    }
    _downvoteArea.selected = YES;
    if (_delegate && [_delegate respondsToSelector:@selector(voteAnswerUpOrDown:voteModel:)]) {
        [_delegate voteAnswerUpOrDown:2 voteModel:model];
    }
    [self updateViewWithReplyModel];
}

- (void)displayBottomViews
{
    _timeLabel.bottom = _upvoteArea.bottom = _downvoteArea.bottom = self.height - REPLYITEM_BOTTOM_MARGIN;
    
    _downvoteArea.right = self.width - REPLYITEM_BOTTOM_INSETX;
    _upvoteArea.right = _downvoteArea.left - REPLYITEM_BOTTOM_ITEM_INSET;
    
    _timeLabel.width = self.width - _timeLabel.left - _upvoteArea.left;
}

- (void)setAnsId:(NSInteger)ansId
{
    _ansId = ansId;
    [self updateViewWithReplyModel];
}

- (DPAnswerModel *)replyModel
{
    return [[DPAnswerUpdateService shareInstance] getAnswerDetail:_ansId questionId:_questionId];
}

- (void)updateViewWithReplyModel
{
    DPAnswerModel* model = [self replyModel];
    [_contentLabel setContentText:model.ans];
    [self setFloorNumber:[model.floorId integerValue]];
    [_timeLabel setText:[NSDate compareCurrentTime:[NSDate dateWithTimeIntervalSince1970:model.pubTime]]];
    [_timeLabel sizeToFit];
    [_upvoteArea setMessageText:[NSString stringWithFormat:@"%zd",model.likeNum]];
    [_downvoteArea setMessageText:[NSString stringWithFormat:@"%zd",model.unlikeNum]];
    
    [_upvoteArea setSelected:[model.likeFlag integerValue] == 1];
    [_downvoteArea setSelected:[model.likeFlag integerValue] == 2];

    _contentLabel.width = SCREEN_WIDTH - _contentLabel.left - REPLYITEM_MARGIN_RIGHT;
    
    CGFloat tHeight =  _contentLabel.height + [DPDetailReplyItemCell defaultHeight];
    
    if (model.otherAnsData) {
        [self.contentView addSubview:self.followFloorBtn];
        [self setFollowFloorNumber:[[model.otherAnsData floorId] integerValue] followMsg:[model.otherAnsData ans]];
        _followFloorBtn.left = _contentLabel.left;
        _followFloorBtn.top = _contentLabel.bottom;
        tHeight += REPLYITEM_FOLLOW_HEIGHT;
    }else{
        [_followFloorBtn removeFromSuperview];
        self.followFloorBtn = nil;
    }
    self.height = tHeight;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    [self displayBottomViews];
    UIView* sep = [self findSubview:@"_UITableViewCellSeparatorView" resursion:YES];
    CGRect frame = sep.frame;
    frame.size.width += frame.origin.x;
    frame.origin.x = 0;
    sep.frame = frame;
    
    [self bringSubviewToFront:sep];
}

#pragma mark -
- (void)setUpvoteAreaSelected:(BOOL)selected
{
    _upvoteArea.selected = selected;
}

- (void)setDownvoteAreaSelected:(BOOL)selected
{
    _downvoteArea.selected = selected;
}

- (void)setHighLightContent:(BOOL)highLightContent
{
    _highLightContent = highLightContent;
    if (_highLightContent) {
        [_contentLabel setTextColor:[UIColor colorWithColorType:ColorType_HighlightTxt]];
    }else{
        [_contentLabel setTextColor:[UIColor colorWithColorType:ColorType_MediumTxt]];
    }
}

+ (CGFloat)defaultHeight
{
    return REPLYITEM_CONTENT_MARGINY + REPLYITEM_CONTENT_MARGIN_BOTTOM;
}

+ (CGFloat)cellHeightForContentText:(NSString*)content withFollowMsg:(BOOL)withfm
{
    CGFloat height = [self defaultHeight];
    if ([content length]) {
        height += [DPContentLabel caculateHeightOfTxt:content contentType:ContentType_Left maxWidth:(SCREEN_WIDTH - 2*REPLYITEM_CONTENT_INSETX)];
    }
    if (withfm) {
        height += REPLYITEM_FOLLOW_HEIGHT;
    }
    return height;
}

@end
