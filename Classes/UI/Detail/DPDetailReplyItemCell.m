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
#define REPLYITEM_CONTENT_MARGIN_BOTTOM _size_S(48)

#define REPLYITEM_BOTTOM_MARGIN _size_S(12)
#define REPLYITEM_BOTTOM_INSETX _size_S(23)
#define REPLYITEM_BOTTOM_ITEM_INSET _size_S(30)

@interface DPDetailReplyItemCell ()

@property (nonatomic, strong) DPTouchButton* upvoteArea;
@property (nonatomic, strong) DPTouchButton* downvoteArea;
@property (nonatomic, strong) DPContentLabel* contentLabel;

@property (nonatomic, strong) UILabel* timeLabel;

@end

@implementation DPDetailReplyItemCell

- (void)dealloc
{
    DPTrace("释放回复Cell单元");
    self.upvoteArea = nil;
    self.downvoteArea = nil;
    self.contentLabel = nil;
    self.timeLabel = nil;
    self.upvoteClickOpt = nil;
    self.downvoteClickOpt = nil;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.upvoteClickOpt = nil;
        self.downvoteClickOpt = nil;
        
        _contentLabel = [[DPContentLabel alloc] initWithFrame:CGRectMake(REPLYITEM_CONTENT_INSETX, REPLYITEM_CONTENT_MARGINY, SCREEN_WIDTH - 2*REPLYITEM_CONTENT_INSETX , 0) contentType:ContentType_Left];
        _contentLabel.numberOfLines = 0;
        _contentLabel.font = [DPFont systemFontOfSize:FONT_SIZE_MIDDLE];
        [_contentLabel setTextColor:[UIColor colorWithColorType:ColorType_MediumTxt]];
        [self.contentView addSubview:_contentLabel];
        
        [self initializeBottomViews];
    }
    return self;
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
    if (_upvoteClickOpt) {
        _upvoteClickOpt([self replyModel]);
    }else{
        
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
    if (_downvoteClickOpt) {
        _downvoteClickOpt([self replyModel]);
    }else{
        
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
    
    [_timeLabel setText:[NSDate compareCurrentTime:[NSDate dateWithTimeIntervalSince1970:model.pubTime]]];
    [_timeLabel sizeToFit];
    [_upvoteArea setMessageText:[NSString stringWithFormat:@"%zd",model.likeNum]];
    [_downvoteArea setMessageText:[NSString stringWithFormat:@"%zd",model.unlikeNum]];
    
    [_upvoteArea setSelected:[model.likeFlag integerValue] == 1];
    [_downvoteArea setSelected:[model.likeFlag integerValue] == 2];

    _contentLabel.width = SCREEN_WIDTH - 2*REPLYITEM_CONTENT_INSETX;
    self.height = _contentLabel.height + [DPDetailReplyItemCell defaultHeight];
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

+ (CGFloat)cellHeightForContentText:(NSString*)content
{
    CGFloat height = [self defaultHeight];
    if ([content length]) {
        height += [DPContentLabel caculateHeightOfTxt:content contentType:ContentType_Left maxWidth:(SCREEN_WIDTH - 2*REPLYITEM_CONTENT_INSETX)];
    }
    return height;
}

@end
