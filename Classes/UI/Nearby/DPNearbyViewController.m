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
#import "DPListStyleReplyView.h"
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
    [self.tableView reloadData];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    if (_currentOpenIndex != NSNotFound) {
//        [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:_currentOpenIndex inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
        [[DPListStyleReplyView shareInstance] resetReplyView];
        [[DPListStyleReplyView shareInstance] removeFromSuperview];
    }
    _currentOpenIndex = NSNotFound;
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
//        checkType = TableViewType_Lbs;
    }
    
    if ([[[DPQuestionUpdateService shareInstance] nearbyQuestionList] count]){
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
        
        if([[DPQuestionUpdateService shareInstance] nearbyQuestionList].count  > 10)
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
    }
    
    NSNumber* questionID = [[DPQuestionUpdateService shareInstance] nearbyQuestionList][indexPath.row];
    [listCell setPostContentModel:[[DPQuestionUpdateService shareInstance] getQuestionModelWithID:questionID.integerValue]];
    [listCell setModelInPosition:indexPath.row];
    
    if (_currentOpenIndex == indexPath.row) {
        listCell.contentState = ListStyleViewState_Open;
    }else{
        listCell.contentState = ListStyleViewState_Close;
    }
    
    if (_currentOpenIndex == NSNotFound) {
        [listCell closeReplyViewOpt];
    }
    return listCell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (_viewType != TableViewType_Plain && _viewType != TableViewType_Group) {
        return;
    }
    if (_currentOpenIndex == indexPath.row) {
        _currentOpenIndex = NSNotFound;
//        [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        [self reloadIndexPathsWithCallback:@[indexPath]];
        return;
    }
    
    NSInteger lastIndex = _currentOpenIndex;
    _currentOpenIndex = indexPath.row;
    NSMutableArray* arr = [NSMutableArray arrayWithObject:indexPath];
    if (lastIndex != NSNotFound) {
        [arr addObject:[NSIndexPath indexPathForRow:lastIndex inSection:indexPath.section]];
    }
//    [tableView reloadRowsAtIndexPaths:arr withRowAnimation:UITableViewRowAnimationAutomatic];
    [self reloadIndexPathsWithCallback:arr];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (_viewType != TableViewType_Plain && _viewType != TableViewType_Group) {
        return SCREEN_HEIGHT - [self getNavStatusBarHeight];
    }
    NSNumber* questionID = [[DPQuestionUpdateService shareInstance] nearbyQuestionList][indexPath.row];
    DPQuestionModel* model = [[DPQuestionUpdateService shareInstance] getQuestionModelWithID:questionID.integerValue];
    
    if (_currentOpenIndex == indexPath.row) {
        return DANKUDEGAULTHEIGHT + [DPListStyleViewCell cellHeightForContentText:model.quest] + CELLBOTTOMHEIGHT;
    }
    return [DPListStyleViewCell cellHeightForContentText:model.quest];
}

- (void)showErrorTips:(NSString*)message
{
    [DPShortNoticeView showTips:message atRootView:self.tableView];
}

- (void)openDetailViewAtIndex:(NSInteger)index action:(BOOL)first
{
    NSNumber* questionID = [[DPQuestionUpdateService shareInstance] nearbyQuestionList][index];
    DPQuestionModel* model = [[DPQuestionUpdateService shareInstance] getQuestionModelWithID:questionID.integerValue];
    DPDetailViewController* detail = [[DPDetailViewController alloc] initWithPost:model];
    detail.inputBarIsFirstResponse = first;
    [self.navigationController pushViewController:detail animated:YES];
}

- (void)cellDidClickMessageButton:(NSInteger)modelInPosition
{
    [self openDetailViewAtIndex:modelInPosition action:YES];
}

- (void)cellDidClickBottomAcessoryView:(NSInteger)modelInPosition
{
    [self openDetailViewAtIndex:modelInPosition action:NO];
}

- (void)reloadIndexPathsWithCallback:(NSArray*)indexPaths
{
    [self.tableView reloadRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationAutomatic];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        dispatch_async(dispatch_get_main_queue(), ^{
            [self pullRefreshControlUpdatePosition];
        });
    });
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
