//
//  DPDetailViewController.m
//  biubiu
//
//  Created by haowenliang on 15/2/1.
//  Copyright (c) 2015年 dpsoft. All rights reserved.
//

#import "DPDetailViewController.h"
#import "DPCommentTextField.h"
#import "DPBiuBiuMapItemView.h"
#import "DPInternetService.h"
#import "DPShortNoticeView.h"
#import "DPDetailReplyItemCell.h"
#import "BMKMapLocationView.h"
#import "DPLbsServerEngine.h"
#import "DPHttpService.h"
#import "BackSourceInfo_2001.h"
#import "BackSourceInfo_2005.h"
#import "EGORefreshTableHeaderView.h"
#import "BackSourceInfo_4302.h"

#import "DPQuestionUpdateService.h"
#import "DPAnswerUpdateService.h"

#define DETAIL_MAP_VIEW_HEIGHT _size_S(104)
@interface DPDetailViewController ()<UIAlertViewDelegate,UITableViewDataSource,UITableViewDelegate,DPCommentTextFieldProtocol,EGORefreshTableHeaderDelegate, UIScrollViewDelegate,UIActionSheetDelegate,DPDetailReplyItemCellProtocol>
{
    CGFloat textFieldOrignY;
    NSInteger _clickIndex;
    BOOL _isShutterOpen;
    BOOL _isAnimating;
    BOOL _displayMap;
    BOOL _containsUpRefreshControl;

    BOOL _isEndOfMoreData;
    EGORefreshTableHeaderView* _PullUpRefreshView;
    
    BOOL _needToUpdateModelWhenAppear;
    BOOL _isSendingAnswer;
    BOOL _containsMemoryCacheItem;
    
    NSInteger _currentQuestionId;
}

@property (nonatomic, strong) UITableView* tableView;
@property (nonatomic, strong) BMKMapLocationView* mapView;

@property (nonatomic, strong) NSMutableDictionary* replyUpVoteList;
@property (nonatomic, strong) NSMutableDictionary* replyDownVoteList;

@property (nonatomic, strong) DPCommentTextField* replyField;

@property (nonatomic, strong) DPBiuBiuMapItemView* headerView;
@property (nonatomic, weak) DPDetailViewController* weakSelf;
@end

@implementation DPDetailViewController

- (instancetype)initWithUnreadMessage:(id)model
{
    if (self = [super init]) {
        _highLightUserReply = YES;
        DPPushItemModel* pushModel = (DPPushItemModel*)model;
        _currentQuestionId = [pushModel.questId integerValue];
        DPQuestionModel* questModel = [[DPQuestionUpdateService shareInstance] getQuestionModelWithID:_currentQuestionId];
        if (nil == questModel) {
            questModel = [[DPQuestionModel alloc] init];
            questModel.questId = (int)_currentQuestionId;
            questModel.quest = [pushModel.quest length]?pushModel.quest:@"";
            
            _needToUpdateModelWhenAppear = YES;
        }
        self.postDataModel = questModel;
    }
    return self;
}

