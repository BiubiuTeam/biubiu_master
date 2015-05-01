//
//  DPUnionCreateViewController.m
//  biubiu
//
//  Created by haowenliang on 15/3/24.
//  Copyright (c) 2015年 dpsoft. All rights reserved.
//

/*
 *  需要的控件
 *  1，拍照按钮btn 2，label 3，textfield 4,lbsinfo btn 5,btn 6,label
 *
*/
#import "DPUnionCreateViewController.h"
#import "DPLbsInformationView.h"

#import "DPLbsServerEngine.h"
#import "DPShortNoticeView.h"
#import "DPHttpService+Sociaty.h"
#import <MobileCoreServices/UTCoreTypes.h>
#import <AVFoundation/AVFoundation.h>
#import <objc/runtime.h>
#import "DPPhotoUploader.h"
#import "DPBaseUploadMgr.h"

//接入新的定位控件
#import "DPLbsServerEngine.h"

#define CreatorMarginTop _size_S(26)
#define CreatorPhotoDiameter _size_S(86)

#define CreatorMarginTop1 _size_S(14)
#define CreatorMarginTop2 _size_S(26)
#define CreatorMarginTop3 _size_S(16)
#define CreatorMarginTop4 _size_S(32)
#define CreatorMarginTop5 _size_S(13)

#define CreatorInset _size_S(11)
#define CreatorTextFieldHeight _size_S(44)
#define CreatorTextFieldWidth _size_S(281)
#define CreatorLbsViewHeight _size_S(33)

#pragma mark -MaskButton
@interface MaskButton : UIButton
@property (nonatomic, assign) CGFloat maskProgress;
@property (nonatomic, strong) UIView* maskView;
@end

@implementation MaskButton

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        _maskProgress = 1;
        _maskView = [[UIView alloc] initWithFrame:self.bounds];
        _maskView.backgroundColor = RGBACOLOR(0xff, 0xff, 0xff, 0.4);
        
        [self addSubview:_maskView];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    _maskView.height = (1.0 - _maskProgress)* self.height;
}

- (void)setMaskProgress:(CGFloat)maskProgress
{
    _maskProgress = maskProgress;
    [self setNeedsLayout];
}

@end

/////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////
#pragma mark -CreatorTextField
@interface CreatorTextField : UITextField

@end

@implementation CreatorTextField

//控制placeHolder 的位置，左右缩 8px
- (CGRect)textRectForBounds:(CGRect)bounds
{
    return CGRectInset(bounds , _size_S(8) , 0 );
}

// 控制文本的位置，左右缩 8px
- (CGRect)editingRectForBounds:(CGRect)bounds
{
    return CGRectInset(bounds , _size_S(8) , 0 );
}

@end

/////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////
#pragma mark -CreatorLbsView
@interface CreatorLbsView : UIView
{
    NSInteger _poiIndex;
}
@property (nonatomic, strong) UILabel* infoLabel;
@property (nonatomic, strong) CALayer* iconLayer;
@property (nonatomic, strong) UIButton* refreshBtn;
@property (nonatomic, strong) BMKPoiInfo* curInfo;
@end

