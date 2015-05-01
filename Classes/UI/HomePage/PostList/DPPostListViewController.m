//
//  DPPostListViewController.m
//  biubiu
//
//  Created by haowenliang on 15/2/1.
//  Copyright (c) 2015年 dpsoft. All rights reserved.
//

#import "DPPostListViewController.h"
#import "DPPostCardStyleView.h"
#import "DPEmptyView.h"
#import "NSDateAdditions.h"
#import "DPInternetService.h"
#import "DPListStyleViewCell.h"
#import "BackSourceInfo_2001.h"
#import "BackSourceInfo_2002.h"
#import "DPHttpService.h"
#import "DPFileHelper.h"
#import "DPDetailViewController.h"
#import "DPShortNoticeView.h"

#import "DPQuestionUpdateService.h"
@interface DPPostListViewController ()
{
    TableViewType _displayType;
}
@property (nonatomic, weak) DPPostListViewController* weakSelf;
@property (nonatomic, strong) DPEmptyView* displayEmptyView;

@end

@implementation DPPostListViewController

- (instancetype)initWithPostListStyle:(HomePageType)type
{
    if (self = [super init]) {
        _listType = type;
        _displayType = TableViewType_Empty;
        
        _datasource = [[NSMutableArray alloc] initWithCapacity:1];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.weakSelf = self;
    
    [self resetBackBarButtonWithImage];
    
    if (_listType == HomePageType_Question) {
        [_datasource addObjectsFromArray:[[DPQuestionUpdateService shareInstance] myPostQuestionList]];
        [self performSelector:@selector(showLoadingView:) withObject:NSLocalizedString(@"BB_TXTID_加载中...", nil) afterDelay:0.3];
        [self reloadUserPostList];
    }else{
        [_datasource addObjectsFromArray:[[DPQuestionUpdateService shareInstance] myReplyQuestionList]];
        [self performSelector:@selector(showLoadingView:) withObject:NSLocalizedString(@"BB_TXTID_加载中...", nil) afterDelay:0.3];
        [self reloadUserFollowList];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self reloadSubviews];
    
    [self removeTableHeaderView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    [[DPQuestionUpdateService shareInstance] cleanUpMemory];
}


- (void)reloadSubviews
{
    UIView* emptyView = [self.view findSubview:@"DPEmptyView" resursion:YES];
    if (emptyView) {
        [emptyView removeFromSuperview];
    }
    if(![_datasource count])
        _displayType = TableViewType_Empty;
    else
        _displayType = TableViewType_Group;
    
    if (_displayType == TableViewType_Empty) {
        if (_listType == HomePageType_Question) {
            self.displayEmptyView = [DPEmptyView getEmptyViewWithFrame:self.tableView.bounds viewType:DPEmptyViewType_PostNone];
        } else if(_listType == HomePageType_Answer){
            self.displayEmptyView = [DPEmptyView getEmptyViewWithFrame:self.tableView.bounds viewType:DPEmptyViewType_ReplyNone];
        }else{
            self.displayEmptyView = [DPEmptyView getEmptyViewWithFrame:self.tableView.bounds viewType:DPEmptyViewType_DefaultError];
        }
        self.tableView.scrollEnabled = NO;
        [self removeUpPullRefreshControl];
    }else{
        self.tableView.scrollEnabled = YES;
        
        if(_datasource.count  >= ONEPAGE_COUNT)
            [self addUpPullRefreshControl];
        else
            [self removeUpPullRefreshControl];
    }
    [self.tableView reloadData];
    [self pullRefreshControlUpdatePosition];
}

- (void)pullRefreshControlStartRefresh:(EGORefreshTableHeaderView *)view
{
    if (view.orientation == EGOPullOrientationUp) {
        if (_listType == HomePageType_Question) {
            [self loadMoreUserPost];
        }else{
            [self loadMoreUserFollowList];
        }
    }
    [self performSelector:@selector(pullRefreshControlRefreshDone) withObject:nil afterDelay:15];
}

#pragma mark -我的提问请求方法
- (void)reloadUserPostList
{
    [[DPQuestionUpdateService shareInstance] updateMyPostQuestionListWithCompletion:^(NSArray *questionList, DPResponseType type) {
        if([questionList count]){
            _weakSelf.datasource = [NSMutableArray arrayWithArray:questionList];
        }else{
            _weakSelf.datasource = [NSMutableArray array];
        }
        if(type == DPResponseType_Failed){
            [DPShortNoticeView showTips:NSLocalizedString(@"BB_TXTID_更新失败",nil) atRootView:self.view];
        }
        [_weakSelf reloadSubviews];
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(showLoadingView:) object:NSLocalizedString(@"BB_TXTID_加载中...", nil)];
        [_weakSelf hideLoading];
    }];
}

- (void)loadMoreUserPost
{
    [[DPQuestionUpdateService shareInstance] pullMoreMyPostQuestionListWithCompletion:^(NSArray *questionList, DPResponseType type) {
//        if([questionList count] > [_weakSelf.datasource count]){
            if([questionList count]){
                _weakSelf.datasource = [NSMutableArray arrayWithArray:questionList];
            }else{
                _weakSelf.datasource = [NSMutableArray array];
            }
            [_weakSelf performSelector:@selector(pullRefreshControlRefreshDone) withObject:nil afterDelay:0.3];
            [_weakSelf reloadSubviews];
//            if(type == DPResponseType_NoMore)
//                [_weakSelf removeUpPullRefreshControl];
//        }else{
//            if([questionList count]){
//                _weakSelf.datasource = [NSMutableArray arrayWithArray:questionList];
//            }else{
//                _weakSelf.datasource = [NSMutableArray array];
//            }
//            [_weakSelf pullRefreshControlRefreshDone];
//            [_weakSelf reloadSubviews];
////            [_weakSelf removeUpPullRefreshControl];
//        }
    }];
}

#pragma mark -我的回答列表请求方法

- (void)reloadUserFollowList
{
    [[DPQuestionUpdateService shareInstance] updateMyReplyQuestionListWithCompletion:^(NSArray *questionList, DPResponseType type) {
        if([questionList count]){
            _weakSelf.datasource = [NSMutableArray arrayWithArray:questionList];
        }else{
            _weakSelf.datasource = [NSMutableArray array];
        }
        if(type == DPResponseType_Failed){
            [DPShortNoticeView showTips:NSLocalizedString(@"BB_TXTID_更新失败",nil) atRootView:self.view];
        }
        [_weakSelf reloadSubviews];
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(showLoadingView:) object:NSLocalizedString(@"BB_TXTID_加载中...", nil)];
        [_weakSelf hideLoading];
    }];
}

