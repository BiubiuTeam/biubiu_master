//
//  DPListStyleViewCell.m
//  BiuBiu
//
//  Created by haowenliang on 15/1/15.
//  Copyright (c) 2015年 dpsoft. All rights reserved.
//

#import "DPListStyleViewCell.h"
#import "DPTouchButton.h"
#import "DPListStyleContentView.h"
#import "DPListStyleReplyView.h"
#import "ListConstants.h"
#import "DPQuestionUpdateService.h"

#import "BackSourceInfo_2001.h"
#import "DPAnswerUpdateService.h"
#import "DPHttpService.h"
#import "DPSociatyModel.h"

#pragma mark -
@interface DPListStyleViewCell ()
{
    UIView* _colorArea;
    DPListStyleContentView* _contentView;

}
@property (nonatomic, strong) DPTouchButton* upvoteArea;
@property (nonatomic, strong) DPTouchButton* downvoteArea;

@property (nonatomic, strong) UIView* touchAccessoryView;
@property (nonatomic, strong) DPQuestionModel* postModel;

@property (nonatomic, strong) UIButton* messageButton;

@property (nonatomic, strong) UILabel* ansNumLabel;
@property (nonatomic, strong) UILabel* placeLabel;
@property (nonatomic, strong) UILabel* distanceLabel;

@property (nonatomic, strong) UIView* bottomTouchView;
@end

@implementation DPListStyleViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.separatorInset = UIEdgeInsetsZero;
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        _contentView = [[DPListStyleContentView alloc] initWithFrame:CGRectMake(0, 0, self.width - COLOR_AREA_WIDTH, CELLDEGAULTHEIGHT)];
        [self addSubview:_contentView];
    
        _touchAccessoryView = [[UIView alloc] initWithFrame:self.bounds];
        _touchAccessoryView.backgroundColor = [UIColor clearColor];
        [self addSubview:_touchAccessoryView];
        
        _colorArea = [[UIView alloc] initWithFrame:CGRectMake(0, 0, COLOR_AREA_WIDTH, self.height)];
        [self addSubview:_colorArea];
        
        self.distanceLabel = ({
            UILabel* label = [[UILabel alloc] initWithFrame:CGRectZero];
            label.textColor = [UIColor colorWithColorType:ColorType_LightTxt];
            label.textAlignment = NSTextAlignmentCenter;
            label.backgroundColor = [UIColor clearColor];
            label.font = [DPFont systemFontOfSize:FONT_SIZE_SMALL];
            label;
        });
        self.placeLabel = ({
            UILabel* label = [[UILabel alloc] initWithFrame:CGRectZero];
            label.textColor = [UIColor colorWithColorType:ColorType_WhiteTxt];
            label.textAlignment = NSTextAlignmentCenter;
            label.font = [DPFont systemFontOfSize:FONT_SIZE_SMALL];
            label;
        });
        self.ansNumLabel = ({
            UILabel* label = [[UILabel alloc] initWithFrame:CGRectZero];
            label.textColor = [UIColor colorWithColorType:ColorType_LightTxt];
            label.backgroundColor = [UIColor clearColor];
            label.textAlignment = NSTextAlignmentCenter;
            label.font = [DPFont systemFontOfSize:FONT_SIZE_SMALL];
            label;
        });
        
        [self addSubview:_distanceLabel];
        [self addSubview:_placeLabel];
        [self addSubview:_ansNumLabel];
        
        [self setPtType:SociatyType_Public ptName:@"< 3 km"];
        
        [self setAnswerNumber:0];
        
        [self addBottomViews];
        _contentState = ListStyleViewState_Close;
    }
    return self;
}

- (UIView *)bottomTouchView
{
    if (nil == _bottomTouchView) {
        _bottomTouchView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, CELLBOTTOMHEIGHT + _size_S(16))];
        _bottomTouchView.backgroundColor = [UIColor clearColor];
        
        UITapGestureRecognizer* gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didClickBottomTouchView)];
        [_bottomTouchView addGestureRecognizer:gesture];
    }
    return _bottomTouchView;
}

- (void)setPtType:(SociatyType)type ptName:(NSString*)name
{
    if (type == SociatyType_School) {
        _placeLabel.text = NSLocalizedString(@"BB_TXTID_校", nil);
        _placeLabel.backgroundColor = [UIColor colorWithColorType:ColorType_NavBar];
    }else{
        _placeLabel.text = NSLocalizedString(@"BB_TXTID_距", nil);
        _placeLabel.backgroundColor = [UIColor colorWithColorType:ColorType_OriginColor];
    }
    _distanceLabel.text = name;
    
    [_placeLabel sizeToFit];
    [_distanceLabel sizeToFit];
    
    _placeLabel.width = _placeLabel.width + _size_S(16);
    
    _distanceLabel.height = _placeLabel.height = _placeLabel.height + _size_S(0);
    _placeLabel.layer.cornerRadius = _placeLabel.height/2;
    _placeLabel.layer.masksToBounds = YES;
}

