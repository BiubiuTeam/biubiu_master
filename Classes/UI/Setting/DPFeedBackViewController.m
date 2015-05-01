//
//  DPFeedBackViewController.m
//  BiuBiu
//
//  Created by haowenliang on 14/12/23.
//  Copyright (c) 2014年 dpsoft. All rights reserved.
//

#import "DPFeedBackViewController.h"
#import "DPCommentTextField.h"
#import "OBaconView.h"
#import "OBaconViewItem.h"
#import "DPHttpService.h"
#import "BackSourceInfo_3002.h"
#import <MBProgressHUD.h>
#import "DPShortNoticeView.h"
#import "DPInternetService.h"

@interface FeebBackContent : OBaconViewItem
@property (nonatomic, strong) UILabel *itemLabel;
@end

@implementation FeebBackContent
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // text label
        _itemLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _itemLabel.width = SCREEN_WIDTH;
        _itemLabel.backgroundColor = [UIColor clearColor];
        _itemLabel.textAlignment = NSTextAlignmentCenter;
        _itemLabel.font = [DPFont systemFontOfSize:FONT_SIZE_MIDDLE];
        
        _itemLabel.textColor = RGBACOLOR(0x66, 0x66, 0x66, 1);
        _itemLabel.numberOfLines = 0;
        
        
        self.backgroundColor = RGBACOLOR(0xff, 0xff, 0xff, 0.7);
        self.layer.cornerRadius = 5;
        self.layer.masksToBounds = YES;
        
        [self addSubview:_itemLabel];
    }
    return self;
}

- (void)dealloc
{
    DPTrace("反馈数据Cell销毁");
}

- (void)setContentText:(NSString*)content
{
    [_itemLabel setText:content];
    [_itemLabel sizeToFit];
    
    self.size = CGSizeMake(_itemLabel.width + _size_S(20),_itemLabel.height + _size_S(16));
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    _itemLabel.center = CGPointMake(self.width/2, self.height/2);
}

@end

@interface DPFeedBackViewController ()<DPCommentTextFieldProtocol,UIScrollViewDelegate,OBaconViewDataSource, OBaconViewDelegate>{
    
    OBaconView *_feedsBaconView;

    CGFloat textFieldOrignY;
}
@property (nonatomic, strong) NSMutableArray* feedbacks;

@property (nonatomic, strong) MBProgressHUD* HUD;
@property (nonatomic, strong) UIImageView* centerBiubiu;
@property (nonatomic, strong) UIImageView* bottomCloud;

@property (nonatomic, strong) DPCommentTextField* replyField;

@property (nonatomic, weak) DPFeedBackViewController* weakSelf;

@property (nonatomic, strong) OBaconView* feedsBaconView;
@end


@implementation DPFeedBackViewController

- (BOOL)isSupportLeftDragBack
{
    return NO;
}

- (void)initHUD
{
    if (nil == _HUD) {
        //初始化进度框，置于当前的View当中
        _HUD = [[MBProgressHUD alloc] initWithView:[[UIApplication sharedApplication] keyWindow]];
        //如果设置此属性则当前的view置于后台
        _HUD.dimBackground = NO;
        _HUD.removeFromSuperViewOnHide = YES;
    }
    if (_HUD.superview && _HUD.superview != self.view) {
        [_HUD removeFromSuperview];
    }
    [self.view addSubview:_HUD];
}

- (void)hideLoading
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(hideLoading) object:nil];;
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(showLoadingView:) object:nil];;
    if (_HUD) {
        [_HUD hide:YES];
    }
}

- (void)showLoadingView:(NSString*)message
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(showLoadingView:) object:nil];;
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(hideLoading) object:nil];;
    
    [self performSelector:@selector(hideLoading) withObject:nil afterDelay:10];
    
    [self initHUD];
    //设置对话框文字
    _HUD.labelText = message;
    _HUD.mode = MBProgressHUDModeIndeterminate;
    
    //显示对话框
    [_HUD show:YES];
}

- (void)dealloc
{
    DPTrace("反馈页面销毁");
    self.HUD = nil;
    self.feedsBaconView = nil;
    _replyField.delegate = nil;
    self.weakSelf = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self updateFeedBackList];
}

