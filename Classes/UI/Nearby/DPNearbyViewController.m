//
//  DPNearbyViewController.m
//  biubiu
//
//  Created by haowenliang on 15/2/1.
//  Copyright (c) 2015年 dpsoft. All rights reserved.
//

#import "DPNearbyViewController.h"
#import "DPEmptyView.h"
#import "DPLbsServerEngine.h"
#import "DPInternetService.h"
#import "DPListStyleViewCell.h"
#import "DPHttpService.h"
#import "BackSourceInfo_2001.h"
#import "BackSourceInfo_2004.h"
#import "DPPublishViewController.h"
#import "DPDetailViewController.h"
#import "DPShortNoticeView.h"
#import "DPFileHelper.h"
#import "DPHttpService+UnionExtension.h"

#import "DPQuestionUpdateService.h"
#import "DPAnswerUpdateService.h"

#import "DPNavLocationView.h"
#import "DPHttpService+Sociaty.h"
@interface DPNearbyViewController ()<DPListStyleViewCellProtocol>
{
    TableViewType _viewType;
    NSInteger _currentOpenIndex;
}

@end

@implementation DPNearbyViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self updateLeftBarButtonWithLbs:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(newPostCallback:) name:kNotification_NewPostCallBack object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onPlatformRegistCallback:) name:kNotification_RegistCallBack object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onLocationAuthorizationStatusChanged:) name:kNotification_ChangeLocationAuthorizationStatus object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(locationWillStartUpdate:) name:DPLocationWillStartUpdate object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(locationDidUpdate:) name:DPLocationDidEndUpdate object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(locationUserPlaceCallback:) name:kLocationUserPlace object:nil];
    
    _currentOpenIndex = NSNotFound;
    _viewType = TableViewType_Empty;
    [self.tableView setShowsHorizontalScrollIndicator:NO];
    [self.tableView setShowsVerticalScrollIndicator:NO];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    [self resetRightBarButtonWithNormal:@"bb_navigation_editor_normal.png" highLighted:@"bb_navigation_editor_press.png" andSel:@selector(openPostNewBiuBiuViewController)];
    
    [self removeTableHeaderView];
    
    [DPQuestionUpdateService shareInstance];
    [DPAnswerUpdateService shareInstance];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self reloadDataOpt];
}

- (void)newPostCallback:(NSNotification*)notification
{
    NSDictionary* userInfo = notification.userInfo;
    if ([[userInfo objectForKey:@"questType"] integerValue] == QuestionType_Union) {
        //工会的发表操作
        return;
    }
    
    NSInteger retCode = [[userInfo objectForKey:kNotification_StatusCode] integerValue];
    if (retCode == 0) {
        [self forceToUpdateNearbyList];
    }
}

- (void)onPlatformRegistCallback:(NSNotification*)notification
{
    NSDictionary* userInfo = notification.userInfo;
    NSInteger retCode = [[userInfo objectForKey:kNotification_StatusCode] integerValue];
    if (retCode == 0 || retCode == 1) {
        if ([[DPLbsServerEngine shareInstance] isEnabledAndAuthorize]) {
            [self forceToUpdateNearbyList];
        }
    }else{
        if (![[[DPQuestionUpdateService shareInstance] nearbyQuestionList] count]) {
            _viewType = TableViewType_Network;
            [self.tableView reloadData];
        }else{
            DPTrace("需要提示用户，账户注册失败否？");
        }
    }
}

- (void)onLocationAuthorizationStatusChanged:(NSNotification*)notification
{
    NSDictionary* userInfo = notification.userInfo;
    NSInteger fromStatus = [[userInfo objectForKey:@"fromStatus"] integerValue];
    NSInteger toStatus = [[userInfo objectForKey:@"toStatus"] integerValue];
    if (fromStatus == NSNotFound) {
        return;
    }
    if (toStatus == kCLAuthorizationStatusDenied || toStatus == kCLAuthorizationStatusRestricted) {
        [self reloadDataOpt];
        return;
    }
    if (fromStatus == kCLAuthorizationStatusNotDetermined) {
        [self forceToUpdateNearbyList];
    }else if (fromStatus == kCLAuthorizationStatusAuthorized || fromStatus == kCLAuthorizationStatusAuthorizedAlways || fromStatus == kCLAuthorizationStatusAuthorizedWhenInUse){
        
    }else if (fromStatus == kCLAuthorizationStatusDenied || fromStatus == kCLAuthorizationStatusRestricted){
        if (toStatus == kCLAuthorizationStatusAuthorized || toStatus == kCLAuthorizationStatusAuthorizedAlways || toStatus == kCLAuthorizationStatusAuthorizedWhenInUse){
            [self forceToUpdateNearbyList];
        }
    }
}

- (void)locationWillStartUpdate:(NSNotification*)notification
{
    if(_viewType == TableViewType_Lbs){
        [self reloadDataOpt];
    }
}