- (instancetype)initWithPost:(id)post
{
    if (self = [super init]) {
        _highLightUserReply = YES;
        self.postDataModel = post;
        _needToUpdateModelWhenAppear = NO;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.view setBackgroundColor:RGBACOLOR(0xf6, 0xf7, 0xf9, 1)];
    self.weakSelf = self;
    _clickIndex = NSNotFound;
    
    _containsMemoryCacheItem = NO;
    _isSendingAnswer = NO;
    
    _replyUpVoteList = [[NSMutableDictionary alloc] init];
    _replyDownVoteList = [[NSMutableDictionary alloc] init];
    
    self.title = NSLocalizedString(@"BB_TXTID_详情", nil);
    [self resetBackBarButtonWithImage];

    CGRect tbframe = [self.view bounds];
    tbframe.size.height -= [self getNavStatusBarHeight];
    _replyField = [[DPCommentTextField alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
    _replyField.center = CGPointMake(_replyField.center.x, (tbframe.size.height - _replyField.height/2.0f));
    _replyField.delegate = self;
    [self.view addSubview:_replyField];
    textFieldOrignY = _replyField.frame.origin.y;
    
    tbframe.size.height -= _replyField.height;
    _tableView = [[UITableView alloc] initWithFrame:tbframe];
    _tableView.backgroundColor = [UIColor clearColor];
    _tableView.separatorColor = RGBACOLOR(0xd0, 0xd0, 0xd0, 1);
    _tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    _tableView.delegate = self;
    _tableView.dataSource = self;
    
    _headerView = [[DPBiuBiuMapItemView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, [DPBiuBiuMapItemView defaultHeight])];

    _tableView.tableFooterView = [[UIView alloc] init];
    [self.view addSubview:_tableView];
    [self.view bringSubviewToFront:_replyField];
    //Map View 占用了非常大的一块内存空间
    _mapView = [[BMKMapLocationView alloc] initWithFrame:CGRectMake(0, -DETAIL_MAP_VIEW_HEIGHT, SCREEN_WIDTH, DETAIL_MAP_VIEW_HEIGHT)];
    UITapGestureRecognizer* gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapMapView:)];
    [_mapView addGestureRecognizer:gesture];
    
    [self.view insertSubview:_mapView belowSubview:_tableView];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onAnswerQuestionCallback:) name:kNotification_AnswerPostCallBack object:nil];
    
    [self updateAnswerList];
}

- (void)dealloc
{
    DPTrace("释放详情页面");
    _replyField.delegate = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [_mapView viewWillAppear];
    
    [self updateOptAppearanceWithModel];
    
    if (_needToUpdateModelWhenAppear) {
        [[DPQuestionUpdateService shareInstance] updateQuestionModelWithID:_currentQuestionId completion:^(DPQuestionModel *question, DPResponseType type) {
            if(type == DPResponseType_Succeed){
                _weakSelf.postDataModel = question;
                [_weakSelf updateOptAppearanceWithModel];
            }
        }];
    }
}

