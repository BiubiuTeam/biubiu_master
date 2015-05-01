//
//  DPHomePageViewController.m
//  biubiu
//
//  Created by haowenliang on 15/1/31.
//  Copyright (c) 2015年 dpsoft. All rights reserved.
//

#import "DPHomePageViewController.h"
#import "DPHomeTopView.h"
#import "DPLocalDataManager.h"
#import "DPHttpService.h"
#import "BackSourceInfo_1004.h"

#import "DPPostListViewController.h"
#import "DPSettingViewController.h"
#import "DPGroupTopicViewController.h"

@implementation HomePageTableModel

@end

@interface DPHomePageViewController ()<UITableViewDataSource,UITableViewDelegate>
{
    DPHomeTopView* _bgImgView;
}
@property (nonatomic, strong) BackendReturnData_1004* accountModel;
@property (nonatomic, strong) NSMutableArray* datasource;

@end

@implementation DPHomePageViewController

- (instancetype)init
{
    if (self = [super init]) {
        [DPLocalDataManager shareInstance];
    }
    return self;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onPlatformAccountInfoUpdate:) name:kNotification_UpdateAccountInfo object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(newPostHomePageCallback:) name:kNotification_NewPostCallBack object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(newPostHomePageCallback:) name:kNotification_AnswerPostCallBack object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(newPostHomePageCallback:) name:kNotification_FeedbackPost object:nil];
    
    [self resetRightBarButtonWithNormal:@"bb_homepage_set_normal.png" highLighted:@"bb_homepage_set_press.png" andSel:@selector(openSettingViewController)];
    
    self.tableView.tableHeaderView = [[UIView alloc] initWithFrame:CGRectZero];
    self.tableView.separatorColor = RGBACOLOR(0xd0, 0xd0, 0xd0, 1);
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    
    [self initializeDatasource];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self forceToUpdatePlatformInfo];
}

- (void)forceToUpdatePlatformInfo
{
    [[DPLocalDataManager shareInstance] loadPlatformAccountInfoCompletion:^(BOOL succeed, BackendReturnData_1004 *result) {
        if (result) {
            self.accountModel = result;
            [self updateAppearanceWithAccountInfo];
        }
    }];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    [_bgImgView stopRunloopProgress];
}

- (void)newPostHomePageCallback:(NSNotification*)notification
{
}

//- (void)onPlatformAccountInfoUpdate:(NSNotification*)notification
//{
//    NSDictionary* userInfo = [notification userInfo];
//    if (userInfo && [userInfo count]) {
//        NSInteger retCode = [[userInfo objectForKey:kNotification_StatusCode] integerValue];
//        if (retCode == 0) {
//            BackSourceInfo_1004* rspObject = [userInfo objectForKey:kNotification_ReturnObject];
//            self.accountModel = rspObject.returnData;
//            [self updateAppearanceWithAccountInfo];
//        }
//    }
//}

- (void)loadView
{
    [super loadView];
    CGRect bframe = self.view.bounds;
    bframe.size.height = bframe.size.height - [self getBarsHeight];
    
    _bgImgView = [[DPHomeTopView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, _size_S(200))];
    _bgImgView.contentMode = UIViewContentModeScaleAspectFit;
    
    self.tableView.showsHorizontalScrollIndicator = NO;
    self.tableView.showsVerticalScrollIndicator = NO;
    
    [_bgImgView setUserAchiveCount:0 level:0];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)initializeDatasource
{
    _datasource = [[NSMutableArray alloc] initWithCapacity:1];
    
    //顶部占位数据
    HomePageTableModel* model0 = [[HomePageTableModel alloc] init];
    [_datasource addObject:@[model0]];
    
    HomePageTableModel* model1 = [[HomePageTableModel alloc] init];
    model1.title = NSLocalizedString(@"BB_TXTID_我的提问",nil);
    model1.content = @"0";
    model1.style = HomePageType_Question;
    
    HomePageTableModel* model2 = [[HomePageTableModel alloc] init];
    model2.title = NSLocalizedString(@"BB_TXTID_我的回答",nil);
    model2.content = @"0";
    model2.style = HomePageType_Answer;
    
    [_datasource addObject:@[model1,model2]];
}

