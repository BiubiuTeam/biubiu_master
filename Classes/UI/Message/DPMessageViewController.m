//
//  DPMessageViewController.m
//  biubiu
//
//  Created by haowenliang on 15/2/1.
//  Copyright (c) 2015年 dpsoft. All rights reserved.
//

#import "DPMessageViewController.h"
#import "DPEmptyView.h"
#import "DPLocalDataManager.h"
#import "MessageViewCell.h"
#import "BackSourceInfo_4302.h"
#import "NSDateAdditions.h"
#import "DPFileHelper.h"
#import "DPDetailViewController.h"
#import "AppDelegate.h"
#import "DPLocalDataManager+DebugMode.h"
#import "DPInternetService.h"
#import "DPUnionPostViewController.h"
#import "DPUnionCreateViewController.h"

@interface DPMessageViewController ()
{
    TableViewType _viewType;
}
@end

@implementation DPMessageViewController

- (instancetype)init
{
    if (self = [super init]) {
        
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self removeTableHeaderView];
    UIView* footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 0.35)];
    footerView.backgroundColor = [UIColor colorWithColorType:ColorType_Seperator];
    [self.tableView setTableFooterView:footerView];

}

- (void)loadCacheMessageList
{
    __weak DPMessageViewController* weakSelf = self;
    [DPLocalDataManager shareInstance].msgListCallback = ^(NSError* error, NSArray* result){
        if (error) {
            DPTrace("出错了： %@",error);
        }
        
        weakSelf.datasource = [NSMutableArray arrayWithArray:result];
        [weakSelf reloadData];
    };
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    if ([[DPLocalDataManager shareInstance] hasUnreadMessage]) {
        [[DPLocalDataManager shareInstance] loadPushMessageList:2 lastId:0];
    }else{
        DPTrace("不需要触发加载更多");
    }
    //先从缓存读取消息列表数据
    [self loadCacheMessageList];
    
    [self reloadData];
}

