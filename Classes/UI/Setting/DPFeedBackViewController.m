//
//  DPFeedBackViewController.m
//  BiuBiu
//
//  Created by haowenliang on 14/12/23.
//  Copyright (c) 2014年 dpsoft. All rights reserved.
//

#import "DPFeedBackViewController.h"
#import "DPCommentTextField.h"
#import "AnimateLabel.h"

#import "DPHttpService.h"
#import "BackSourceInfo_3002.h"
#import <MBProgressHUD.h>
#import "DPShortNoticeView.h"
#import "DPInternetService.h"

static int DanKuLines = 10;

@interface DPFeedBackViewController ()<DPCommentTextFieldProtocol,UIScrollViewDelegate>{
    CGFloat textFieldOrignY;

    NSInteger _colorType;
    NSInteger _loopTime;
    NSInteger _loopRow;
    float* dankuLineLength;
    BOOL _runningLoop;
}
@property (nonatomic, strong) NSMutableArray* positionArray;


@property (nonatomic, strong) NSMutableArray* feedbacks;

@property (nonatomic, strong) MBProgressHUD* HUD;
@property (nonatomic, strong) UIImageView* centerBiubiu;
@property (nonatomic, strong) UIImageView* bottomCloud;

@property (nonatomic, strong) DPCommentTextField* replyField;

@property (nonatomic, weak) DPFeedBackViewController* weakSelf;

@property (nonatomic, strong) UIView* feedsBaconView;
@end


@implementation DPFeedBackViewController

- (BOOL)isSupportLeftDragBack
{
    return NO;
}

- (UIView *)feedsBaconView
{
    if (nil == _feedsBaconView) {
        _feedsBaconView = [[UIView alloc] initWithFrame:self.view.bounds];
        _feedsBaconView.backgroundColor = [UIColor clearColor];
    }
    return _feedsBaconView;
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
        [_weakSelf setup];
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
    [self resetDankuView];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    dankuLineLength = (float *)malloc(DanKuLines * sizeof(float));
    
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
    
    [self.view addSubview:self.feedsBaconView];
    
    CGRect tbframe = [self.view bounds];
    tbframe.size.height -= [self getNavStatusBarHeight];
    _replyField = [[DPCommentTextField alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
    [_replyField resetPlaceHolder: NSLocalizedString(@"BB_TXTID_写下您的建议", @"") editingPlaceHolder: NSLocalizedString(@"BB_TXTID_写下您的建议", @"")];
    
    _replyField.center = CGPointMake(_replyField.center.x, (tbframe.size.height - _replyField.height/2.0f));
    _replyField.delegate = self;
    [self.view addSubview:_replyField];
    textFieldOrignY = _replyField.frame.origin.y;
    _bottomCloud.bottom = _replyField.top;
    
    [self.view bringSubviewToFront:_replyField];
    
    [self initHUD];
    
    _feedsBaconView.height = _bottomCloud.centerY;
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

#pragma mark -

- (UIColor*)randomColor:(NSInteger)type
{
    UIColor* color = [UIColor blackColor];
    type = type + _loopTime + _loopRow;
    switch (type%DanKuLines) {
        case 0:
            color = RGBACOLOR(0x79,0x93,0xdf,1);//[UIColor colorWithColorType:ColorType_Green];
            break;
        case 1:
            color = RGBACOLOR(0x57,0x87,0x42,1);//[UIColor colorWithColorType:ColorType_Pink];
            break;
        case 2:
            color = RGBACOLOR(0xb2,0x36,0x36,1);//[UIColor colorWithColorType:ColorType_Yellow];
            break;
        default:
            color = [UIColor colorWithColorType:ColorType_WhiteTxt];
            break;
    }
    return color;
}

- (UIFont*)randomFont:(NSInteger)type
{
    type += (_loopRow + _loopTime)%7;
    return [UIFont systemFontOfSize:(13+type)];
}

- (NSMutableArray *)positionArray
{
    if (nil == _positionArray) {
        _positionArray = [NSMutableArray new];
    }
    return _positionArray;
}

- (CGFloat)getRandomOffsetY:(NSInteger)index
{
    CGFloat yoffset = 0;
    yoffset = (index%DanKuLines) * (_feedsBaconView.height/DanKuLines);
    return yoffset;
}

- (CGFloat)getRandomOffsetX:(NSInteger)index withWidth:(CGFloat)twidth
{
    float with = dankuLineLength[index%DanKuLines];
    dankuLineLength[index%DanKuLines] = with + twidth;
    
    return with + random()%20;
}

- (void)resetDankuView
{
    _runningLoop = NO;
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(setup) object:nil];
    _loopTime = 0;
    NSArray* subviews = _feedsBaconView.subviews;
    for (UIView* view in subviews) {
        if ([view isKindOfClass:[AnimateLabel class]]) {
            [(AnimateLabel*)view disappearFromSuperview];
        }
    }
    self.feedbacks = nil;
}

- (void)setup
{
    @synchronized(self){
        if (_runningLoop) {
            return;
        }
        _runningLoop = YES;
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(setup) object:nil];
        
        NSMutableArray* biubiu = [_feedbacks mutableCopy];
        while ([biubiu count] < DanKuLines) {
            [biubiu addObjectsFromArray:[_feedbacks copy]];
        }
        _loopRow = 0;
        for (int i = 0; i < DanKuLines; i++) {
            dankuLineLength[i] = SCREEN_WIDTH;
        }
        for (NSInteger index = 0; index < biubiu.count; index++) {
            if(_runningLoop == NO){
                //强制停止循环
                return;
            }
            
            if (index%DanKuLines == 0) {
                _loopRow++;
            }
            
            BackendContentData_3002* contentData = biubiu[index];
            NSString* string = [NSString stringWithFormat:@"%@", contentData.cont];
            NSString *trimmedString = [string stringByTrimmingCharactersInSet:
                                       [NSCharacterSet whitespaceAndNewlineCharacterSet]];
            trimmedString = [trimmedString stringByReplacingOccurrencesOfString:@"\n" withString:@" "];
            
            AnimateLabel* label = [[AnimateLabel alloc] initWithFrame:CGRectZero];
            label.backgroundColor = [UIColor clearColor];
            label.text = trimmedString;
            
            
            NSInteger randomInt = rand()%8;
            label.font = [self randomFont:randomInt];
            label.textColor = [self randomColor:randomInt];
            
            [label sizeToFit];
            [_feedsBaconView addSubview:label];
            
            //在开始动画前，需要设置起始位置
            CGFloat width = [self widthOfString:trimmedString withFont:label.font];
            label.left = [self getRandomOffsetX:(index+2*_loopTime) withWidth:width];
            label.top = [self getRandomOffsetY:(index+2*_loopTime)];
            
            [label startAnimation];
        }
        _loopTime++;
        
        //计算下次启动的时间
        CGFloat maxWith = 0;
        for (int i = 0; i < DanKuLines; i++) {
            maxWith += dankuLineLength[i];
        }
        int time = MAX(5,abs((maxWith/DanKuLines-SCREEN_WIDTH)/(1.2*60)));
        
        _runningLoop = NO;
        [self performSelector:@selector(setup) withObject:nil afterDelay:time];
    }
}

- (CGFloat)widthOfString:(NSString *)string withFont:(UIFont *)font {
    NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:font, NSFontAttributeName, nil];
    return [[[NSAttributedString alloc] initWithString:string attributes:attributes] size].width;
}
@end
