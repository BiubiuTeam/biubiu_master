//
//  DPUnionPostViewController.m
//  biubiu
//
//  Created by haowenliang on 15/3/25.
//  Copyright (c) 2015年 dpsoft. All rights reserved.
//

#import "DPUnionPostViewController.h"

#import "DPEmptyView.h"
#import "DPInternetService.h"
#import "DPListStyleViewCell.h"
#import "DPHttpService.h"
#import "BackSourceInfo_2001.h"
#import "BackSourceInfo_2004.h"
#import "DPPublishViewController.h"
#import "DPDetailViewController.h"
#import "DPShortNoticeView.h"
#import "DPFileHelper.h"

#import "DPHttpService+Sociaty.h"
#import "DPHttpService+UnionExtension.h"
#import "DPQuestionUpdateService.h"
#import "DPAnswerUpdateService.h"
#import "DPListStyleReplyView.h"
#import "DPUnionPostManager.h"

#define AutoCmd (0)
@interface DPUnionPostViewController ()<DPListStyleViewCellProtocol>
{
    TableViewType _viewType;
    NSInteger _currentOpenIndex;
}
@property (nonatomic, copy) DPUnionPostCallbackBlock requestCallback;

@property (nonatomic, strong) NSMutableArray* datasource;
@end

@implementation DPUnionPostViewController

- (instancetype)initWithUnionId:(NSUInteger)unionId
{
    if (self = [super init]) {
        _curUnionId = unionId;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(newPostCallback:) name:kNotification_NewPostCallBack object:nil];
    
#if AutoCmd
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pullUnionPostListCallback:) name:kPullUnionPostListResult object:nil];
#endif
    
    _datasource = [[NSMutableArray alloc] initWithCapacity:1];
    _currentOpenIndex = NSNotFound;
    _viewType = TableViewType_Plain;
    
    [self.tableView setShowsHorizontalScrollIndicator:NO];
    [self.tableView setShowsVerticalScrollIndicator:NO];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    [self resetRightBarButtonWithNormal:@"bb_navigation_editor_normal.png" highLighted:@"bb_navigation_editor_press.png" andSel:@selector(openPostNewBiuBiuViewController)];
    [self resetBackBarButtonWithImage];
    
    [self removeTableHeaderView];
    
    __weak DPUnionPostViewController* weakSelf = self;
    self.requestCallback = ^(NSInteger pullOrLoad, BOOL Succeed) {
        [weakSelf reloadDataOpt];
    };
    [[DPUnionPostManager shareInstance] resetRegistedUnion:_curUnionId completion:_requestCallback];
  
    [self updateUnionPostList];
}

- (void)dealloc
{
    [[DPUnionPostManager shareInstance] clearRegistedUnionInfo];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    self.datasource = nil;
    self.requestCallback = nil;
}