- (void)reloadData
{
    [self pullRefreshControlRefreshDone];
    if([_datasource count]){
        _viewType = TableViewType_Plain;
        self.tableView.scrollEnabled = YES;
        [self addDownPullRefreshControl];
        if ([_datasource count] > 10) {
            [self addUpPullRefreshControl];
        }else{
            [self removeUpPullRefreshControl];
        }
    }else{
        _viewType = TableViewType_Empty;
        self.tableView.scrollEnabled = NO;
        
        [self removeDownPullRefreshControl];
        [self removeUpPullRefreshControl];
    }
    
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
    if (_viewType == TableViewType_Empty) {
        return 1;
    }
    return [_datasource count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (_viewType == TableViewType_Empty) {
        UITableViewCell* Empty_Cell = [tableView dequeueReusableCellWithIdentifier:@"EmptyIdentifier"];
        if (nil == Empty_Cell) {
            Empty_Cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"EmptyIdentifier"];
        }
        DPEmptyView* empty = (DPEmptyView*)[Empty_Cell findSubview:@"DPEmptyView" resursion:YES];
        if (empty == nil) {
            CGRect epframe = self.view.bounds;
            epframe.size.height = SCREEN_HEIGHT - [self getNavStatusBarHeight];
            empty = [DPEmptyView getEmptyViewWithFrame:epframe viewType:DPEmptyViewType_MessageNone];
            [Empty_Cell addSubview:empty];
        }
        [Empty_Cell bringSubviewToFront:empty];
        Empty_Cell.selectionStyle = UITableViewCellSelectionStyleNone;
        Empty_Cell.backgroundColor = [UIColor clearColor];
        Empty_Cell.accessoryType = UITableViewCellAccessoryNone;
        return Empty_Cell;
    }
    
    NSString* cellIdentifier = @"MessageCellIdentifier";
    MessageViewCell* cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (nil == cell) {
        cell = [[MessageViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellIdentifier];
    }
    DPPushItemModel* model = _datasource[indexPath.row];
    
    NSDate* pubDate = [NSDate dateWithTimeIntervalSince1970:[model.pubTime unsignedIntegerValue]];
    NSString* content = model.ans;
    NSString* info = model.quest;
    
    if([model.type integerValue] == UNREAD_MESSAGETYPE_QUESTION){
        content = NSLocalizedString(@"BB_TXTID_有1个问题等待您的答复", nil);
    }else if ([model.type integerValue] == UNREAD_MESSAGETYPE_VOTE){
        if ([model.ansId integerValue] == 0) {
            content = NSLocalizedString(@"BB_TXTID_您的提问得到了1个新赞",nil);
        }else{
            info = content;
            content = NSLocalizedString(@"BB_TXTID_您的回复得到了1个新赞",nil);
        }
    }else if([model.type integerValue] == UNREAD_MESSAGETYPE_NOTIFICATION){
        if ([model.isPass integerValue] == 1) {
            content = NSLocalizedString(@"BB_TXTID_版块通过审核", nil);
        }else{
            content = NSLocalizedString(@"BB_TXTID_版块未通过审核", nil);
        }
        info = model.unionName;
    }
    
    [cell setMessageType:[model.type integerValue]];
    [cell setContentText:content info:info date:pubDate];
    
    cell.selectionStyle = UITableViewCellSelectionStyleDefault;
    cell.backgroundColor = [UIColor clearColor];
    BOOL read = [[DPLocalDataManager shareInstance] messageReadTag:[model.ullId integerValue]];
    if (read) {
        DPTrace("已读,%@",indexPath);
    }else{
        DPTrace("未读,%@",indexPath);
    }
    [cell setMaskOnView:read];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    if (_viewType == TableViewType_Empty) {
        return;
    }

    DPPushItemModel* model = _datasource[indexPath.row];
    [[DPLocalDataManager shareInstance] setMessageReadTag:[model.ullId integerValue] readTag:YES];
    if ([model.type integerValue] == UNREAD_MESSAGETYPE_NOTIFICATION) {
        if ([model.isPass integerValue] == 1) {
            //通过，打开版块页面
            DPUnionPostViewController* postCtr = [[DPUnionPostViewController alloc] initWithUnionId:[model.unionId integerValue]];
            postCtr.title = model.unionName;
            [self.navigationController pushViewController:postCtr animated:YES];
        }else{
            //不通过，打开创建页面
            DPUnionCreateViewController* unionCreator = [[DPUnionCreateViewController alloc] init];
            [self.navigationController pushViewController:unionCreator animated:YES];
        }
    }else{
        DPDetailViewController* detail = [[DPDetailViewController alloc] initWithUnreadMessage:model];
        [self.navigationController pushViewController:detail animated:YES];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (_viewType == TableViewType_Empty) {
        return SCREEN_HEIGHT - [self getNavStatusBarHeight];
    }
//    DPPushItemModel* model = _datasource[indexPath.row];
//    NSString* content = model.ans;
//    return [MessageViewCell changableHeight:content];
    return [MessageViewCell limitedHeight];
}


#pragma mark -table support delete
//单元格返回的编辑风格，包括删除 添加 和 默认  和不可编辑三种风格
-(UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (_viewType == TableViewType_Empty) {
        return UITableViewCellEditingStyleNone;
    }
    return UITableViewCellEditingStyleDelete;
}

-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle==UITableViewCellEditingStyleDelete) {
        [tableView beginUpdates];
        
        // 获取选中删除行索引值
        NSInteger position = [indexPath row];
        
        // 通过获取的索引值删除数组中的值
        [_datasource removeObjectAtIndex:position];
        [[DPLocalDataManager shareInstance] deleteUnreadMessageAtIndex:position];
        
        // 删除单元格的某一行时，在用动画效果实现删除过程
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        
        [tableView endUpdates];
        
        if (![_datasource count]) {
            [self reloadData];
        }
    }
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
        [self performSelector:@selector(refreshMessageList) withObject:nil afterDelay:0.3];
    }else if (orientation == EGOPullOrientationUp){
        [self performSelector:@selector(loadMoreMessageList) withObject:nil afterDelay:0.3];
    }
    [self performSelector:@selector(pullRefreshControlRefreshDone) withObject:nil afterDelay:10.0f];
}

- (void)showErrorTips:(NSString*)message
{
    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:nil message:message delegate:nil cancelButtonTitle:nil otherButtonTitles:NSLocalizedString(@"BB_TXTID_确定", nil), nil];
    [alert show];
}

- (void)refreshMessageList
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(refreshMessageList) object:nil];
    
    [[DPLocalDataManager shareInstance] loadPushMessageList:2 lastId:0];
}

- (void)loadMoreMessageList
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(loadMoreMessageList) object:nil];
    
    if([_datasource count]){
        DPPushItemModel* model = [_datasource lastObject];
        [[DPLocalDataManager shareInstance] loadPushMessageList:1 lastId:[model.ullId integerValue]];
    }
}

@end
