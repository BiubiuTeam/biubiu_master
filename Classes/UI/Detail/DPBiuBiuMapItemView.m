//
//  DPBiuBiuMapItemView.m
//  BiuBiu
//
//  Created by haowenliang on 14/12/21.
//  Copyright (c) 2014年 dpsoft. All rights reserved.
//

#import "DPBiuBiuMapItemView.h"
#import "DPTouchButton.h"
#import "DPContentLabel.h"
#import "DPHttpService.h"
#import "BackSourceInfo_2001.h"

#import "DPQuestionUpdateService.h"
#define DETAILVIEW_CONTENT_INSETX _size_S(42)
#define DETAILVIEW_CONTENT_MARGINY _size_S(37)
#define DETAILVIEW_CONTENT_MARGIN_BOTTOM _size_S(78)

#define DETAILVIEW_BOTTOM_MARGIN _size_S(17)
#define DETAILVIEW_BOTTOM_INSETX _size_S(23)
#define DETAILVIEW_BOTTOM_ITEM_INSET _size_S(30)

@interface DPBiuBiuMapItemView ()
@property (nonatomic, strong) DPTouchButton* upvoteArea;
@property (nonatomic, strong) DPTouchButton* downvoteArea;
@property (nonatomic, strong) DPContentLabel* contentLabel;
@property (nonatomic, strong) UILabel* nickNameLabel;

@end

@implementation DPBiuBiuMapItemView

- (void)dealloc
{
    DPTrace("释放详情信息主展示区域");
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    self.upvoteArea = nil;
    self.downvoteArea = nil;
    self.contentLabel = nil;
    self.nickNameLabel = nil;
    self.datasource = nil;
    
    self.upvoteBlock = nil;
    self.downvoteBlock = nil;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor whiteColor];
        
        _contentLabel = [[DPContentLabel alloc] initWithFrame:CGRectMake(DETAILVIEW_CONTENT_INSETX, DETAILVIEW_CONTENT_MARGINY,  self.width - DETAILVIEW_CONTENT_INSETX*2, 0) contentType:ContentType_Center];
        _contentLabel.numberOfLines = 0;
        
        [self addSubview:_contentLabel];
        
        [self initializeBottomViews];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(voteCallback:) name:kNotification_VoteOptCallBack object:nil];        
    }
    return self;
}

- (void)initializeBottomViews
{
    _nickNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(DETAILVIEW_BOTTOM_INSETX, 0, 0, 0)];
    _nickNameLabel.backgroundColor = [UIColor clearColor];
    _nickNameLabel.textAlignment = NSTextAlignmentLeft;
    _nickNameLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    _nickNameLabel.textColor = [UIColor colorWithColorType:ColorType_LightTxt];
    _nickNameLabel.font = [DPFont systemFontOfSize:FONT_SIZE_MIDDLE];
    _nickNameLabel.numberOfLines = 1;
    [self addSubview:_nickNameLabel];
    
    UIImage* upNormal = LOAD_ICON_USE_POOL_CACHE(@"bb_upvote_normal.png");
    UIImage* upSelected = LOAD_ICON_USE_POOL_CACHE(@"bb_upvote_selected.png");
    _upvoteArea = [[DPTouchButton alloc] initWithFrame:CGRectZero];
    [_upvoteArea setNormalImage:upNormal highlightImage:upSelected message:@"0"];
    [_upvoteArea addTarget:self action:@selector(didPressedUpvoteBtn) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_upvoteArea];
    
    UIImage* downNormal = LOAD_ICON_USE_POOL_CACHE(@"bb_downvote_normal.png");
    UIImage* downSelected = LOAD_ICON_USE_POOL_CACHE(@"bb_downvote_selected.png");
    _downvoteArea = [[DPTouchButton alloc] initWithFrame:CGRectZero];
    [_downvoteArea setNormalImage:downNormal highlightImage:downSelected message:@"0"];
    [_downvoteArea addTarget:self action:@selector(didPressedDownvoteBtn) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_downvoteArea];
}

- (void)didPressedUpvoteBtn
{
    DPTrace("DETAIL %s",__FUNCTION__);
    if(_upvoteArea.selected == YES){
        return;
    }
    _upvoteArea.selected = YES;
    if (_upvoteBlock) {
        _upvoteBlock(self);
    }else{
        DPTrace("DETAIL No UpvoteBlock");
        DPQuestionModel* content = (DPQuestionModel*)_datasource;
        [[DPHttpService shareInstance] excuteCmdToVoteQuestion:content.questId ansId:0 like:1];
    }
}

