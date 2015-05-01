//
//  DPListStyleViewCell.m
//  BiuBiu
//
//  Created by haowenliang on 15/1/15.
//  Copyright (c) 2015年 dpsoft. All rights reserved.
//

#import "DPListStyleViewCell.h"
#import "DPListStyleLeftView.h"
#import "DPListStyleContentView.h"
#import "DPListStyleReplyView.h"
#import "ListConstants.h"

#import "BackSourceInfo_2001.h"
#import "DPAnswerUpdateService.h"
#import "DPHttpService.h"
#pragma mark -
@interface DPListStyleViewCell ()
{
    DPListStyleLeftView* leftView;
    DPListStyleContentView* _contentView;
    DPListStyleReplyView* _replyView;
}

@property (nonatomic, strong) UIView* touchAccessoryView;
@property (nonatomic, strong) DPListStyleReplyView* replyView;
@property (nonatomic, strong) DPQuestionModel* postModel;
@end

@implementation DPListStyleViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (ListStyleViewState)contentState
{
    return leftView.contentState;
}

- (void)setContentState:(ListStyleViewState)contentState
{
    leftView.contentState = contentState;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.separatorInset = UIEdgeInsetsZero;
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.openOptBlock = nil;
        self.closeOptBlock = nil;
        self.clickBlock = nil;
        
        _contentView = [[DPListStyleContentView alloc] initWithFrame:CGRectMake(0, 0, self.width - DP_LEFTVIEW_WIDTH, self.height)];
        [self addSubview:_contentView];
        
        _replyView = [[DPListStyleReplyView alloc] initWithFrame:CGRectMake(0, 0, self.width - DP_LEFTVIEW_WIDTH, self.height)];
        [self addSubview:_replyView];
        
        _touchAccessoryView = [[UIView alloc] initWithFrame:self.bounds];
        _touchAccessoryView.backgroundColor = [UIColor clearColor];
        [self addSubview:_touchAccessoryView];
        
        leftView = [[DPListStyleLeftView alloc] initWithFrame:CGRectMake(0, 0, DP_LEFTVIEW_WIDTH, self.height)];
        [self addSubview:leftView];
        leftView.contentState = ListStyleViewState_Close;
        [leftView addTarget:self action:@selector(didClickLeftView) forControlEvents:UIControlEventTouchUpInside];
        
        [self setupSwipGesture];
    }
    return self;
}

- (void)setupSwipGesture
{
    self.userInteractionEnabled = YES;
    UISwipeGestureRecognizer* swipeRight = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipe:)];
    swipeRight.direction = UISwipeGestureRecognizerDirectionRight;
    [self addGestureRecognizer:swipeRight];
    
    UISwipeGestureRecognizer* swipeLeft = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipe:)];
    swipeLeft.direction = UISwipeGestureRecognizerDirectionLeft;
    [self addGestureRecognizer:swipeLeft];
    
//    UITapGestureRecognizer* tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didClickOtherPlace:)];
//    [_touchAccessoryView addGestureRecognizer:tap];
}

- (void)didClickOtherPlace:(UIGestureRecognizer*)gesture
{
    if (gesture.state == UIGestureRecognizerStateEnded) {
        if (_clickBlock) {
            _clickBlock(self);
        }
    }
}