- (void)updateOptAppearanceWithModel
{
    [_headerView setDatasource:_postDataModel];

    _tableView.tableHeaderView = nil;
    _tableView.tableHeaderView = _headerView;
    
    NSString* location = _postDataModel.selfLocDesc;
    if (![location length]) {
        location = _postDataModel.locDesc;
    }
    float lat = [[_postDataModel latitude] floatValue];
    float lon = [[_postDataModel longitude] floatValue];
    if (lat > 9999 || lon > 9999) {
        lat = lat/1000000.0;
        lon = lon/1000000.0;
    }
    [_mapView setLocation:CLLocationCoordinate2DMake(lat, lon) withInfo:location];
    
    if (_postDataModel.isMine == nil) {
        [self removeRightNavigationBarButton];
    }else if ([_postDataModel.isMine integerValue] == 1) {
//        [self resetTextRightButtonWithTitle:NSLocalizedString(@"BB_TXTID_删除", @"") andSel:@selector(deleteThePostOpt)];
    }else if([_postDataModel.isImpeach integerValue] == 0){
        [self resetTextRightButtonWithTitle:NSLocalizedString(@"BB_TXTID_举报", @"") andSel:@selector(showReportSheet)];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)reloadData
{
    [_tableView reloadData];
    if ([[self replyList] count] >= 10) {
        [self addUpPullRefreshControl];
    }
}

- (NSArray *)replyList
{
    NSArray* list = [[DPAnswerUpdateService shareInstance] getQuestionAnswerList:_postDataModel.questId];
//    [[DPAnswerUpdateService shareInstance] forceToUpdateAnswerList:_postDataModel.questId demandedCount:_postDataModel.ansNum];
    return list;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillChangeFrameNotification object:nil];
    
    if (_inputBarIsFirstResponse) {
        [_replyField becomeFirstResponder];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [_mapView viewWillDisappear];
    
    [self removeUpPullRefreshControl];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)onAnswerQuestionCallback:(NSNotification*)notification
{
    _isSendingAnswer = NO;
    NSDictionary* userInfo = notification.userInfo;
    NSInteger retCode = [[userInfo objectForKey:kNotification_StatusCode] integerValue];
    if (retCode == 0) {
        DPTrace("回答成功");
        [_replyField clearTextContent];
        [_replyField resignFirstResponderEx];
        
        if(NO == [self insertCallbackAnswerCell:[userInfo objectForKey:kNotification_ReturnObject]]){
            [self insertTmpAnswerCell:[userInfo objectForKey:kNotification_CmdObject]];
        }
        _postDataModel.ansNum++;
        [[DPQuestionUpdateService shareInstance] replaceMemoryCacheQuestion:_postDataModel];
    }else{
        DPTrace("回答失败");
        [DPShortNoticeView showTips:NSLocalizedString(@"BB_TXTID_回答操作失败",nil) atRootView:self.view];
    }
}

- (BOOL)insertCallbackAnswerCell:(DPAnswerModel*)model
{
    if (model) {
        model.localModel = @YES;
        [[DPAnswerUpdateService shareInstance] insertAnswerToQuestion:model questionId:_postDataModel.questId];
        [self reloadData];
        NSIndexPath* indexPath = [NSIndexPath indexPathForRow:([[self replyList] count]-1) inSection:0];
        [_tableView scrollToRowAtIndexPath:indexPath
                          atScrollPosition:UITableViewScrollPositionBottom animated:YES];
        return YES;
    }
    return NO;
}

- (void)insertTmpAnswerCell:(NSDictionary*)commandDict
{
    DPAnswerModel* tmpData = [[DPAnswerModel alloc] init];
    tmpData.ans = [commandDict objectForKey:@"ans"];
    NSNumber* toAnsId = [commandDict objectForKey:@"ansId"];
    if ([toAnsId integerValue] != 0) {
        DPAnswerModel* toModel = [[DPAnswerUpdateService shareInstance] getAnswerDetail:[toAnsId integerValue] questionId:_postDataModel.questId];
        if (toModel) {
            tmpData.otherAnsData = (DPAnswerModel<Optional,ConvertOnDemand>*)toModel;
        }
    }
    
    [[DPAnswerUpdateService shareInstance] insertQuestionLocalAnswer:tmpData questionId:_postDataModel.questId];
    
    [self reloadData];
    NSIndexPath* indexPath = [NSIndexPath indexPathForRow:([[self replyList] count]-1) inSection:0];
    [_tableView scrollToRowAtIndexPath:indexPath
                          atScrollPosition:UITableViewScrollPositionBottom animated:YES];
}

- (void)updateAnswerList
{
    [[DPAnswerUpdateService shareInstance] updateQuestionAnswerList:_postDataModel.questId completion:^(NSArray *qanswerList, DPResponseType type) {
        if (type == DPResponseType_Succeed) {
            [_weakSelf reloadData];
        }
    }];
}

- (void)loadMoreAnswer
{
    [[DPAnswerUpdateService shareInstance] pullMoreAnswerList:_postDataModel.questId completion:^(NSArray *qanswerList, DPResponseType type) {
        if(type != DPResponseType_Failed){
            [_weakSelf reloadData];
        }
        [_weakSelf performSelector:@selector(pullRefreshControlRefreshDone) withObject:nil afterDelay:0.3];
    }];
}

- (void)reportThePostOpt
{
    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:nil message:NSLocalizedString(@"BB_TXTID_是否确定举报该biubiu",nil) delegate:self cancelButtonTitle:NSLocalizedString(@"BB_TXTID_取消", @"") otherButtonTitles:NSLocalizedString(@"BB_TXTID_确定", @""), nil];
    alert.tag = 0x1001;
    [alert show];
}

- (void)showReportSheet
{
    UIActionSheet *actionSheet = [[UIActionSheet alloc]
                                  initWithTitle:NSLocalizedString(@"BB_TXTID_是否确定举报该问题",nil)
                                  delegate:self
                                  cancelButtonTitle:NSLocalizedString(@"BB_TXTID_取消", @"")
                                  destructiveButtonTitle:nil
                                  otherButtonTitles:NSLocalizedString(@"BB_TXTID_确定", @""),nil];
    actionSheet.tag = 0x1001;
    actionSheet.actionSheetStyle = UIActionSheetStyleBlackOpaque;
    [actionSheet showInView:self.view];
}