- (void)loadMoreUserFollowList
{
    [[DPQuestionUpdateService shareInstance] pullMoreMyReplyQuestionListWithCompletion:^(NSArray *questionList, DPResponseType type) {
//        if([questionList count] > [_weakSelf.datasource count]){
            if([questionList count]){
                _weakSelf.datasource = [NSMutableArray arrayWithArray:questionList];
            }else{
                _weakSelf.datasource = [NSMutableArray array];
            }
            [_weakSelf performSelector:@selector(pullRefreshControlRefreshDone) withObject:nil afterDelay:0.3];
            [_weakSelf reloadSubviews];
//            if(type == DPResponseType_NoMore)
//                [_weakSelf removeUpPullRefreshControl];
//        }else{
//            if([questionList count]){
//                _weakSelf.datasource = [NSMutableArray arrayWithArray:questionList];
//            }else{
//                _weakSelf.datasource = [NSMutableArray array];
//            }
//            [_weakSelf reloadSubviews];
////            [_weakSelf removeUpPullRefreshControl];
//        }
    }];
}

#pragma mark -table view delegate & datasource
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString* reuseIdentifier = @"reuseIdentifier";
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
    if (nil == cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
    }
    
    [_displayEmptyView removeFromSuperview];
    if (_displayType == TableViewType_Empty) {
        UIView* subview = [cell findSubview:@"DPPostCardStyleView" resursion:YES];
        [subview removeFromSuperview];
        [cell addSubview:_displayEmptyView];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    }
    
    
    DPPostCardStyleView* itemView = (DPPostCardStyleView*)[cell viewWithTag:0x1023];
    if ( nil == itemView ) {
        itemView = [[DPPostCardStyleView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 0)];
        itemView.tag = 0x1023;
        [cell addSubview:itemView];
        
        itemView.btnClickBlock = ^(id sender){
            DPDetailViewController* detail = [[DPDetailViewController alloc] initWithPost:sender];
            [_weakSelf.navigationController pushViewController:detail animated:YES];
        };
    }
    id model = _datasource[indexPath.section];
    if ([model isKindOfClass:[NSNumber class]]) {
        DPQuestionModel* contentData = [[DPQuestionUpdateService shareInstance] getQuestionModelWithID:[model integerValue]];
        unsigned int interval = contentData.pubTime;
        NSDate* date = [NSDate dateWithTimeIntervalSince1970:interval];
        
        itemView.datasource = contentData;
        NSString* location = contentData.selfLocDesc;
        if (![location length]) {
            location = contentData.locDesc;
        }
        [itemView setTimeText:[NSDate compareCurrentTime:date] locationInfo:location content:contentData.quest];
        [itemView setReplyNumber:contentData.ansNum upvoteNumber:contentData.likeNum downVoteNumber:contentData.unlikeNum];
        
        itemView.height = [self heightOfCellWithModel:contentData];
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.backgroundColor = [UIColor colorWithColorType:ColorType_WhiteBg];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    if(_displayType == TableViewType_Empty)
        return;
    [self openDetailViewController:indexPath.section];
}

