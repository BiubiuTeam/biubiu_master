//
//  DPPublishViewController.m
//  BiuBiu
//
//  Created by haowenliang on 14/12/8.
//  Copyright (c) 2014年 dpsoft. All rights reserved.
//


#import "DPPublishViewController.h"
#import "DPTextView.h"
#import "DPRefreshLbsInfoView.h"
#import "DPSignUpTextField.h"
#import "DPLbsServerEngine.h"
#import "DPInternetService.h"
#import "DPHttpService.h"
#import "DPShortNoticeView.h"
#import "ProgressTool.h"
#import <MBProgressHUD/MBProgressHUD.h>

#define LBS_VIEW_DEFAULT_HEIGHT _size_S(33)

#define SIGN_UP_VIEW_DEFAULT_HEIGHT _size_S(44)
#define SIGN_UP_VIEW_BOTTOM _size_S(16)
#define SIGN_UP_VIEW_RIGHT _size_S(22)

#define CONTENT_VIEW_MARING_X _size_S(10)
#define CONTENT_VIEW_MARING_Y _size_S(15)

#define CONTENT_VIEW_TEXT_COLOR (RGBACOLOR(0x33, 0x33, 0x33, 1))

@interface DPPublishViewController ()<UITextViewDelegate,DPSignUpTextFieldProtocol>
{
    DPRefreshLbsInfoView* _accessoryView;
    DPRefreshLbsInfoView* _bottomView;
    DPSignUpTextField* _signUp;
    
    MBProgressHUD* _HUD;
    
    NSInteger _currentPoiIndex;
}
@property (nonatomic, strong) BMKPoiInfo* curInfo;
@property (nonatomic, strong) MBProgressHUD* HUD;
@property (nonatomic, strong) DPTextView* textView;
@property (nonatomic, strong) DPSignUpTextField* signUp;
@property (nonatomic, strong) NSString* addrInfo;
@property (nonatomic, weak) DPPublishViewController* weakSelf;

@property (nonatomic, strong) UILabel* wordCountLabel;
@end

@implementation DPPublishViewController

- (instancetype)initWithCurUnionId:(NSInteger)unionId questionType:(QuestionType)type
{
    if (self = [super init]) {
        _currentPoiIndex = 0;
        _curUnionId = unionId;
        _qustionType = type;
    }
    return self;
}

- (instancetype)init
{
    if (self = [super init]) {
        _currentPoiIndex = 0;
        _curUnionId = 0;
        _qustionType = QuestionType_Nearby;
    }
    return self;
}

- (UILabel *)wordCountLabel
{
    if (nil == _wordCountLabel) {
        _wordCountLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _wordCountLabel.backgroundColor = [UIColor clearColor];
        _wordCountLabel.font = [DPFont systemFontOfSize:FONT_SIZE_MIDDLE];
        _wordCountLabel.textColor = [UIColor colorWithColorType:ColorType_LightTxt];
        _wordCountLabel.textAlignment = NSTextAlignmentCenter;
        _wordCountLabel.left = SIGN_UP_VIEW_RIGHT;
        _wordCountLabel.text = @"200/200";
        [_wordCountLabel sizeToFit];
    }
    return _wordCountLabel;
}

- (void)dealloc
{
    DPTrace("发表页面释放");
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    self.HUD = nil;
    [_textView resignAllFirstResponder];
    [_signUp resignAllFirstResponder];
    self.textView = nil;
    self.signUp = nil;
    self.addrInfo = nil;
    self.weakSelf = nil;
}

- (BOOL)isSupportLeftDragBack
{
    return NO;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    _currentPoiIndex = 0;
    // Do any additional setup after loading the view.
    [self.view setBackgroundColor:[UIColor colorWithColorType:ColorType_WhiteBg]];
    
    self.title = NSLocalizedString(@"BB_TXTID_说点儿啥",nil);
    [self resetTextRightButtonWithTitle:NSLocalizedString(@"BB_TXTID_发表",nil) andSel:@selector(postBiuBiuOpt)];
    
    [self resetBackBarButtonWithImage];
    
    [self.view addSubview:self.wordCountLabel];
    [self makeTextView];
    [self makeSignUpField];
    [self makeAccessoryView];
    
    [[DPLbsServerEngine shareInstance] forceToUpdateLocation];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidShow:) name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
    [self hideLoadingAndResetResponder:YES];
    
    self.weakSelf = self;
    if ([[DPLbsServerEngine shareInstance] isEnabledAndAuthorize]) {
        self.curInfo = [[DPLbsServerEngine shareInstance] getPoiInfoAtIndex:_currentPoiIndex];
        [self setLbsInfo:_curInfo.name];
    }else{
        [DPShortNoticeView showTips:NSLocalizedString(@"BB_TXTID_需要开启定位服务，允许biubiu的请求",nil) atRootView:self.view];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    if (_HUD) {
        [self hideLoadingAndResetResponder:NO];
    }
}