- (void)showReportAnswerSheet
{
    UIActionSheet *actionSheet = [[UIActionSheet alloc]
                                  initWithTitle:nil //NSLocalizedString(@"BB_TXTID_是否确定举报该回答",nil)
                                  delegate:self
                                  cancelButtonTitle:nil
                                  destructiveButtonTitle:nil
                                  otherButtonTitles:NSLocalizedString(@"BB_TXTID_回答", @""),NSLocalizedString(@"BB_TXTID_举报", @""),NSLocalizedString(@"BB_TXTID_取消", @""),nil];
    actionSheet.tag = 0x1002;
    actionSheet.actionSheetStyle = UIActionSheetStyleBlackOpaque;
    [actionSheet showInView:self.view];
}

- (void)deleteThePostOpt
{
    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:nil message:NSLocalizedString(@"BB_TXTID_是否确定删除该biubiu",nil) delegate:self cancelButtonTitle:NSLocalizedString(@"BB_TXTID_取消", @"") otherButtonTitles:NSLocalizedString(@"BB_TXTID_确定", @""), nil];
    alert.tag = 0x1002;
    [alert show];
}

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) {
        if (actionSheet.tag == 0x1001) {
            //举报问题
            [[DPHttpService shareInstance] reportItem:1 type:_postDataModel.questId completion:^(id json, JSONModelError *err) {
                BackSourceInfo* backSource = [[BackSourceInfo alloc] initWithDictionary:json error:nil];
                DPTrace("举报结果如下：%zd - %@", backSource.statusCode, backSource.statusInfo);
                if (backSource.statusCode == 0) {
                    [DPShortNoticeView showTips:NSLocalizedString(@"BB_TXTID_举报成功",nil) atRootView:self.view];
                }else{
                    [DPShortNoticeView showTips:NSLocalizedString(@"BB_TXTID_举报失败",nil) atRootView:self.view];
                }
            }];
        }else if (actionSheet.tag == 0x1002){
            if(buttonIndex == 1){
                //举报回复
                DPAnswerModel* model = (DPAnswerModel*)[self replyList][_clickIndex];
                //            [[DPHttpService shareInstance] reportAnswer:model.ansId];
                [[DPHttpService shareInstance] reportItem:model.ansId type:2 completion:^(id json, JSONModelError *err) {
                    BackSourceInfo* backSource = [[BackSourceInfo alloc] initWithDictionary:json error:nil];
                    DPTrace("举报结果如下：%zd - %@", backSource.statusCode, backSource.statusInfo);
                    if (backSource.statusCode == 0) {
                        [DPShortNoticeView showTips:NSLocalizedString(@"BB_TXTID_举报成功",nil) atRootView:_weakSelf.view];
                    }else{
                        [DPShortNoticeView showTips:NSLocalizedString(@"BB_TXTID_举报失败",nil) atRootView:_weakSelf.view];
                    }
                }];
                _clickIndex = NSNotFound;
            }
        }
    }
}

- (void)actionSheetCancel:(UIActionSheet *)actionSheet
{
    
}

-(void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if(actionSheet.tag == 0x1002 && buttonIndex == 0){
        //回复回复
        NSLog(@"回复回复");
        [_replyField becomeFirstResponder];
    }
}

-(void)actionSheet:(UIActionSheet *)actionSheet willDismissWithButtonIndex:(NSInteger)buttonIndex{

}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (buttonIndex) {
        case 1:
        {
            if (alertView.tag == 0x1001) {
                DPTrace("确定举报");
                [[DPHttpService shareInstance] reportPost:_postDataModel.questId];
            }else if (alertView.tag == 0x1002){
                DPTrace("确定删除");
            }
        }break;
        default:
            break;
    }
}

- (BOOL)hidesBottomBarWhenPushed
{
    return YES;
}

- (void)voteReplyOpt:(NSInteger)ansId like:(NSInteger)likeOrNot
{
    if (likeOrNot == 1) {
        [[DPAnswerUpdateService shareInstance] updateDemandedAnswer:ansId questionId:_postDataModel.questId countType:DPCountSrcType_Upvotes];
    }else if(likeOrNot == 2) {
        [[DPAnswerUpdateService shareInstance] updateDemandedAnswer:ansId questionId:_postDataModel.questId countType:DPCountSrcType_Downvotes];
    }
    [[DPHttpService shareInstance] excuteCmdToVoteQuestion:_postDataModel.questId ansId:ansId like:likeOrNot];
}