- (void)updateFeedBackList
{
    DPTrace("请求反馈数据");
    [[DPHttpService shareInstance] downloadFeedbacksWithCompletion:^(id feedbackList, JSONModelError *err) {
        DPTrace("加载到现有的反馈数据 %zd 条",[feedbackList count]);
        [_weakSelf.feedbacks removeAllObjects];
        [_weakSelf.feedbacks addObjectsFromArray:feedbackList];
        [_weakSelf.feedbacks addObjectsFromArray:feedbackList];
        [_weakSelf.feedbacks addObjectsFromArray:feedbackList];
        [_weakSelf.feedsBaconView reloadData];
    }];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onFeedbackOptResponse:) name:kNotification_FeedbackPost object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillChangeFrameNotification object:nil];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    _feedsBaconView.delegate = nil;
    _feedsBaconView.dataSource = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    _feedbacks = [[NSMutableArray alloc] initWithCapacity:1];
    self.weakSelf = self;
    self.view.backgroundColor = [UIColor colorWithColorType:ColorType_BlueTxt];
    
    [self resetBackBarButtonWithImage];
    self.title = NSLocalizedString(@"BB_TXTID_用户反馈", @"");
    
    UIImage* logo = LOAD_ICON_USE_POOL_CACHE(@"bb_feedback_icon.png");
    _centerBiubiu = [[UIImageView alloc] initWithImage:logo];
    _centerBiubiu.size = CGSizeMake(screenScale()*logo.size.width, screenScale()*logo.size.height);
    _centerBiubiu.center = CGPointMake(self.view.width/2, (_centerBiubiu.height + _size_S(140))/2);
    [self.view addSubview:_centerBiubiu];
    
    UIImage* cloud = LOAD_ICON_USE_POOL_CACHE(NSLocalizedString(@"BB_SRCID_FeedbacCloud", nil));
    _bottomCloud = [[UIImageView alloc] initWithImage:cloud];
    _bottomCloud.width = SCREEN_WIDTH;
    _bottomCloud.height = cloud.size.height * SCREEN_WIDTH/cloud.size.width;
    [self.view addSubview:_bottomCloud];
    
    CGRect tbframe = [self.view bounds];
    tbframe.size.height -= [self getNavStatusBarHeight];
    _replyField = [[DPCommentTextField alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
    [_replyField resetPlaceHolder: NSLocalizedString(@"BB_TXTID_写下您的建议", @"") editingPlaceHolder: NSLocalizedString(@"BB_TXTID_写下您的建议", @"")];
    
    _replyField.center = CGPointMake(_replyField.center.x, (tbframe.size.height - _replyField.height/2.0f));
    _replyField.delegate = self;
    [self.view addSubview:_replyField];
    textFieldOrignY = _replyField.frame.origin.y;
    _bottomCloud.bottom = _replyField.top;
    
    // init bacon View
    _feedsBaconView = [[OBaconView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, _bottomCloud.top)];
    _feedsBaconView.animationDirection = OBaconViewAnimationDirectionLeft;
    _feedsBaconView.dataSource = self;
    _feedsBaconView.delegate = self;
    _feedsBaconView.disableSwipGesture = YES;
    _feedsBaconView.animationTime = 4;
    [self.view addSubview:_feedsBaconView];
    
    [self.view bringSubviewToFront:_replyField];
    
    UITapGestureRecognizer* gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapScrollView)];
    [_feedsBaconView addGestureRecognizer:gesture];
    
    [self initHUD];
}

- (void)tapScrollView
{
    [_replyField resignFirstResponderEx];
}
#pragma mark -
- (void)onFeedbackOptResponse:(NSNotification*)notification
{
    [self hideLoading];
    NSDictionary* userInfo = [notification userInfo];
    if (userInfo && [userInfo count]) {
        NSInteger retCode = [[userInfo objectForKey:kNotification_StatusCode] integerValue];
        if (retCode == 0) {
            [DPShortNoticeView showTips:NSLocalizedString(@"BB_TXTID_感谢您真诚的反馈",nil) atRootView:self.view];
            [_replyField clearTextContent];
        }else{
            [DPShortNoticeView showTips:NSLocalizedString(@"BB_TXTID_反馈提交失败",nil) atRootView:self.view];
        }
    }
}