- (void)locationDidUpdate:(NSNotification*)notification
{
    [self forceToUpdateNearbyList];
}

- (void)updateUserLocationPlace
{
    int lat = [[DPLbsServerEngine shareInstance] latitude];
    int lon = [[DPLbsServerEngine shareInstance] longitude];
    [[DPHttpService shareInstance] excuteCmdToLocationUserPlaceAtLatitude:lat logitude:lon];
}

- (void)locationUserPlaceCallback:(NSNotification*)notification
{
    DPTrace("用户归属地更新");
    NSDictionary* userInfo = notification.userInfo;
    NSString* place = [userInfo objectForKey:kNotification_ReturnObject];
    [self updateLeftBarButtonWithLbs:place];
}

- (void)updateLeftBarButtonWithLbs:(NSString*)location
{
    if ([location length]) {
        DPNavLocationView* locationBtn = [[DPNavLocationView alloc] initWithFrame:CGRectMake(5.0, 0, 0, 0)];
        [locationBtn setLbsLabelContent:location];
        [self resetLeftBarButtonWithButton:locationBtn];
    }else{
        NSString* city = [[[[DPLbsServerEngine shareInstance] geoCodeResult] addressDetail] city];
        if([city length]){
            DPNavLocationView* locationBtn = [[DPNavLocationView alloc] initWithFrame:CGRectMake(5.0, 0, 0, 0)];
            [locationBtn setLbsLabelContent:city];
            [self resetLeftBarButtonWithButton:locationBtn];
        }else{
            [self resetLeftBarButtonWithNormal:@"bb_biubiu.png" highLighted:@"bb_biubiu.png" andSel:nil];
        }
    }
}

- (void)refreshLbsLocation
{
    [[DPLbsServerEngine shareInstance] forceToUpdateLocation];
}