- (void)setAnswerNumber:(NSInteger)number
{
    NSString* string = [NSString stringWithFormat:@"%zd 回复",number];
    _ansNumLabel.text = string;
    [_ansNumLabel sizeToFit];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    // Configure the view for the selected state
}

- (void)didPressedUpvoteBtn
{
    if ([_postModel.likeFlag integerValue]) {
        return;
    }
    if (_upvoteArea.selected == YES) {
        return;
    }
    _upvoteArea.selected = YES;
    
    [self voteQuestionOpt:0 like:1];
}

- (void)didPressedDownvoteBtn
{
    if ([_postModel.likeFlag integerValue]) {
        return;
    }
    if (_downvoteArea.selected == YES) {
        return;
    }
    _downvoteArea.selected = YES;
    
    [self voteQuestionOpt:0 like:2];
}

- (void)voteQuestionOpt:(NSInteger)ansId like:(NSInteger)likeOrNot
{
    DPQuestionModel* tmpModel = _postModel;
    if (likeOrNot == 1) {
        tmpModel = [[DPQuestionUpdateService shareInstance] updateDemandedQuestion:_postModel.questId countType:DPCountSrcType_Upvotes];
    }else if(likeOrNot == 2) {
        tmpModel = [[DPQuestionUpdateService shareInstance] updateDemandedQuestion:_postModel.questId countType:DPCountSrcType_Downvotes];
    }
    [self setPostContentModel:tmpModel];
    
    [[DPHttpService shareInstance] excuteCmdToVoteQuestion:_postModel.questId ansId:ansId like:likeOrNot];
}

- (void)displaySubViews
{
    _contentView.width = self.width - COLOR_AREA_WIDTH;
    
    _colorArea.right = self.width;
    _colorArea.height = self.height;
    
    [_touchAccessoryView setFrame:_contentView.frame];
    
    _placeLabel.left = _size_S(16);
    _distanceLabel.left = _placeLabel.right + _size_S(8);
    _ansNumLabel.right = _contentView.right - _size_S(16);
    
    _placeLabel.top = _distanceLabel.top = _ansNumLabel.top = _contentView.bottom + _size_S(14);
    
    DPListStyleReplyView* reply = (DPListStyleReplyView*)[self findSubview:@"DPListStyleReplyView" resursion:YES];
    if (reply) {
        reply.bottom = self.height - _size_S(30);
        [self bringSubviewToFront:reply];
    }
    
    [self bringSubviewToFront:_colorArea];
    
    _bottomTouchView.hidden = _messageButton.hidden = _upvoteArea.hidden = _downvoteArea.hidden = (ListStyleViewState_Close == _contentState);
    _upvoteArea.left = _placeLabel.left;
    _downvoteArea.left = _upvoteArea.right + _size_S(10);
    _messageButton.right = _contentView.right - _size_S(13);
    _messageButton.bottom = _upvoteArea.bottom = _downvoteArea.bottom = self.height - _size_S(6);
    _bottomTouchView.bottom = self.height;
    
    [self insertSubview:_bottomTouchView belowSubview:_colorArea];
    [self insertSubview:_upvoteArea aboveSubview:_bottomTouchView];
    [self insertSubview:_downvoteArea aboveSubview:_bottomTouchView];
    [self insertSubview:_messageButton aboveSubview:_bottomTouchView];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    [self displaySubViews];
}

- (void)addBottomViews
{
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
    
    downNormal = LOAD_ICON_USE_POOL_CACHE(@"bb_reply_gray.png");
    downSelected = LOAD_ICON_USE_POOL_CACHE(@"bb_reply_white.png");
    _messageButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _messageButton.backgroundColor = [UIColor clearColor];
    _messageButton.contentMode = UIViewContentModeScaleAspectFit;
    [_messageButton setFrame:CGRectMake(0, 0, _size_S(32), _size_S(26))];
    [_messageButton setImage:downNormal forState:UIControlStateNormal];
    [_messageButton setImage:downSelected forState:UIControlStateHighlighted];
    [_messageButton addTarget:self action:@selector(didClickMessageButton) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_messageButton];
    
    [self addSubview:self.bottomTouchView];
}