- (NSMutableArray *)datasource
{
#if AutoCmd
    return _datasource;
#else
    return [[DPUnionPostManager shareInstance] unionPostList];
#endif
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
        [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:_currentOpenIndex inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
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

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    if (self.navigationController == nil) {
        NSLog(@"不在堆栈里面了");
        if (_currentOpenIndex != NSNotFound) {
//            DPListStyleViewCell* cell = (DPListStyleViewCell*)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:_currentOpenIndex inSection:0]];
        }
    }else{
        NSLog(@"还在堆栈");
    }
}

//- (BOOL)isSupportLeftDragBack
//{
//    return NO;
//}

#pragma mark - opts

- (void)openPostNewBiuBiuViewController
{
    DPPublishViewController* publish = [[DPPublishViewController alloc] initWithCurUnionId:_curUnionId questionType:QuestionType_Union];
    publish.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:publish animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)hidesBottomBarWhenPushed
{
    return YES;
}

- (void)newPostCallback:(NSNotification*)notification
{
    NSDictionary* userInfo = notification.userInfo;
    if ([[userInfo objectForKey:@"questType"] integerValue] == QuestionType_Nearby) {
        return;
    }
    if ([[userInfo objectForKey:@"unionId"] integerValue] != _curUnionId) {
        return;
    }
    
    NSInteger retCode = [[userInfo objectForKey:kNotification_StatusCode] integerValue];
    if (retCode == 0) {
        [self updateUnionPostList];
    }
}

- (void)reloadDataOpt
{
    [self pullRefreshControlRefreshDone];
    
    TableViewType checkType = TableViewType_Empty;
    
    if ([self.datasource count]){
        checkType = TableViewType_Plain;
    }else if (NO == [[DPInternetService shareInstance] networkEnable]){
        checkType = TableViewType_Network;
    }
    
    if (checkType != TableViewType_Plain) {
        self.tableView.scrollEnabled = NO;
        [self removeDownPullRefreshControl];
        [self removeUpPullRefreshControl];
    }else{
        self.tableView.scrollEnabled = YES;
        [self addDownPullRefreshControl];
        if(self.datasource.count  >= 10)
            [self addUpPullRefreshControl];
        else
            [self removeUpPullRefreshControl];
    }
    
    _viewType = checkType;
    [self.tableView reloadData];
    [self pullRefreshControlUpdatePosition];
}


#pragma mark -
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (_viewType != TableViewType_Plain) {
        return 1;
    }
    return [self.datasource count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (_viewType != TableViewType_Plain) {
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
            empty = [DPEmptyView getEmptyViewWithFrame:epframe viewType:DPEmptyViewType_UnionPostNone];
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
    if (indexPath.row >= [self.datasource count]) {
        return [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
    }
    NSString* cellIdentifier = @"NearbyIdentifier";
    DPListStyleViewCell* listCell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (nil == listCell) {
        listCell = [[DPListStyleViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        listCell.delegate = self;
    }
    
    [listCell setPostContentModel:[self getQuestionFromSource:indexPath.row]];
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
    if (_viewType != TableViewType_Plain) {
        return;
    }
    if (_currentOpenIndex == indexPath.row) {
        _currentOpenIndex = NSNotFound;
        [self reloadIndexPathsWithCallback:@[indexPath]];
        return;
    }
    
    NSInteger lastIndex = _currentOpenIndex;
    _currentOpenIndex = indexPath.row;
    NSMutableArray* arr = [NSMutableArray arrayWithObject:indexPath];
    if (lastIndex != NSNotFound) {
        [arr addObject:[NSIndexPath indexPathForRow:lastIndex inSection:indexPath.section]];
    }
    [self reloadIndexPathsWithCallback:arr];
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

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (_viewType != TableViewType_Plain) {
        return SCREEN_HEIGHT - [self getNavStatusBarHeight];
    }
    DPQuestionModel* model = [self getQuestionFromSource:indexPath.row];
    
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
    DPQuestionModel* model = [self getQuestionFromSource:index];
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
        [self performSelector:@selector(updateUnionPostList) withObject:nil afterDelay:0.3];
    }else if (orientation == EGOPullOrientationUp){
        [self performSelector:@selector(loadMoreUnionPostList) withObject:nil afterDelay:0.3];
    }
    [self performSelector:@selector(pullRefreshControlRefreshDone) withObject:nil afterDelay:10.0f];
}

#pragma mark -请求命令接口

- (DPQuestionModel*)getQuestionFromSource:(NSInteger)index
{
#if AutoCmd
    if (index < [self.datasource count]) {
        return self.datasource[index];
    }
    return nil;
#else
    if (index < [self.datasource count]) {
        NSNumber* questionID = self.datasource[index];
        return [[DPQuestionUpdateService shareInstance] getQuestionModelWithID:questionID.integerValue];
    }
    return nil;
#endif
}

- (void)updateUnionPostList
{
#if AutoCmd
    [[DPHttpService shareInstance] excuteCmdToPullUnionPosts:_curUnionId idType:1 lastId:0];
#else
    [[DPUnionPostManager shareInstance] updateUnionPostList];
#endif
}

- (void)loadMoreUnionPostList
{
#if AutoCmd
    DPQuestionModel* model = [self getQuestionFromSource:(_datasource.count -1 )];
    [[DPHttpService shareInstance] excuteCmdToPullUnionPosts:_curUnionId idType:1 lastId:[model.sortId integerValue]];
#else
    [[DPUnionPostManager shareInstance] loadMoreUnionPostList];
#endif
}
#if AutoCmd
- (void)pullUnionPostListCallback:(NSNotification*)notification
{
    NSDictionary* userInfo = notification.userInfo;
    NSUInteger lastId = [[userInfo objectForKey:@"lastId"] unsignedIntegerValue];
    
    if ([userInfo objectForKey:kNotification_Error]) {
        NSString* tips = nil;
        //失败
        if (lastId == 0) {
            tips = @"刷新失败";
        }else{
            tips = @"加载更多失败";
        }
        [DPShortNoticeView showTips:tips atRootView:self.view];
        [self reloadDataOpt];
        return;
    }
    
    if ([userInfo objectForKey:kNotification_ReturnObject]) {
        if (lastId == 0) {
            [_datasource removeAllObjects];
        }
        [_datasource addObjectsFromArray:[userInfo objectForKey:kNotification_ReturnObject]];
    }
    [self reloadDataOpt];
}
#endif
@end