- (void)postBiuBiuOpt
{
    self.navigationItem.rightBarButtonItem.enabled = NO;
    if (![[DPInternetService shareInstance] networkEnable]) {
        DPTrace("网络不可用");
        [DPShortNoticeView showTips:NSLocalizedString(@"BB_TXTID_网络未连接，请确认网络连接是否正常",nil) atRootView:self.view];
        self.navigationItem.rightBarButtonItem.enabled = YES;
        return;
    }
    if ([[DPLbsServerEngine shareInstance] isEnabledAndAuthorize] == NO) {
        DPTrace("定位服务不可用");
        [DPShortNoticeView showTips:NSLocalizedString(@"BB_TXTID_需要开启定位服务，允许biubiu的请求",nil) atRootView:self.view];
        self.navigationItem.rightBarButtonItem.enabled = YES;
        return;
    }
    
    NSString* content = [_textView.text copy];
    NSString *trimmedString = [content stringByTrimmingCharactersInSet:
                               [NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if (![trimmedString length] || [trimmedString length] < 5) {
        DPTrace("问题内容字数不够");
        [DPShortNoticeView showTips:NSLocalizedString(@"BB_TXTID_问题内容字数不能少于5个字",nil) atRootView:self.view];
        self.navigationItem.rightBarButtonItem.enabled = YES;
        return;
    }
    __block NSString* sign = [[_signUp currentWrittenName] copy];
    [_signUp rememberUserInput];
    CLLocationCoordinate2D location = self.curInfo.pt;
    float latitude = location.latitude * 1000000;
    float longitude = location.longitude * 1000000;
    [[DPHttpService shareInstance] excutePublishedCmd:trimmedString latitude:latitude logitude:longitude signiture:sign location:_addrInfo questType:_qustionType unionId:_curUnionId];
    
    [self performSelector:@selector(showLoadingView) withObject:nil afterDelay:0.3];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kNotification_NewPostCallBack object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onPostCallBack:) name:kNotification_NewPostCallBack object:nil];
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
    [self hideLoadingAndResetResponder:YES];
}

- (void)showLoadingView
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(showLoadingView) object:nil];

    [self initHUD];
    //设置对话框文字
    _HUD.labelText = NSLocalizedString(@"BB_TXTID_正在努力发表中...",nil);
    _HUD.mode = MBProgressHUDModeIndeterminate;
    
    [_textView resignFirstResponder];
    [_signUp resignAllFirstResponder];
    //显示对话框
    [_HUD show:YES];
}

- (void)hideLoadingAndResetResponder:(BOOL)reset
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(showLoadingView) object:nil];
    if (reset) {
        [_textView becomeFirstResponder];
    }
    if (_HUD) {
        [_HUD hide:YES];
    }
}

- (void)popViewController
{
    [self hideLoadingAndResetResponder:NO];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)onPostCallBack:(NSNotification*)notification
{
    NSDictionary* userInfo = notification.userInfo;
    NSInteger retCode = [[userInfo objectForKey:kNotification_StatusCode] integerValue];
    if (retCode == 0) {
        [self popViewController];
    }else{
        [self hideLoadingAndResetResponder:YES];
        [DPShortNoticeView showTips:NSLocalizedString(@"BB_TXTID_发表失败",nil) atRootView:self.view];
    }
    self.navigationItem.rightBarButtonItem.enabled = YES;
}
#pragma mark -public methods

- (void)setLbsInfo:(NSString*)info
{
    self.addrInfo = info;
    [_accessoryView updateLbsInformationWithText:info];
    [_bottomView updateLbsInformationWithText:info];
}

#pragma mark - make up ui contents
- (void)makeTextView
{
    CGRect tvframe = self.view.bounds;
    tvframe.origin.y = CONTENT_VIEW_MARING_Y;
    tvframe.origin.x = CONTENT_VIEW_MARING_X;
    tvframe.size.height = tvframe.size.height - LBS_VIEW_DEFAULT_HEIGHT;
    tvframe.size.width = tvframe.size.width - CONTENT_VIEW_MARING_X*2;
    
    _textView = [[DPTextView alloc] initWithFrame:tvframe];
    _textView.backgroundColor = [UIColor clearColor];
    if(_qustionType == QuestionType_Nearby){
        _textView.defaultPlaceholder = NSLocalizedString(@"BB_TXTID_说点儿啥～", nil);
        _textView.editingPlaceholder = NSLocalizedString(@"BB_TXTID_说点儿啥～", nil);
    }else if(_qustionType == QuestionType_Union){
        _textView.defaultPlaceholder = NSLocalizedString(@"BB_TXTID_版块内发表引导词", nil);
        _textView.editingPlaceholder = NSLocalizedString(@"BB_TXTID_版块内发表引导词", nil);
    }
    _textView.countLabel = self.wordCountLabel;
    _textView.delegate = self;
    _textView.textColor = CONTENT_VIEW_TEXT_COLOR;
    _textView.font = [DPFont systemFontOfSize:FONT_SIZE_LARGE];
    _textView.editable = YES;
    [self.view addSubview:_textView];
    
    [_textView dpTextDidChanged:nil];
}