#pragma mark -pull to refresh

- (void)addUpPullRefreshControl
{
    [self removeUpPullRefreshControl];
    _containsUpRefreshControl = YES;
    _PullUpRefreshView = [[EGORefreshTableHeaderView alloc] initWithScrollView:self.tableView orientation:EGOPullOrientationUp];
    _PullUpRefreshView.delegate = self;
    [_PullUpRefreshView adjustPosition];
}

- (void)removeUpPullRefreshControl
{
    if (_containsUpRefreshControl) {
        _containsUpRefreshControl = NO;
        [_PullUpRefreshView removeFromSuperview];
        _PullUpRefreshView.delegate = nil;
        _PullUpRefreshView = nil;
    }
}

- (void)pullRefreshControlRefreshDone
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(pullRefreshControlRefreshDone) object:nil];
    if (_containsUpRefreshControl) {
        [_PullUpRefreshView egoRefreshScrollViewDataSourceDidFinishedLoading:self.tableView];
    }
}

- (void)pullRefreshControlStartRefresh:(EGORefreshTableHeaderView*)view
{
    if (view.orientation == EGOPullOrientationUp) {
        [self loadMoreAnswer];
    }
}
#pragma mark - EGORefreshTableHeaderDelegate

- (void)egoRefreshTableHeaderDidTriggerRefresh:(EGORefreshTableHeaderView*)view
{
    [self pullRefreshControlStartRefresh:view];
}

- (BOOL)egoRefreshTableHeaderDataSourceIsLoading:(EGORefreshTableHeaderView*)view
{
    return view.state == EGOOPullRefreshLoading;
}

- (NSDate*)egoRefreshTableHeaderDataSourceLastUpdated:(EGORefreshTableHeaderView*)view
{
    return [NSDate date];
}