@implementation CreatorLbsView

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor clearColor];
        self.infoLabel = ({
            UILabel* label = [[UILabel alloc] initWithFrame:CGRectZero];
            label.textColor = [UIColor colorWithColorType:ColorType_LightTxt];
            label.font = [DPFont systemFontOfSize:FONT_SIZE_MIDDLE];
            label.textAlignment = NSTextAlignmentCenter;
            label.backgroundColor = [UIColor clearColor];
            label.lineBreakMode = NSLineBreakByTruncatingTail;
            label.numberOfLines = 1;
            label;
        });
        
        self.iconLayer = ({
            CALayer* layer = [CALayer layer];
            UIImage* image = LOAD_ICON_USE_POOL_CACHE(@"bb_creator_lbslogo.png");
            layer.bounds = CGRectMake(0.0f,0.0f,image.size.width,image.size.height);
            layer.backgroundColor = [UIColor clearColor].CGColor;
            layer.contents = (id)image.CGImage;
            layer.anchorPoint = CGPointMake(0, 0);
            layer;
        });
        
        self.refreshBtn = ({
            UIButton* button = [UIButton buttonWithType:UIButtonTypeCustom];
            button.backgroundColor = [UIColor clearColor];
            UIImage* image = LOAD_ICON_USE_POOL_CACHE(@"bb_creator_refresh.png");
            button.size = image.size;
            [button setImage:image forState:UIControlStateNormal];
            [button setImage:image forState:UIControlStateHighlighted];
            [button addTarget:self action:@selector(refreshLbsInfo) forControlEvents:UIControlEventTouchUpInside];
            button;
        });
        
        [self.layer addSublayer:_iconLayer];
        [self addSubview:_infoLabel];
        [self addSubview:_refreshBtn];
        
        self.height = _iconLayer.frame.size.height;
        _infoLabel.left = _iconLayer.frame.size.width + CreatorInset;
        _poiIndex = 0;
        if ([[DPLbsServerEngine shareInstance] isEnabledAndAuthorize]) {
            self.curInfo = [[DPLbsServerEngine shareInstance] getPoiInfoAtIndex:_poiIndex];
            [self setLbsInfo:_curInfo.name];
        }
    }
    return self;
}

- (void)setLbsInfo:(NSString*)lbs
{
    _infoLabel.text = lbs;
    [_infoLabel sizeToFit];

    _infoLabel.width = MIN(_infoLabel.width, CreatorTextFieldWidth - CreatorInset*2);
    self.width = _iconLayer.frame.size.width + _infoLabel.width + _refreshBtn.width + CreatorInset*2;
    
    self.centerX = SCREEN_WIDTH/2;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    _infoLabel.centerY = _refreshBtn.centerY = self.height/2;
    _refreshBtn.left = _infoLabel.right + CreatorInset;
}

- (void)refreshLbsInfo
{
    _poiIndex ++;
    if ([[DPLbsServerEngine shareInstance] isEnabledAndAuthorize]) {
        self.curInfo = [[DPLbsServerEngine shareInstance] getPoiInfoAtIndex:_poiIndex];
        [self setLbsInfo:_curInfo.name];
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self refreshLbsInfo];
}
@end

/////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////
#pragma mark -DPUnionCreateViewController
@interface DPUnionCreateViewController ()<UITextFieldDelegate,UINavigationControllerDelegate ,UIImagePickerControllerDelegate,DPBaseUploadMgrProtocol,UIActionSheetDelegate>
{
    NSUInteger _curUploadTaskTag;
    NSString* _curUploadedPicPath;
}
@property (nonatomic, strong) MaskButton* logoSetBtn;
@property (nonatomic, strong) UILabel* logoInfoLabel;

@property (nonatomic, strong) CreatorTextField* unionNameField;

@property (nonatomic, strong) CreatorLbsView* lbsInfoView;

@property (nonatomic, strong) UIButton* creatorBtn;
@property (nonatomic, strong) UILabel* creatorInfoLabel;

@end

@implementation DPUnionCreateViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(geoReverseDidUpdate:) name:DPLocationGetReverseGeoCodeResult object:nil];
    
    _curUploadTaskTag = NSNotFound;
    _curUploadedPicPath = nil;
    // Do any additional setup after loading the view.
    [self.view setBackgroundColor:[UIColor colorWithColorType:ColorType_EmptyViewBg]];
    
    [self resetBackBarButtonWithImage];
    self.title = NSLocalizedString(@"BB_TXTID_版块创建", @"");
    
    [self addSubControls];
    
    [[DPBaseUploadMgr shareInstance] setDelegate:self];
    
    [[DPLbsServerEngine shareInstance] forceToUpdateLocation];
}