- (void)handleSwipe:(UISwipeGestureRecognizer *)gesture
{
    if (gesture.direction == UISwipeGestureRecognizerDirectionRight){
        if (leftView.contentState == ListStyleViewState_Open) {
            [self didClickLeftView];
        }
    }else if (gesture.direction == UISwipeGestureRecognizerDirectionLeft){
        if (leftView.contentState == ListStyleViewState_Close) {
            [self didClickLeftView];
        }
    }else
        DPTrace("Unrecognized swipe direction");
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

- (void)displaySubViews
{
    CGRect frame = leftView.frame;
    frame.size.height = self.height;
    frame.origin.y = 0;
    switch (leftView.contentState) {
        case ListStyleViewState_Open:
        {
            frame.origin.x = 0;
        } break;
        default:
        {
            frame.origin.x = self.width - frame.size.width;
        }break;
    }
    leftView.frame = frame;
    [leftView displayArrowAndLabel];
    
    CGRect ctnFrame = _contentView.frame;
    ctnFrame.size.width = self.width - leftView.width;
    ctnFrame.size.height = self.height;
    ctnFrame.origin.y = 0;
    ctnFrame.origin.x = MIN(0,frame.origin.x - _contentView.width);
    _contentView.frame = ctnFrame;
    
    CGRect rplFrame = _replyView.frame;
    rplFrame.size.width = self.width - leftView.width;
    rplFrame.size.height = self.height;
    rplFrame.origin.y = 0;
    rplFrame.origin.x = CGRectGetMaxX(frame);
    _replyView.frame = rplFrame;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    [_touchAccessoryView setFrame:self.bounds];
    [self displaySubViews];
}

- (void)setModelInPosition:(NSInteger)modelInPosition
{
    _modelInPosition = modelInPosition;
    
    if (modelInPosition%2) {
        _contentView.backgroundColor = [UIColor colorWithColorType:ColorType_MediumGray];
    }else{
        _contentView.backgroundColor = [UIColor colorWithColorType:ColorType_WhiteBg];
    }
    
    [leftView setColorAreaType:modelInPosition];
    [_replyView setColorType:modelInPosition%3];
}

- (void)closeLeftReplyViewSilence:(BOOL)silence
{
    if(silence){
        leftView.contentState = ListStyleViewState_Close;
        [self displaySubViews];
        [_replyView resetReplyView];
    }else{
        leftView.contentState = ListStyleViewState_Close;
        [UIView animateWithDuration:0.3 animations:^{
            [self displaySubViews];
            [_replyView resetReplyView];
        } completion:^(BOOL finished) {
        }];
    }
}

- (void)openLeftViewOpt
{
    __weak DPListStyleViewCell* weakSelf = self;
    [[DPLocalDataManager shareInstance] getPostReplyList:_postModel.questId completion:^(NSError *error, NSArray *result) {
        if (error == nil && [result count]) {
            DPTrace("加载到现有的反馈数据 %zd 条",[result count]);
            [weakSelf.replyView appendDatasource:result];
        }else{
            DPTrace("附近页面加载回答数据： %@ ， count: %@", error, result);
        }
    }];
}

- (void)didClickLeftView
{
    switch (leftView.contentState) {
        case ListStyleViewState_Close:
        {
            leftView.contentState = ListStyleViewState_Open;
            [self openLeftViewOpt];
            [UIView animateWithDuration:0.3 animations:^{
                [self displaySubViews];
            } completion:^(BOOL finished) {
                
            }];
        } break;
        case ListStyleViewState_Open:
        {
            leftView.contentState = ListStyleViewState_Close;
            [UIView animateWithDuration:0.3 animations:^{
                [self displaySubViews];
                [_replyView resetReplyView];
            } completion:^(BOOL finished) {
            }];
        } break;
        case ListStyleViewState_None:
        default:{
            if (_clickBlock) {
                _clickBlock(self);
            }
        }break;
    }
    
    if (_delegate && [_delegate respondsToSelector:@selector(replyStateChangedAtPosition:toState:)]) {
        [_delegate replyStateChangedAtPosition:_modelInPosition toState:leftView.contentState];
    }
}

#pragma mark -
- (void)setPostContentModel:(id)model
{
    self.postModel = model;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        //请求加载回复列表
        [[DPAnswerUpdateService shareInstance] forceToUpdateAnswerList:_postModel.questId demandedCount:_postModel.ansNum];
//        [[DPLocalDataManager shareInstance] getPostReplyList:_postModel.questId completion:nil];
    });
    [_contentView setNickText:_postModel.sign contentText:_postModel.quest];
    [leftView setNumber:_postModel.ansNum];
    
    //特殊标识
    if ([_postModel.isCreator integerValue] == 1 || [_postModel.opType integerValue] == 2) {
        [_contentView highlightContent:YES];
    }else{
        [_contentView highlightContent:NO];
    }
}

@end