- (void)reloadDataOpt
{
    [self pullRefreshControlRefreshDone];
    
    TableViewType checkType = TableViewType_Empty;
    if(NO == [[DPLbsServerEngine shareInstance] isEnabledAndAuthorize]) {
        checkType = TableViewType_Lbs;
    }else if ([[[DPQuestionUpdateService shareInstance] nearbyQuestionList] count]){
        checkType = TableViewType_Plain;
    }else if (NO == [[DPInternetService shareInstance] networkEnable]){
        checkType = TableViewType_Network;
    }

    if (checkType != TableViewType_Plain && checkType != TableViewType_Group) {
        self.tableView.scrollEnabled = NO;
        [self removeDownPullRefreshControl];
        [self removeUpPullRefreshControl];
    }else{
        self.tableView.scrollEnabled = YES;
        [self addDownPullRefreshControl];
        if([[DPQuestionUpdateService shareInstance] nearbyQuestionList].count  >= ONEPAGE_COUNT)
            [self addUpPullRefreshControl];
        else
            [self removeUpPullRefreshControl];
    }
    
    _viewType = checkType;
    [self.tableView reloadData];
    [self pullRefreshControlUpdatePosition];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (_viewType != TableViewType_Plain && _viewType != TableViewType_Group) {
        return 1;
    }
    return [[[DPQuestionUpdateService shareInstance] nearbyQuestionList] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (_viewType != TableViewType_Plain && _viewType != TableViewType_Group) {
        UITableViewCell* emptyCell = [tableView dequeueReusableCellWithIdentifier:@"EmptyViewCell"];
        if (nil == emptyCell) {
            emptyCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"EmptyViewCell"];
        }
        DPEmptyView* empty = (DPEmptyView*)[emptyCell findSubview:@"DPEmptyView" resursion:YES];
        if (empty) {
            [empty removeFromSuperview];
        }
        CGRect epframe = self.view.bounds;
        epframe.size.height = SCREEN_HEIGHT - [self getNavStatusBarHeight];
        if (_viewType == TableViewType_Empty) {
            empty = [DPEmptyView getEmptyViewWithFrame:epframe viewType:DPEmptyViewType_NearbyNone];
        }else if (_viewType == TableViewType_Lbs){
            empty = [DPEmptyView getEmptyViewWithFrame:epframe viewType:DPEmptyViewType_LocationError];
        }else if (_viewType == TableViewType_Network){
            empty = [DPEmptyView getEmptyViewWithFrame:epframe viewType:DPEmptyViewType_NetworkError];
        }
        [emptyCell addSubview:empty];
        [emptyCell bringSubviewToFront:empty];
        
        emptyCell.selectionStyle = UITableViewCellSelectionStyleNone;
        emptyCell.backgroundColor = [UIColor clearColor];
        emptyCell.accessoryType = UITableViewCellAccessoryNone;
        return emptyCell;
    }
    NSString* cellIdentifier = @"NearbyIdentifier";
    DPListStyleViewCell* listCell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (nil == listCell) {
        listCell = [[DPListStyleViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        listCell.delegate = self;
    }else{
        if(listCell.contentState == ListStyleViewState_Open && indexPath.row != listCell.modelInPosition){
            [listCell closeLeftReplyViewSilence:YES];
        }
    }
    NSNumber* questionID = [[DPQuestionUpdateService shareInstance] nearbyQuestionList][indexPath.row];
    [listCell setPostContentModel:[[DPQuestionUpdateService shareInstance] getQuestionModelWithID:questionID.integerValue]];
    [listCell setModelInPosition:indexPath.row];
    
    if (_currentOpenIndex == indexPath.row) {
        if (listCell.contentState != ListStyleViewState_Open) {
            [listCell openLeftViewOpt];
        }
        listCell.contentState = ListStyleViewState_Open;
    }else{
        [listCell closeLeftReplyViewSilence:YES];
        listCell.contentState = ListStyleViewState_Close;
    }
    
    return listCell;
}

- (void)replyStateChangedAtPosition:(NSInteger)position toState:(ListStyleViewState)state
{
    if(state == ListStyleViewState_Close){
        if (_currentOpenIndex == position) {
            _currentOpenIndex = NSNotFound;
        }
    }
    if(state == ListStyleViewState_Open && _currentOpenIndex != position){
        if (_currentOpenIndex != NSNotFound) {
            DPListStyleViewCell* cell = (DPListStyleViewCell*)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:_currentOpenIndex inSection:0]];
            [cell didClickLeftView];
            
//            [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:_currentOpenIndex inSection:0]] withRowAnimation:UITableViewRowAnimationRight];
        }
        _currentOpenIndex = position;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (_viewType != TableViewType_Plain && _viewType != TableViewType_Group) {
        return;
    }
//    if (_currentOpenIndex == indexPath.row) {
//        return;
//    }
    NSNumber* questionID = [[DPQuestionUpdateService shareInstance] nearbyQuestionList][indexPath.row];
    DPQuestionModel* model = [[DPQuestionUpdateService shareInstance] getQuestionModelWithID:questionID.integerValue];
//    model = [[DPQuestionUpdateService shareInstance] getQuestionModelWithID:model.questId];
    DPDetailViewController* detail = [[DPDetailViewController alloc] initWithPost:model];
    [self.navigationController pushViewController:detail animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (_viewType != TableViewType_Plain && _viewType != TableViewType_Group) {
        return SCREEN_HEIGHT - [self getNavStatusBarHeight];
    }
    return _size_S(143.0);
}

- (void)showErrorTips:(NSString*)message
{
    [DPShortNoticeView showTips:message atRootView:self.tableView];
}

#pragma mark - refresh opt

- (void)pullRefreshControlStartRefresh:(EGORefreshTableHeaderView *)view
{
    if ([[DPInternetService shareInstance] networkEnable] == NO) {
        [self pullRefreshControlRefreshDone];
        [self performSelector:@selector(showErrorTips:) withObject:NSLocalizedString(@"BB_TXTID_网络未连接，请确认网络连接是否正常",nil) afterDelay:0.1];
        return;
    }
    EGOPullOrientation orientation = view.orientation;
    if (orientation == EGOPullOrientationDown) {
        //        [self performSelector:@selector(updateNearbyList) withObject:nil afterDelay:0.3];
        [self performSelector:@selector(downRefreshOptWithLocationUpdate) withObject:nil afterDelay:0.3];
    }else if (orientation == EGOPullOrientationUp){
        [self performSelector:@selector(loadMoreNearbyList) withObject:nil afterDelay:0.3];
    }
    [self performSelector:@selector(pullRefreshControlRefreshDone) withObject:nil afterDelay:10.0f];
}

#pragma mark - opts

//下拉刷新操作，修改，先重新定位，再刷新
- (void)downRefreshOptWithLocationUpdate
{
    [[DPLbsServerEngine shareInstance] forceToUpdateLocation];
}

- (void)openPostNewBiuBiuViewController
{
    DPPublishViewController* publish = [[DPPublishViewController alloc] init];
    publish.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:publish animated:YES];
}

#pragma mark -请求命令接口

- (void)forceToUpdateNearbyList
{
    [[DPQuestionUpdateService shareInstance] updateNearbyQuestionListWithCompletion:^(NSArray *questionList, DPResponseType type) {
        [self reloadDataOpt];
    }];
    [self updateUserLocationPlace];
}

- (void)loadMoreNearbyList
{
    [[DPQuestionUpdateService shareInstance] pullMoreNearbyQuestionListWithCompletion:^(NSArray *questionList, DPResponseType type) {
        [self reloadDataOpt];
        if (type == DPResponseType_NoMore) {
            [self removeUpPullRefreshControl];
        }
    }];
}

@end