- (void)geoReverseDidUpdate:(NSNotification*)notification
{
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(textChanged:)
                                                 name:UITextFieldTextDidChangeNotification
                                               object:nil];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if ([[DPLbsServerEngine shareInstance] isEnabledAndAuthorize] == NO) {
        [DPShortNoticeView showTips:NSLocalizedString(@"BB_TXTID_需要开启定位服务，允许biubiu的请求",nil) atRootView:self.view];
    }
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextFieldTextDidChangeNotification object:nil];
}

- (BOOL)hidesBottomBarWhenPushed
{
    return YES;
}

- (BOOL)isSupportLeftDragBack
{
    return YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - ui
- (void)addSubControls
{
    [self.view addSubview:self.logoSetBtn];
    
    self.logoInfoLabel = [self defaultInfoLabel];
    _logoInfoLabel.text = NSLocalizedString(@"BB_TXTID_设置Logo提示", @"");
    [_logoInfoLabel sizeToFit];
    [self.view addSubview:_logoInfoLabel];
    
    [self.view addSubview:self.unionNameField];
    
    [self.view addSubview:self.lbsInfoView];
    
    [self.view addSubview:self.creatorBtn];
    self.creatorInfoLabel = [self defaultInfoLabel];
    _creatorInfoLabel.text = NSLocalizedString(@"BB_TXTID_创建版块提示", @"");
    [_creatorInfoLabel sizeToFit];
    [self.view addSubview:_creatorInfoLabel];
    
    {
        _logoSetBtn.centerX = _logoInfoLabel.centerX = _unionNameField.centerX = _lbsInfoView.centerX = _creatorInfoLabel.centerX =_creatorBtn.centerX = SCREEN_WIDTH/2;
        
        _logoSetBtn.top = CreatorMarginTop;
        _logoInfoLabel.top = _logoSetBtn.bottom + CreatorMarginTop1;
        _unionNameField.top = _logoInfoLabel.bottom + CreatorMarginTop2;
        _lbsInfoView.top = _unionNameField.bottom + CreatorMarginTop3;
        _creatorBtn.top = _lbsInfoView.bottom + CreatorMarginTop4;
        _creatorInfoLabel.top = _creatorBtn.bottom + CreatorMarginTop5;
    }
}

- (CreatorLbsView *)lbsInfoView
{
    if (nil == _lbsInfoView) {
        _lbsInfoView = [[CreatorLbsView alloc] initWithFrame:CGRectZero];
    }
    return _lbsInfoView;
}

- (UIButton *)logoSetBtn
{
    if (nil == _logoSetBtn) {
        _logoSetBtn = [[MaskButton alloc] initWithFrame:CGRectMake(0, 0, CreatorPhotoDiameter, CreatorPhotoDiameter)];
        [_logoSetBtn setBackgroundColor:[UIColor clearColor]];
        UIImage* image = LOAD_ICON_USE_POOL_CACHE(@"bb_creator_camera.png");
        [_logoSetBtn setImage:image forState:UIControlStateNormal];
        [_logoSetBtn setImage:image forState:UIControlStateHighlighted];
        
        _logoSetBtn.layer.cornerRadius = CreatorPhotoDiameter/2;
        _logoSetBtn.layer.masksToBounds = YES;
        
        [_logoSetBtn addTarget:self action:@selector(showActionSheet) forControlEvents:UIControlEventTouchUpInside];
    }
    return _logoSetBtn;
}

- (UITextField *)unionNameField
{
    if (nil == _unionNameField) {
        _unionNameField = [[CreatorTextField alloc] initWithFrame:CGRectMake(0, 0, CreatorTextFieldWidth, CreatorTextFieldHeight)];
        _unionNameField.layer.cornerRadius = _size_S(5);
        _unionNameField.layer.masksToBounds = YES;
        _unionNameField.font = [DPFont systemFontOfSize:FONT_SIZE_MIDDLE];
        _unionNameField.textColor = [UIColor colorWithColorType:ColorType_MediumTxt];
        
        _unionNameField.placeholder = NSLocalizedString(@"BB_TXTID_版块名称提示", @"");
        _unionNameField.delegate = self;
        _unionNameField.layer.borderWidth = _size_S(1.0);
        _unionNameField.layer.borderColor = RGBACOLOR(0xd3, 0xd3, 0xd3, 1).CGColor;
    }
    return _unionNameField;
}

- (UILabel*)defaultInfoLabel
{
    UILabel* label = [[UILabel alloc] initWithFrame:CGRectZero];
    label.textColor = [UIColor colorWithColorType:ColorType_LightTxt];
    label.font = [DPFont systemFontOfSize:FONT_SIZE_MIDDLE];
    label.textAlignment = NSTextAlignmentCenter;
    label.backgroundColor = [UIColor clearColor];
    
    return label;
}

- (UIButton*)creatorBtn
{
    if (nil == _creatorBtn) {
        _creatorBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, CreatorTextFieldWidth, CreatorTextFieldHeight)];
        [_creatorBtn setBackgroundImage:[UIImage imageWithColor:RGBACOLOR(0x5f, 0xcb, 0xff, 1)] forState:UIControlStateNormal];
        [_creatorBtn setBackgroundImage:[UIImage imageWithColor:RGBACOLOR(0x5f, 0xcb, 0xff, 1)] forState:UIControlStateHighlighted];
        [_creatorBtn setTitleColor:RGBACOLOR(0xff, 0xff, 0xff, 1) forState:UIControlStateNormal];
        [_creatorBtn setTitleColor:RGBACOLOR(0xff, 0xff, 0xff, 0.7) forState:UIControlStateHighlighted];
        _creatorBtn.layer.cornerRadius = 5.0f;
        _creatorBtn.layer.masksToBounds = YES;
        [_creatorBtn setTitle:NSLocalizedString(@"BB_TXTID_创建版块", @"") forState:UIControlStateNormal];
        
        [_creatorBtn addTarget:self action:@selector(creatorSocialtyOpt) forControlEvents:UIControlEventTouchUpInside];
    }
    return _creatorBtn;
}

