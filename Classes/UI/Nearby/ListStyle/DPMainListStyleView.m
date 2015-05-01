//
//  DPMainListStyleView.m
//  BiuBiu
//
//  Created by haowenliang on 15/1/15.
//  Copyright (c) 2015年 dpsoft. All rights reserved.
//

#import "DPMainListStyleView.h"
#import "DPListStyleViewCell.h"
#import "DPListStyleContentView.h"
#import "ListConstants.h"
#import "DPMainEventHandler.h"

//#import "BBPostTable.h"

#import "DPLoadingMessageView.h"
@interface DPMainListStyleView ()
{
    NSInteger _openPosition;
}

@property (nonatomic, strong) DPLoadingMessageView* loadingMessageView;
@end

@implementation DPMainListStyleView

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor clearColor];
        [self setup];
    }
    return self;
}

- (instancetype)init
{
    if (self = [super init]) {
        _frame = CGRectZero;
        [self setup];
    }
    return self;
}

- (void)setup
{
    [self initializedTableView];
    _isEndOfMoreData = NO;
    _isUpPullRefreshing = NO;
    _openPosition = NSIntegerMax;
}

- (void)initializedTableView
{
    self.backgroundColor = [UIColor colorWithColorType:ColorType_DeepGray];
    
    _tableView = [[UITableView alloc] initWithFrame:self.bounds style:UITableViewStylePlain];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
//    _tableView.separatorColor = RGBACOLOR(0xe8, 0xe8, 0xe8, 1);
    _tableView.backgroundColor = [UIColor clearColor];
    _tableView.showsHorizontalScrollIndicator = NO;
    _tableView.showsVerticalScrollIndicator = NO;
    [self addSubview:_tableView];
    
    _loadingMessageView = [[DPLoadingMessageView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, _size_S(44))];
    _loadingMessageView.backgroundColor = [UIColor clearColor];
    _tableView.tableFooterView = _loadingMessageView;
}

- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    _tableView.frame = self.bounds;
}

- (void)setDatasource:(NSMutableArray *)datasource
{
    _datasource = datasource;
    [_tableView reloadData];
}

- (void)startAnimation
{
}

- (void)stopAnimation
{
    
}

- (void)updateFooter:(BOOL)animating withMessage:(NSString*)msg
{
    [_loadingMessageView setLoadingMessage:msg hideLoadingView:!animating];
}

#pragma mark -tableview delegate & datasource

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString* listIdentifier = @"ListStyleIdentifier";
    DPListStyleViewCell* listCell = [tableView dequeueReusableCellWithIdentifier:listIdentifier];
    if (nil == listCell) {
        listCell = [[DPListStyleViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:listIdentifier];
//        listCell.changedBlock = ^(DPListStyleViewCell* cell){
//            NSInteger position = [cell modelInPosition];
//            ListStyleViewState toState = cell.contentState;
//            NSNumber* state = [NSNumber numberWithInteger:toState];
//            if ([state integerValue] == ListStyleViewState_Open) {
//                if (_openPosition < [_datasource count]) {
//                    DPListStyleViewCell* lastCell = (DPListStyleViewCell* )[_tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:_openPosition inSection:0]];
//                    [lastCell didClickLeftView];
//                }
//                _openPosition = position;
//            }else if(position == _openPosition){
//                _openPosition = NSIntegerMax;
//            }
//        };
        
        listCell.clickBlock = ^(DPListStyleViewCell* cell){
            NSInteger position = [cell modelInPosition];
            if (_eventHandler) {
                [_eventHandler openBiuBiuDetailViewController:_datasource[position]];
            }
        };
    }
    listCell.modelInPosition = indexPath.row;
    [listCell setPostContentModel:_datasource[indexPath.row]];
    if (_openPosition == indexPath.row) {
        [listCell setContentState:ListStyleViewState_Open];
    }else if(listCell.contentState != ListStyleViewState_None){
        [listCell setContentState:ListStyleViewState_Close];
    }
    return listCell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return DP_CELL_DEFAULT_HEIGHT;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_datasource count];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    //判断是否拉到底部，触发加载更多
    if (scrollView.contentOffset.y + scrollView.bounds.size.height >= scrollView.contentSize.height + _size_S(44)+ _size_S(20)) {
        if (!_isUpPullRefreshing && !_isEndOfMoreData && [_datasource count])
        {
            _isUpPullRefreshing = YES;
            if (_loadMoreOpt) {
                _loadMoreOpt(self);
            }
        }
    }
}

@end