- (void)openDetailViewController:(NSInteger)position
{
    NSNumber* model = _datasource[position];
    DPQuestionModel* contentData = [[DPQuestionUpdateService shareInstance] getQuestionModelWithID:[model integerValue]];
    DPDetailViewController* detail = [[DPDetailViewController alloc] initWithPost:contentData];
    [self.navigationController pushViewController:detail animated:YES];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (_displayType == TableViewType_Empty) {
        return 1;
    }
    return [_datasource count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(_displayType == TableViewType_Empty){
        return tableView.height;
    }
    
    if (indexPath.section >= [_datasource count]) {
        return 0.01;
    }
    NSNumber* model = _datasource[indexPath.section];
    DPQuestionModel* contentData = [[DPQuestionUpdateService shareInstance] getQuestionModelWithID:[model integerValue]];
    return [self heightOfCellWithModel:contentData];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (CGFloat)heightOfCellWithModel:(id) model
{
    CGFloat height = [DPPostCardStyleView otherControlHeight];
    if ([model isKindOfClass:[DPQuestionModel class]]) {
        DPQuestionModel* contentData = (DPQuestionModel*)model;
        height = [DPPostCardStyleView adjustHeightWhenFillWithContent:[contentData quest]];
    }else if ([model isKindOfClass:[NSNumber class]]){
        DPQuestionModel* contentData = [[DPQuestionUpdateService shareInstance] getQuestionModelWithID:[model integerValue]];
        height = [DPPostCardStyleView adjustHeightWhenFillWithContent:[contentData quest]];
    }
    return height;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    return [[UIView alloc] initWithFrame:CGRectZero];
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    if (_displayType == TableViewType_Empty || section >= [_datasource count] - 1) {
        return _size_S(0.01);
    }
    return _size_S(21);
}

#pragma mark -table support delete
//单元格返回的编辑风格，包括删除 添加 和 默认  和不可编辑三种风格
-(UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
//    if (_displayType == TableViewType_Empty) {
//        return UITableViewCellEditingStyleNone;
//    }
//    if(_listType == HomePageType_Question){
//        return UITableViewCellEditingStyleDelete;
//    }
    return UITableViewCellEditingStyleNone;
}

-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle==UITableViewCellEditingStyleDelete) {
        [tableView beginUpdates];
        
        // 获取选中删除行索引值
        NSInteger section = [indexPath section];
        
        // 通过获取的索引值删除数组中的值
        [_datasource removeObjectAtIndex:section];
        
        // 删除单元格的某一行时，在用动画效果实现删除过程
        [tableView deleteSections:[[NSIndexSet alloc] initWithIndex:section] withRowAnimation:UITableViewRowAnimationAutomatic];
        
        [tableView endUpdates];
        
        if (![_datasource count]) {
            [self reloadSubviews];
        }
    }
}

@end