- (void)creatorSocialtyOpt
{
    if(_curUploadTaskTag == NSNotFound){
        //未选择图片上传
        [DPShortNoticeView showTips:NSLocalizedString(@"BB_TXTID_未选择图片上传", nil) atRootView:self.view];
        return;
    }
    
    if ([_unionNameField.text length]) {
        [_unionNameField resignFirstResponder];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(unionCreationOperationCallback:) name:kUnionCreationResult object:nil];
        NSString* poiName = [_lbsInfoView curInfo].name;
        CLLocationCoordinate2D location = [_lbsInfoView curInfo].pt;
        int lat = location.latitude * 1000000;
        int lon = location.longitude * 1000000;
        [[DPHttpService shareInstance] excuteCmdToCreateSociaty:_unionNameField.text picPath:_curUploadedPicPath location:poiName latitude:lat logitude:lon];
    }else{
        [DPShortNoticeView showTips:NSLocalizedString(@"BB_TXTID_版块名称不能为空", nil) atRootView:self.view];
    }
}

- (void)unionCreationOperationCallback:(NSNotification*)notification
{
    DPTrace("版块创建请求回调");
    NSDictionary* userInfo = notification.userInfo;
    BackSourceInfo* response = [userInfo objectForKey:kNotification_ReturnObject];
    if (response) {
        if (response.statusCode == 0) {
            DPTrace("**************版块创建请求成功**************");
            UIAlertView* alert = [[UIAlertView alloc] initWithTitle:nil message:NSLocalizedString(@"BB_TXTID_审核中", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"BB_TXTID_确定", @"") otherButtonTitles:nil, nil];
            [alert show];
        }else{
            DPTrace("**************版块创建请求失败: %zd - %@**************", response.statusCode, response.statusInfo);
            [DPShortNoticeView showTips:NSLocalizedString(@"BB_TXTID_版块创建请求失败", nil) atRootView:self.view];
        }
        return;
    }
    DPTrace("**************版块创建请求失败**************");
    DPTrace("%@",[userInfo objectForKey:kNotification_Error]);
    [DPShortNoticeView showTips:NSLocalizedString(@"BB_TXTID_版块创建请求失败", nil) atRootView:self.view];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    [self popSelf];
}