#pragma mark -Responding to keyboard events
- (void)keyboardWillShow:(NSNotification *)notification {
    NSDictionary *userInfo = [notification userInfo];
    NSValue* aValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect keyboardRect = [aValue CGRectValue];
    // Get the duration of the animation.
    NSValue *animationDurationValue = [userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSTimeInterval animationDuration;
    [animationDurationValue getValue:&animationDuration];
    // Animate the resize of the text view's frame in sync with the keyboard's appearance.
    [self moveInputBarWithKeyboardHeight:keyboardRect.size.height withDuration:animationDuration];
}

- (void)keyboardWillHide:(NSNotification *)notification {
    NSDictionary* userInfo = [notification userInfo];
    NSValue *animationDurationValue = [userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSTimeInterval animationDuration;
    [animationDurationValue getValue:&animationDuration];
    
    [self moveInputBarWithKeyboardHeight:0.0 withDuration:animationDuration];
}

- (void)moveInputBarWithKeyboardHeight:(CGFloat)height withDuration:(NSTimeInterval)duration
{
    _replyField.maxCommentTextFieldHeight = SCREEN_HEIGHT - [self getNavStatusBarHeight] - height;
    CGRect oldF = _replyField.frame;
    [UIView animateWithDuration:duration animations:^{
        _replyField.frame = CGRectMake(oldF.origin.x, textFieldOrignY - height, oldF.size.width, oldF.size.height);
        [_replyField setNeedsLayout];
    }];
}

#pragma mark -----------DPCommentTextField Protocol-----------
- (void)textFieldFrameChanged:(DPCommentTextField *)textField
{
    CGFloat visableHeight = self.view.height;
    CGFloat fieldY = visableHeight - _replyField.height;
    
    CGFloat value = fieldY - textFieldOrignY;
    CGRect oldF = _replyField.frame;
    oldF.origin.y += value;
    _replyField.frame = oldF;
    textFieldOrignY = fieldY;
}

- (void)textFieldDidSendText:(DPCommentTextField *)textField inputText:(NSString *)text
{
    if (![[DPInternetService shareInstance] networkEnable]) {
        DPTrace("网络不可用");
        [DPShortNoticeView showTips:NSLocalizedString(@"BB_TXTID_网络未连接，请确认网络连接是否正常",nil) atRootView:self.view];
        return;
    }
    NSString *trimmedString = [text stringByTrimmingCharactersInSet:
                               [NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if (trimmedString.length) {
        
        [[DPHttpService shareInstance] uploadFeedbackWithMessage:trimmedString];
        [textField resignFirstResponderEx];
        [self showLoadingView:NSLocalizedString(@"BB_TXTID_提交中...",nil)];
    }else{
        [DPShortNoticeView showTips:NSLocalizedString(@"BB_TXTID_反馈内容不能为空",nil) atRootView:self.view];
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [_replyField resignFirstResponderEx];
}

//=============================================================================
#pragma mark - baconView stuff

- (int) numberOfItemsInbaconView:(OBaconView *)baconView{
    DPTrace("反馈数据：%zd条",[_feedbacks count]);
    return (int)[_feedbacks count];
}

- (OBaconViewItem *) baconView:(OBaconView *)baconView viewForItemAtIndex:(int)index{
    static NSString *baconItemIdentifier = @"FeedBaconItem";
    
    // deque baconcell
    FeebBackContent *baconItem = (FeebBackContent *)[baconView dequeueReusableItemWithIdentifier:baconItemIdentifier];
    
    // create new one if it's nil
    if (baconItem == nil) {
        baconItem = [[FeebBackContent alloc] initWithFrame:CGRectZero];
    }
    
    // fill data
    if (index < [_feedbacks count]) {
        BackendContentData_3002* contentData = _feedbacks[index];
        NSString* string = [NSString stringWithFormat:@"%@", contentData.cont];
        NSString *trimmedString = [string stringByTrimmingCharactersInSet:
                                   [NSCharacterSet whitespaceAndNewlineCharacterSet]];
        trimmedString = [trimmedString stringByReplacingOccurrencesOfString:@"\n" withString:@" "];
        [baconItem setContentText:trimmedString];
    }
    
    baconItem.userInteractionEnabled = NO;
    return baconItem;
}

- (void) baconView:(OBaconView *)baconView didSelectItemAtIndex:(NSInteger)index{
    // show alert
    return;
}

@end
