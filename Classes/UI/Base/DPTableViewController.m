//
//  DPTableViewController.m
//  BiuBiu
//
//  Created by haowenliang on 14/12/21.
//  Copyright (c) 2014年 dpsoft. All rights reserved.
//

#import "DPTableViewController.h"
#import <MBProgressHUD.h>

@interface DPTableViewController ()
@property (nonatomic, strong) MBProgressHUD* HUD;
@end

@implementation DPTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _containsDownRefreshControl = NO;
    _containsUpRefreshControl = NO;
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    [self.view setBackgroundColor:[UIColor colorWithColorType:ColorType_EmptyViewBg]];
    
    self.tableView.backgroundColor = [UIColor colorWithColorType:ColorType_EmptyViewBg];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    self.tableView.separatorColor = [UIColor colorWithColorType:ColorType_Seperator];
    
    UIView* headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, _size_S(20))];
    headerView.backgroundColor = [UIColor clearColor];
    [self.tableView setTableHeaderView:headerView];
    
    UIView* footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 0.1)];
    footerView.backgroundColor = [UIColor clearColor];
    [self.tableView setTableFooterView:footerView];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self hideLoading];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)removeTableHeaderView
{
    self.tableView.tableHeaderView = nil;
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
    if (_HUD.superview && _HUD.superview != self.tableView) {
        [_HUD removeFromSuperview];
    }
    [self.tableView addSubview:_HUD];
    [self.tableView setScrollEnabled:NO];
}

- (void)hideLoading
{
    @synchronized(self){
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(hideLoading) object:nil];;
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(showLoadingView:) object:nil];
        
        if (_HUD) {
            [_HUD hide:YES];
        }
        [self.tableView setScrollEnabled:YES];
    }
}

- (void)showLoadingView:(NSString*)message
{
    @synchronized(self){
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
}

#pragma mark -刷新控件接口
- (void)pullRefreshControlUpdatePosition
{
    if (_containsDownRefreshControl) {
        [_PullDownRefreshView adjustPosition];
    }
    if (_containsUpRefreshControl) {
        [_PullUpRefreshView adjustPosition];
    }
}

- (void)addDownPullRefreshControl
{
    [self removeDownPullRefreshControl];
    _containsDownRefreshControl = YES;
    _PullDownRefreshView = [[EGORefreshTableHeaderView alloc] initWithScrollView:self.tableView orientation:EGOPullOrientationDown];
    _PullDownRefreshView.delegate = self;
    [_PullDownRefreshView adjustPosition];
}

- (void)removeDownPullRefreshControl
{
    if(_containsDownRefreshControl){
        _containsDownRefreshControl = NO;
        
        [_PullDownRefreshView removeFromSuperview];
        _PullDownRefreshView.delegate = nil;
        _PullDownRefreshView = nil;
    }
}

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
    if (_containsDownRefreshControl) {
        [_PullDownRefreshView egoRefreshScrollViewDataSourceDidFinishedLoading:self.tableView];
    }
    if (_containsUpRefreshControl) {
        [_PullUpRefreshView egoRefreshScrollViewDataSourceDidFinishedLoading:self.tableView];
    }
}

- (void)pullRefreshControlStartRefresh:(EGORefreshTableHeaderView*)view
{
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{

    return 0;
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


#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (_PullDownRefreshView.state == EGOOPullRefreshLoading) {
        if (_containsUpRefreshControl &&
            [_PullUpRefreshView reachToPullCondition:scrollView]) {
            [_PullDownRefreshView egoRefreshScrollViewDataSourceDidFinishedLoading:scrollView];
        }else{
            return;
        }
    }else if (_PullUpRefreshView.state == EGOOPullRefreshLoading) {
        if (_containsDownRefreshControl &&
            [_PullDownRefreshView reachToPullCondition:scrollView]) {
            [_PullUpRefreshView egoRefreshScrollViewDataSourceDidFinishedLoading:scrollView];
        }else{
            return;
        }
    }
    if (_containsDownRefreshControl) {
        [_PullDownRefreshView egoRefreshScrollViewDidScroll:scrollView];
    }
    if (_containsUpRefreshControl) {
        [_PullUpRefreshView egoRefreshScrollViewDidScroll:scrollView];
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (_containsDownRefreshControl) {
        [_PullDownRefreshView egoRefreshScrollViewDidEndDragging:scrollView];
    }
    if (_containsUpRefreshControl) {
        [_PullUpRefreshView egoRefreshScrollViewDidEndDragging:scrollView];
    }
}


@end