- (void)popSelf
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)showImagePickerWithType:(UIImagePickerControllerSourceType) type
{
    if (type == UIImagePickerControllerSourceTypeCamera && ![AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo].count){
        return;
    }
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
    imagePicker.mediaTypes = @[(NSString*)kUTTypeImage];
    imagePicker.allowsEditing = YES;
    imagePicker.delegate = self;
    imagePicker.sourceType = type;

    [self presentViewController:imagePicker animated:YES completion:nil];
    if (type == UIImagePickerControllerSourceTypeCamera) {
        if ([self isCameraAuthorized] == NO) {
            UIAlertView* alert = [[UIAlertView alloc] initWithTitle:nil message:NSLocalizedString(@"BB_TXTID_拍照权限提示", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"BB_TXTID_确定", @"") otherButtonTitles:nil, nil];
            [alert show];
        }
    }else{

    }
}
//修改相册选择界面的导航栏颜色
- (void)navigationController:(UINavigationController *)navigationController
      willShowViewController:(UIViewController *)viewController
                    animated:(BOOL)animated
{
    if ([navigationController isKindOfClass:[UIImagePickerController class]])
    {
        viewController.navigationController.navigationBar.translucent = NO;
        viewController.edgesForExtendedLayout = UIRectEdgeNone;
        
        if ([UINavigationBar instancesRespondToSelector:@selector(setBarTintColor:)])
        {
            viewController.navigationController.navigationBar.barTintColor = [UIColor colorWithColorType:ColorType_NavBar];
            viewController.navigationController.navigationBar.tintColor = [UIColor clearColor];
        }
        viewController.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName:[UIColor whiteColor],NSFontAttributeName:[DPFont boldSystemFontOfSize:FONT_SIZE_LARGE]};
        /* Left button */
        viewController.navigationController.navigationBar.tintColor = [UIColor whiteColor];
        
        /* Right button color  */
        viewController.navigationController.navigationBar.topItem.rightBarButtonItem.tintColor = [UIColor whiteColor];
    }
}

// iOS7及以上可以设置应用对摄像头的访问权限，检测方法
- (BOOL) isCameraAuthorized
{
    if ([AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo].count) {
        AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
        if (authStatus == AVAuthorizationStatusDenied) {
            return NO;
        }
        if(authStatus == AVAuthorizationStatusNotDetermined){
            [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
                if(granted){
                    NSLog(@"Granted access to AVMediaTypeVideo");
                } else {
                    NSLog(@"Not granted access to AVMediaTypeVideo");
                }
            }];
        }
    }
    return YES;
}

- (void)showActionSheet
{
    UIActionSheet *actionSheet = [[UIActionSheet alloc]
                                  initWithTitle:nil
                                  delegate:self
                                  cancelButtonTitle:NSLocalizedString(@"BB_TXTID_取消", @"")
                                  destructiveButtonTitle:nil
                                  otherButtonTitles:NSLocalizedString(@"BB_TXTID_拍照", @""), NSLocalizedString(@"BB_TXTID_从手机相册选择", @""),nil];
    actionSheet.actionSheetStyle = UIActionSheetStyleBlackOpaque;
    
    [actionSheet showInView:self.view];
}


- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) {
        //拍照
        [self showImagePickerWithType:UIImagePickerControllerSourceTypeCamera];
    }else if (buttonIndex == 1) {
        //相库
        [self showImagePickerWithType:UIImagePickerControllerSourceTypePhotoLibrary];
    }
}