- (void)makeSignUpField
{
    _signUp = [[DPSignUpTextField alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SIGN_UP_VIEW_DEFAULT_HEIGHT)];
    _signUp.delegate = self;
    _signUp.backgroundColor = [UIColor clearColor];
    _signUp.right = CGRectGetWidth(self.view.bounds) - SIGN_UP_VIEW_RIGHT;
    [self.view addSubview:_signUp];
}

- (void)makeAccessoryView
{
    _accessoryView= [[DPRefreshLbsInfoView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, LBS_VIEW_DEFAULT_HEIGHT)];
    _accessoryView.backgroundColor = [UIColor colorWithColorType:ColorType_Seperator];
    _textView.inputAccessoryView = _accessoryView;
    [_signUp setTextFieldInputAccessoryView:_accessoryView];
    
    _bottomView= [[DPRefreshLbsInfoView alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(self.view.bounds) - LBS_VIEW_DEFAULT_HEIGHT, SCREEN_WIDTH, LBS_VIEW_DEFAULT_HEIGHT)];
    _bottomView.backgroundColor = [UIColor colorWithColorType:ColorType_Seperator];
    [self.view addSubview:_bottomView];
    
    [_accessoryView addTarget:self action:@selector(refreshPoiAddress) forControlEvents:UIControlEventTouchUpInside];
    [_bottomView addTarget:self action:@selector(refreshPoiAddress) forControlEvents:UIControlEventTouchUpInside];
}

- (void)refreshPoiAddress
{
    if ([[DPLbsServerEngine shareInstance] isEnabledAndAuthorize]) {
        ++_currentPoiIndex;
        self.curInfo = [[DPLbsServerEngine shareInstance] getPoiInfoAtIndex:_currentPoiIndex];
        [self setLbsInfo:_curInfo.name];
    }else{
        [DPShortNoticeView showTips:NSLocalizedString(@"BB_TXTID_需要开启定位服务，允许biubiu的请求",nil) atRootView:self.view];
    }
}

#pragma mark -dp textfield delegate
- (void)resignAllResponder:(DPSignUpTextField *)field
{
    [_textView becomeFirstResponder];
}

- (void)textDidChanged:(DPSignUpTextField *)field text:(NSString *)string
{
    _signUp.right = CGRectGetWidth(self.view.bounds) - SIGN_UP_VIEW_RIGHT;
}
#pragma mark -keyboard notification
- (void)keyboardWillShow:(NSNotification*)notification
{
    NSDictionary *userInfo = [notification userInfo];
    NSValue* aValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect keyboardRect = [aValue CGRectValue];
    // Get the duration of the animation.
    NSValue *animationDurationValue = [userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSTimeInterval animationDuration;
    [animationDurationValue getValue:&animationDuration];

    [UIView animateWithDuration:animationDuration animations:^{
        _textView.height = self.view.height - keyboardRect.size.height - 15;
        [_textView setNeedsDisplay];
        _wordCountLabel.bottom = _signUp.bottom = CGRectGetMaxY(_textView.frame) - SIGN_UP_VIEW_BOTTOM;
    }];
}

- (void)keyboardDidShow:(NSNotification*)notification
{
    
}

- (void)keyboardWillHide:(NSNotification*)notification
{
    [self.view bringSubviewToFront:_bottomView];
    NSDictionary* userInfo = [notification userInfo];
    NSValue *animationDurationValue = [userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSTimeInterval animationDuration;
    [animationDurationValue getValue:&animationDuration];

    [UIView animateWithDuration:animationDuration animations:^{
        _textView.height = self.view.height - _bottomView.height - 15;
        _bottomView.top = CGRectGetMaxY(_textView.frame);
        [_textView setNeedsDisplay];
        
        _wordCountLabel.bottom = _signUp.bottom = CGRectGetMaxY(_textView.frame) - SIGN_UP_VIEW_BOTTOM;
    }];
}

#pragma mark -textview delegate

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
    return YES;
}

#pragma mark -

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
//    if ([text isEqualToString:@"\n"]) {
//        return NO;
//    }
    if(textView.markedTextRange || ![text length]){
        return YES;
    }
    
    if (range.length >= [text length]) {
        return YES;
    }
    
    if([textView isKindOfClass:[DPTextView class]]){
        DPTextView* post = (DPTextView*)textView;
        NSInteger more = [text length] - range.length;
        
        if (post.inputCount + more > post.maxCount) {
            return NO;
        }
    }
    return YES;
}

- (void)textViewDidChange:(UITextView *)textView
{
    if (textView.markedTextRange) {
        return;
    }
    if([textView isKindOfClass:[DPTextView class]]){
        DPTextView* post = (DPTextView*)textView;
        NSString* text = textView.text;
        if ([text length] > post.maxCount) {
            textView.text = [text substringToIndex:post.maxCount];
        }
    }
}

@end