#pragma mark -
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [_datasource count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSArray* subArr = _datasource[section];
    return [subArr count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString* cellIdentifier = @"HomePageIdentifier";
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (nil == cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellIdentifier];
        
        cell.textLabel.font = [DPFont systemFontOfSize:FONT_SIZE_LARGE];
        cell.textLabel.textColor = [UIColor colorWithColorType:ColorType_DeepTxt];
        cell.detailTextLabel.font = [DPFont systemFontOfSize:FONT_SIZE_LARGE];
        cell.detailTextLabel.textColor = [UIColor colorWithColorType:ColorType_LightTxt];
    }
    
    if (indexPath.section == 0) {
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        [cell addSubview:_bgImgView];
        cell.backgroundColor = [UIColor clearColor];
        cell.accessoryType = UITableViewCellAccessoryNone;
        return cell;
    }
    
    NSArray* subArr = _datasource[indexPath.section];
    HomePageTableModel* model = subArr[indexPath.row];
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.backgroundColor = [UIColor whiteColor];
    
    cell.textLabel.text = model.title;
    cell.detailTextLabel.text = model.content;
    
    cell.textLabel.centerY = cell.detailTextLabel.centerY = cell.accessoryView.centerY;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    if (indexPath.section == 0) {
        return;
    }
    [self optHandlerCellSelected:indexPath];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0 && indexPath.row == 0) {
        return _bgImgView.height;
    }
    
    return _size_S(63.0);
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 0.001;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    return [[UIView alloc] initWithFrame:CGRectZero];
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
//    if (section == 0 || section == 1) {
//        return _size_S(16);
//    }
//    
    return _size_S(16);
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    UIView* foot = [[UIView alloc] initWithFrame:CGRectZero];
    [foot setBackgroundColor:[UIColor clearColor]];
    
    return foot;
}

#pragma mark -数据源

- (void)updateAppearanceWithAccountInfo
{
    [self modifyDatasource];
    [_bgImgView setUserAchiveCount:[_accountModel otherLikeNum] level:(float)([[_accountModel rankRate] floatValue]/100)];
    [self.tableView reloadData];
}

- (void)modifyDatasource
{
    NSArray* subArr = [_datasource objectAtIndex:1];
    for(HomePageTableModel* model in subArr){
        if (model.style == HomePageType_Question) {
            model.content = [NSString stringWithFormat:@"%zd",[_accountModel questionNum]];
        }else if (model.style == HomePageType_Answer){
            model.content = [NSString stringWithFormat:@"%zd",[_accountModel answerNum]];
        }
    }
    
    if([[_accountModel unionNum] integerValue] > 0){
        //存在工会
        if ([_datasource count] < 3) {
            HomePageTableModel* model3 = [[HomePageTableModel alloc] init];
            model3.title = NSLocalizedString(@"BB_TXTID_我的版块",nil);
            model3.content = [NSString stringWithFormat:@"%@",[_accountModel unionNum]];
            model3.style = HomePageType_Union;
            [_datasource addObject:@[model3]];
        }else{
            NSArray* array = [_datasource objectAtIndex:2];
            HomePageTableModel* model = [array firstObject];
            model.content = [NSString stringWithFormat:@"%@",[_accountModel unionNum]];
        }
    }else{
        //没有工会
        if ([_datasource count] > 2) {
            NSArray* subArr = [_datasource objectAtIndex:2];
            NSMutableArray* array = [NSMutableArray arrayWithArray:subArr];
            for (HomePageTableModel* model in subArr) {
                if (model.style == HomePageType_Union) {
                    [array removeObjectAtIndex:[subArr indexOfObject:model]];
                }
            }
        }
    }
}

- (void)optHandlerCellSelected:(NSIndexPath*)indexPath
{
    NSArray* subArr = _datasource[indexPath.section];
    HomePageTableModel* model = subArr[indexPath.row];
    if (model.style == HomePageType_Union) {
        //打开我的版块列表页面
        DPGroupTopicViewController* unionCtr = [[DPGroupTopicViewController alloc] initWithUnionType:UnionListType_Mine];
        unionCtr.title = model.title;
        unionCtr.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:unionCtr animated:YES];
        return;
    }
    
    DPPostListViewController* postlist = [[DPPostListViewController alloc] initWithPostListStyle:model.style];
    postlist.title = model.title;
    postlist.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:postlist animated:YES];
}

- (void)openSettingViewController
{
    DPSettingViewController* setting = [[DPSettingViewController alloc] init];
    [self.navigationController pushViewController:setting animated:YES];
}

@end