#pragma mark - image picker delegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    //通过UIImagePickerControllerMediaType判断返回的是照片还是视频
    NSString* type = [info objectForKey:UIImagePickerControllerMediaType];
    //如果返回的type等于kUTTypeImage，代表返回的是照片,并且需要判断当前相机使用的sourcetype是拍照还是相册
    if ([type isEqualToString:(NSString*)kUTTypeImage] /*&& picker.sourceType == UIImagePickerControllerSourceTypeCamera*/) {
        UIImage* edit = [info objectForKey:UIImagePickerControllerEditedImage];
        [_logoSetBtn setImage:edit forState:UIControlStateNormal];
        [_logoSetBtn setImage:edit forState:UIControlStateHighlighted];
        _logoSetBtn.maskProgress = 0;
        {
            DPPhotoUploader* uploader = [[DPPhotoUploader alloc] init];
            uploader.resultType = UploadResultType_String;
            [uploader createRequestWithImage:edit];
            _curUploadTaskTag = uploader.taskTag;
            [[DPBaseUploadMgr shareInstance] addTaskWithPhotoTask:uploader];
        }
    }else{
        
    }
    
    //模态方式退出uiimagepickercontroller
    [picker dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - textfield delegate
 - (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if (textField.markedTextRange) {
        return YES;
    }
    
    if (string.length) {
        if (range.length < string.length) {
            if (range.location + string.length > 10) {
                return NO;
            }
        }
    }else{
        return YES;
    }
    return YES;
}

- (void)textChanged:(NSNotification*)notification
{
    if ([[_unionNameField text] length] > 10 && NO == _unionNameField.markedTextRange) {
        NSString* string = _unionNameField.text;
        [_unionNameField setText:[string substringToIndex:MIN(10, string.length)]];
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.unionNameField resignFirstResponder];
}

#pragma mark - uploader delegate
- (void)taskUploadMgrOnStartUploadTask:(DPBaseUploadMgr*)manager task:(DPBaseUploader*)task
{
    if (task.taskTag != _curUploadTaskTag) {
        return;
    }
}

- (void)taskUploadMgrUploadTaskProcess:(DPBaseUploadMgr *)manager task:(DPBaseUploader*)task process:(CGFloat)process
{
    if (task.taskTag != _curUploadTaskTag) {
        return;
    }
    _logoSetBtn.maskProgress = process;
    NSLog(@"****图片上传进度：%f",process);
}

- (void)taskUploadMgrOnFinishUploadTask:(DPBaseUploadMgr*)manager task:(DPBaseUploader*)task info:(NSDictionary*)info
{
    if (task.taskTag != _curUploadTaskTag) {
        return;
    }
    NSLog(@"*****图片上传结果：%@",info);
    if (info) {
        //上传成功
        _curUploadedPicPath = [info objectForKey:@"return_string"];
    }else{
        //上传失败了
        _curUploadTaskTag = NSNotFound;
        UIImage* image = LOAD_ICON_USE_POOL_CACHE(@"bb_creator_camera.png");
        [_logoSetBtn setImage:image forState:UIControlStateNormal];
        [_logoSetBtn setImage:image forState:UIControlStateHighlighted];
        _logoSetBtn.maskProgress = 1;
        //上传失败
        [DPShortNoticeView showTips:NSLocalizedString(@"BB_TXTID_图片上传失败，请重新选择上传", nil) atRootView:self.view];
    }
}

- (void)taskUploadMgrOnCancelUploadTask:(DPBaseUploadMgr*)manager task:(DPBaseUploader*)task
{
    if (task.taskTag != _curUploadTaskTag) {
        return;
    }
    _curUploadTaskTag = NSNotFound;
    UIImage* image = LOAD_ICON_USE_POOL_CACHE(@"bb_creator_camera.png");
    [_logoSetBtn setImage:image forState:UIControlStateNormal];
    [_logoSetBtn setImage:image forState:UIControlStateHighlighted];
    _logoSetBtn.maskProgress = 1;
}

@end