#pragma mark -table view delegate & datasource
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row >= [[self replyList] count]) {
        return [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
    }
    static NSString* reuseIdentifier = @"reuseIdentifier";
    DPDetailReplyItemCell* cell = nil;
    cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
    if (nil == cell) {
        cell = [[DPDetailReplyItemCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
    }
    [cell.contentView setFrame:CGRectMake(0, 0, SCREEN_WIDTH, [self tableView:tableView heightForRowAtIndexPath:indexPath])];
    
    cell.dataPosition = indexPath.row;
    cell.delegate = self;
    DPAnswerModel* model = (DPAnswerModel*)[self replyList][indexPath.row];
    [cell setQuestionId:_postDataModel.questId];
    [cell setAnsId:model.ansId];
    
    [cell setHighLightContent:(_highLightUserReply && [model.isMine integerValue] == 1)];
    cell.backgroundColor = RGBACOLOR(0xf6, 0xf7, 0xf9, 1);
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

- (void)voteAnswerUpOrDown:(NSInteger)voteType voteModel:(id)model
{
    [self voteReplyOpt:[(DPAnswerModel*)model ansId] like:voteType];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    _clickIndex = indexPath.row;
    [_replyField resignFirstResponderEx];
    
    [self showReportAnswerSheet];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    DPAnswerModel* replyItem = (DPAnswerModel*)[self replyList][indexPath.row];
    return [DPDetailReplyItemCell cellHeightForContentText:replyItem.ans withFollowMsg:(replyItem.otherAnsData!=nil)];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[self replyList] count];
}

//foot view
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0;
}

#pragma mark Responding to keyboard events
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

- (void)keyboardWillHide:(NSNotification *)notification
{
    //这个是决定是否是回复回复的关键点啊
    _clickIndex = NSNotFound;
    
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
    if (_isSendingAnswer) {
        return;
    }
    _isSendingAnswer = YES;
    NSString *trimmedString = [text stringByTrimmingCharactersInSet:
                               [NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if (trimmedString.length) {
        if (![[DPInternetService shareInstance] networkEnable]) {
            DPTrace("网络不可用");
            [DPShortNoticeView showTips:NSLocalizedString(@"BB_TXTID_网络未连接，请确认网络连接是否正常",nil) atRootView:self.view];
            return;
        }
        if ([[DPLbsServerEngine shareInstance] isEnabledAndAuthorize] == NO) {
            DPTrace("定位服务不可用");
            [DPShortNoticeView showTips:NSLocalizedString(@"BB_TXTID_需要开启定位服务，允许biubiu的请求",nil) atRootView:self.view];
            return;
        }
        NSInteger ansId = 0;
        if (_clickIndex != NSNotFound) {
            DPAnswerModel* model = (DPAnswerModel*)[self replyList][_clickIndex];
            ansId = model.ansId;
        }
        [[DPHttpService shareInstance] excuteCmdToAnswerThePost:trimmedString questId:_postDataModel.questId ansId:ansId toNick:nil location:[[DPLbsServerEngine shareInstance] geoCodeResult].address];
        return;
    }
    [DPShortNoticeView showTips:NSLocalizedString(@"BB_TXTID_总得说点什么吧···",nil) atRootView:self.view];
}

#pragma mark -动画
- (void)openShutter
{
    _isAnimating = YES;
    [UIView animateWithDuration:0.2
                          delay:0.1
                        options: UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         _mapView.origin = CGPointZero;
                         _mapView.height = DETAIL_MAP_VIEW_HEIGHT;
                         _weakSelf.tableView.origin = CGPointMake(0, DETAIL_MAP_VIEW_HEIGHT);
                     } completion:^(BOOL finished){
                         // Disable cells selection
                         [_weakSelf.tableView setAllowsSelection:NO];
                         _isShutterOpen = YES;
                         _isAnimating = NO;
                     }];
}

- (void)closeShutter
{
    _isAnimating = YES;
    [UIView animateWithDuration:0.2
                          delay:0.1
                        options: UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         _mapView.height = DETAIL_MAP_VIEW_HEIGHT;
                         _mapView.origin = CGPointMake(0, -DETAIL_MAP_VIEW_HEIGHT);
                         _weakSelf.tableView.origin = CGPointZero;
                         _weakSelf.tableView.contentOffset = CGPointZero;
                     }
                     completion:^(BOOL finished){
                         // Enable cells selection
                         [_weakSelf.tableView setAllowsSelection:YES];
                         _isShutterOpen = NO;
                         _isAnimating = NO;
                     }];
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [_replyField clearTextContent];
    [_replyField resignFirstResponderEx];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat scrollOffset = scrollView.contentOffset.y;
//    DPTrace("%lf",scrollOffset);
    if(_isShutterOpen && scrollOffset > 0){
        // Move the tableView up to reach is origin position
        [self closeShutter];
    }else{
        CGRect headerMapViewFrame = _mapView.frame;
        
        CGFloat offsetY = -_mapView.height - scrollOffset;
        if (_isShutterOpen == NO && _isAnimating == NO) {
            headerMapViewFrame.origin.y = MIN(0,offsetY);
            //            if (offsetY > 0) {
            //                headerMapViewFrame.size.height = DETAIL_MAP_VIEW_HEIGHT + offsetY;
            //            }
            _mapView.frame = headerMapViewFrame;
        }
        
        // check if the Y offset is under the minus Y to reach
        if (self.tableView.contentOffset.y < - _size_S(30)){
            if(!_displayMap)
                _displayMap = YES;
        }else{
            if(_displayMap)
                _displayMap = NO;
        }
    }
    
    //判断是否拉到底部，触发加载更多
    if (_PullUpRefreshView.state == EGOOPullRefreshLoading) {
        return;
    }
    if (_containsUpRefreshControl) {
        [_PullUpRefreshView egoRefreshScrollViewDidScroll:scrollView];
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    if(_displayMap){
        [self openShutter];
    }
    if (_containsUpRefreshControl) {
        [_PullUpRefreshView egoRefreshScrollViewDidEndDragging:scrollView];
    }
}

//tap gesture add to map view
- (void)didTapMapView:(UIGestureRecognizer*)gesture
{
    if ([gesture isKindOfClass:[UITapGestureRecognizer class]]) {
        if (gesture.state == UIGestureRecognizerStateEnded) {
            [_replyField clearTextContent];
            [_replyField resignFirstResponderEx];
        }
    }
}

@end