- (void)setModelInPosition:(NSInteger)modelInPosition
{
    _modelInPosition = modelInPosition;
    if (modelInPosition%2) {
        _contentView.backgroundColor = [UIColor colorWithColorType:ColorType_MediumGray];
    }else{
        _contentView.backgroundColor = [UIColor colorWithColorType:ColorType_WhiteBg];
    }
    self.backgroundColor = _contentView.backgroundColor;
    switch (modelInPosition%3) {
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
    
    if ([DPListStyleReplyView shareInstance].superview == self) {
        if (_modelInPosition != [DPListStyleReplyView shareInstance].dankuIndex) {
            [[DPListStyleReplyView shareInstance] resetReplyView];
            [[DPListStyleReplyView shareInstance] removeFromSuperview];
        }
    }
}

- (void)setContentState:(ListStyleViewState)contentState
{
    if (contentState == ListStyleViewState_Open) {
        [self openReplyViewOpt];
    }
    _contentState = contentState;
}

- (void)openReplyViewOpt
{
    if ([DPListStyleReplyView shareInstance].superview != self) {
        [[DPListStyleReplyView shareInstance] resetReplyView];
        [[DPListStyleReplyView shareInstance] removeFromSuperview];
        [self addSubview:[DPListStyleReplyView shareInstance]];
    }else if ([DPListStyleReplyView shareInstance].animating){
        return;
    }
    [DPListStyleReplyView shareInstance].dankuIndex = _modelInPosition;
    
    if (_postModel.ansNum == 0) {
        //没有回复，提示
        [[DPListStyleReplyView shareInstance] setInformationType:INFOTYPE_EMPTY];
    }else{
        [[DPListStyleReplyView shareInstance] setInformationType:INFOTYPE_PROGRESS];
        [[DPLocalDataManager shareInstance] getPostReplyList:_postModel.questId completion:^(NSError *error, NSArray *result) {
            if (error == nil && [result count]) {
                DPTrace("加载到现有的反馈数据 %zd 条",[result count]);
                [[DPListStyleReplyView shareInstance] removeInformationLabelWithAnimate:YES];
                [[DPListStyleReplyView shareInstance] appendDatasource:result];
            }else{
                DPTrace("附近页面加载回答数据： %@ ， count: %@", error, result);
            }
        }];
    }
}

- (void)didClickBottomTouchView
{
    if (_delegate && [_delegate respondsToSelector:@selector(cellDidClickBottomAcessoryView:)]) {
        [_delegate cellDidClickBottomAcessoryView:_modelInPosition];
    }
}

- (void)didClickMessageButton
{
    if (_delegate && [_delegate respondsToSelector:@selector(cellDidClickMessageButton:)]) {
        [_delegate cellDidClickMessageButton:_modelInPosition];
    }
}

- (void)closeReplyViewOpt
{
    [[DPListStyleReplyView shareInstance] resetReplyView];
    [[DPListStyleReplyView shareInstance] removeFromSuperview];
}

#pragma mark -
- (void)setPostContentModel:(id)model
{
    self.postModel = model;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        //请求加载回复列表
        [[DPAnswerUpdateService shareInstance] forceToUpdateAnswerList:_postModel.questId demandedCount:_postModel.ansNum];
    });
    [_contentView setNickText:_postModel.sign contentText:_postModel.quest];
    _contentView.height = [DPListStyleContentView cellHeightForContentText:_postModel.quest];
    
    [self setAnswerNumber:_postModel.ansNum];
    
    //特殊标识
    if ([_postModel.isCreator integerValue] == 1 || [_postModel.opType integerValue] == 2) {
        [_contentView highlightContent:YES];
    }else{
        [_contentView highlightContent:NO];
    }
    
    [_upvoteArea setMessageText:[NSString stringWithFormat:@"%zd",_postModel.likeNum]];
    [_downvoteArea setMessageText:[NSString stringWithFormat:@"%zd",_postModel.unlikeNum]];
    [_upvoteArea setSelected:[_postModel.likeFlag integerValue] == 1];
    [_downvoteArea setSelected:[_postModel.likeFlag integerValue] == 2];
    
    NSInteger dist = [_postModel.distance integerValue];
    if (dist < 3) {
        [self setPtType:SociatyType_Public ptName:@"< 3 km"];
    }else{
        [self setPtType:SociatyType_Public ptName:[NSString stringWithFormat:@"%zd km",dist]];
    }
}

- (void)dealloc
{
    self.upvoteArea = nil;
    self.downvoteArea = nil;
}

#pragma mark -
+ (CGFloat)cellHeightForContentText:(NSString*)content
{
    return [DPListStyleContentView cellHeightForContentText:content]+ _size_S(38);
}

@end