- (void)didPressedDownvoteBtn
{
    DPTrace("DETAIL %s",__FUNCTION__);
    if(_downvoteArea.selected == YES){
        return;
    }
    _downvoteArea.selected = YES;
    if (_downvoteBlock) {
        _downvoteBlock(self);
    }else{
        DPTrace("DETAIL No DownvoteBlock");
        DPQuestionModel* content = (DPQuestionModel*)_datasource;
        [[DPHttpService shareInstance] excuteCmdToVoteQuestion:content.questId ansId:0 like:2];
    }
}

- (void)voteCallback:(NSNotification*)notification
{
    DPTrace("%s",__FUNCTION__);
    NSDictionary* userInfo = notification.userInfo;
    if ([userInfo count]) {
        NSDictionary* cmdObject = [userInfo objectForKey:kNotification_CmdObject];
        if ([cmdObject count]) {
            DPQuestionModel* content = (DPQuestionModel*)_datasource;
            if ([[cmdObject objectForKey:@"questId"] integerValue] == content.questId) {
                if ([[cmdObject objectForKey:@"ansId"] integerValue] == 0) {
                    BOOL needToUpdate = NO;
                    NSInteger like = [[cmdObject objectForKey:@"like"] integerValue];
                    if([[userInfo objectForKey:kNotification_StatusCode] integerValue] == 0){
                        if (like == 1) {
                            DPQuestionModel* content = (DPQuestionModel*)_datasource;
                            content.likeNum ++;
                            content.likeFlag = @(1);
                            needToUpdate = YES;
                            DPTrace("Upvote Succeed");
                        }else if (like == 2){
                            DPQuestionModel* content = (DPQuestionModel*)_datasource;
                            content.unlikeNum ++;
                            content.likeFlag = @(2);
                            needToUpdate = YES;
                            DPTrace("DownVote Succeed");
                        }
                        [self updateMessageWithSource];
                    }else if([[userInfo objectForKey:kNotification_StatusCode] integerValue] == 2){
                        DPTrace("%@",[userInfo objectForKey:kNotification_StatusInfo]);
                    }else{
                        if (like == 1) {
                            DPTrace("Upvote Failed");
                            _upvoteArea.selected = NO;
                        }else if (like == 2){
                            DPTrace("DownVote Failed");
                            _downvoteArea.selected = NO;
                        }
                    }
                    if (needToUpdate) {
                        [self forceToUpdateModel];
                    }
                }
            }
        }
    }
}

- (void)displayBottomViews
{
    _nickNameLabel.bottom = _upvoteArea.bottom = _downvoteArea.bottom = self.height - DETAILVIEW_BOTTOM_MARGIN;
    
    _downvoteArea.right = self.width - DETAILVIEW_BOTTOM_INSETX;
    _upvoteArea.right = _downvoteArea.left - DETAILVIEW_BOTTOM_ITEM_INSET;
    
    _nickNameLabel.width = _upvoteArea.left - _nickNameLabel.left - _size_S(5);
}

- (void)setDatasource:(id)datasource
{
    _datasource = datasource;
    [self updateMessageWithSource];
    
//    [self forceToUpdateModel];
}

- (void)updateMessageWithSource
{
    DPQuestionModel* content = (DPQuestionModel*)_datasource;
    [_contentLabel setContentText:content.quest];
    _contentLabel.width = self.width - 2*DETAILVIEW_CONTENT_INSETX;
    NSString* sign = content.sign;
    if (![sign length]) {
        sign = NSLocalizedString(@"BB_TXTID_匿名", nil);
    }
    [_nickNameLabel setText:sign];
    [_nickNameLabel sizeToFit];
    [_upvoteArea setMessageText:[NSString stringWithFormat:@"%zd",content.likeNum]];
    [_downvoteArea setMessageText:[NSString stringWithFormat:@"%zd",content.unlikeNum]];
    
    [_upvoteArea setSelected:[content.likeFlag integerValue] == 1];
    [_downvoteArea setSelected:[content.likeFlag integerValue] == 2];
    
    if ([content.likeFlag integerValue] != 0) {
        _upvoteArea.userInteractionEnabled = NO;
        _downvoteArea.userInteractionEnabled = NO;
    }else{
        _upvoteArea.userInteractionEnabled = YES;
        _downvoteArea.userInteractionEnabled = YES;
    }
    
    self.height = _contentLabel.height + [DPBiuBiuMapItemView defaultHeight];
}

- (void)forceToUpdateModel
{
    DPQuestionModel* content = (DPQuestionModel*)_datasource;
    __weak DPBiuBiuMapItemView* weakTmp = self;
    [[DPQuestionUpdateService shareInstance] updateQuestionModelWithID:content.questId completion:^(DPQuestionModel *question, DPResponseType type) {
        if(type == DPResponseType_Succeed)
            [weakTmp setDatasource:question];
    }];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    [self displayBottomViews];
}

+ (CGFloat)defaultHeight
{
    return DETAILVIEW_CONTENT_MARGINY + DETAILVIEW_CONTENT_MARGIN_BOTTOM;
}

@end
