//
//  DPGroupTopicViewController.m
//  biubiu
//
//  Created by haowenliang on 15/3/24.
//  Copyright (c) 2015年 dpsoft. All rights reserved.
//

#import "DPGroupTopicViewController.h"
#import "DPUnionCreateViewController.h"
#import "DPSociatyModel.h"
#import "UIImageView+AsyncImage.h"
#import "DPLbsServerEngine.h"
#import "DPHttpService+Sociaty.h"
#import "DPInternetService.h"
#import "DPUnionPostViewController.h"
#import "DPLbsServerEngine.h"
#import "DPShortNoticeView.h"
#import "DPLocalDataManager.h"
#import "DPEmptyView.h"

#import "DPNavLocationView.h"
@interface DPGroupTopicViewController ()
{
    TableViewType _viewType;
}
@property (nonatomic, strong) NSMutableArray* sociatyArray;

@end

@implementation DPGroupTopicViewController

- (instancetype)initWithUnionType:(UnionListType)type
{
    if (self = [super init]) {
        _unionType = type;
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(locationWillStartUpdate:) name:DPLocationWillStartUpdate object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(locationDidUpdate:) name:DPLocationDidEndUpdate object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(unionListCallback:) name:kPullUnionListResult object:nil];
   
    [self.tableView setShowsHorizontalScrollIndicator:NO];
    [self.tableView setShowsVerticalScrollIndicator:NO];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;

//    if ([[DPLocalDataManager shareInstance] platformAccInfo].otherLikeNum > 10) {
        [self resetRightBarButtonWithNormal:@"bb_union_create_normal.png" highLighted:@"bb_union_create_pressed.png" andSel:@selector(openSociatyCreateViewController)];
//    }
    [self removeTableHeaderView];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (![_sociatyArray count]) {
        [self updateUnionListOfPublic];
    }
    [self reloadData];
}

- (void)randomAccessOneTopic
{
    NSInteger count = [_sociatyArray count];
    if (count > 0) {
        NSInteger index = random()%count;
        DPSociatyModel* model = _sociatyArray[index];
        DPUnionPostViewController* postCtr = [[DPUnionPostViewController alloc] initWithUnionId:[model.unionId integerValue]];
        postCtr.title = model.unionName;
        [self.navigationController pushViewController:postCtr animated:YES];
    }
//    else{
//        [DPShortNoticeView showTips:@"当前版块" atRootView:self.tableView];
//    }
}

- (void)reloadData
{
    [self pullRefreshControlRefreshDone];
    
    TableViewType checkType = TableViewType_Empty;
    if(NO == [[DPLbsServerEngine shareInstance] isEnabledAndAuthorize]) {
//        checkType = TableViewType_Lbs;
    }
    if ([_sociatyArray count]){
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
        if ([_sociatyArray count] > 10) {
            [self addUpPullRefreshControl];
        }else{
            [self removeUpPullRefreshControl];
        }
    }
    
    _viewType = checkType;
    [self.tableView reloadData];
    [self pullRefreshControlUpdatePosition];
    
    if(_unionType == UnionListType_Public){
        if (_viewType == TableViewType_Plain) {
            DPNavLocationView* locationBtn = [[DPNavLocationView alloc] initWithFrame:CGRectMake(5.0, 0, 0, 0)];
            [locationBtn setLbsLabelContent:NSLocalizedString(@"BB_TXTID_随便看看", nil)];
            [locationBtn updateLayerContent:LOAD_ICON_USE_POOL_CACHE(@"bb_random_normal.png")];
            [locationBtn addTarget:self action:@selector(randomAccessOneTopic) forControlEvents:UIControlEventTouchUpInside];
            locationBtn.needsHighlightImage = YES;
            [self resetLeftBarButtonWithButton:locationBtn];
        }else{
            [self removeLeftNavigationBarButton];
        }
    }else{
        [self resetBackBarButtonWithImage];
    }
}

- (void)unionListCallback:(NSNotification*)notification
{
    if([[notification.userInfo objectForKey:@"type"] integerValue] != _unionType){
        return;
    }
    
    NSArray* list = [notification.userInfo objectForKey:kNotification_ReturnObject];
    if ([list count]) {
        self.sociatyArray = [NSMutableArray arrayWithArray:list];
        [self reloadData];
    }
}

//- (void)onAccountInfoUpdate:(NSNotification*)notification
//{
//    NSDictionary* userInfo = [notification userInfo];
//    if (userInfo && [userInfo count]) {
//        NSInteger retCode = [[userInfo objectForKey:kNotification_StatusCode] integerValue];
//        if (retCode == 0) {
//            BackSourceInfo_1004* rspObject = [userInfo objectForKey:kNotification_ReturnObject];
//            BackendReturnData_1004* obj = rspObject.returnData;
//            if (obj.otherLikeNum > 10) {
//                [self resetRightBarButtonWithNormal:@"bb_union_create_normal.png" highLighted:@"bb_union_create_pressed.png" andSel:@selector(openSociatyCreateViewController)];
//            }
//        }
//    }
//}

- (void)locationDidUpdate:(NSNotification*)notification
{
    [self updateUnionListOfPublic];
}

- (void)openSociatyCreateViewController
{
    if ([[[DPLocalDataManager shareInstance] platformAccInfo].creUnionFlag boolValue] || [[DPLocalDataManager shareInstance] platformAccInfo].otherLikeNum > 10) {
        DPUnionCreateViewController* unionCreator = [[DPUnionCreateViewController alloc] init];
        [self.navigationController pushViewController:unionCreator animated:YES];
        return;
    }
    [self showErrorTips:NSLocalizedString(@"BB_TXTID_未成年人不能进入", @"")];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
        [self performSelector:@selector(downRefreshOpt) withObject:nil afterDelay:0.3];
    }else if (orientation == EGOPullOrientationUp){
        [self performSelector:@selector(loadMoreUnionListOfPublic) withObject:nil afterDelay:0.3];
    }
    [self performSelector:@selector(pullRefreshControlRefreshDone) withObject:nil afterDelay:10.0f];
}

//先更新地理位置信息，再更新数据
- (void)downRefreshOpt
{
    [[DPLbsServerEngine shareInstance] forceToUpdateLocation];
}

- (void)updateUnionListOfPublic
{
    [[DPHttpService shareInstance] excuteCmdToPullSociaties:1 lastId:0 type:_unionType latitude:[[DPLbsServerEngine shareInstance] latitude] logitude:[[DPLbsServerEngine shareInstance] longitude]];
}

- (void)loadMoreUnionListOfPublic
{
    DPSociatyModel* model = [_sociatyArray lastObject];
    [[DPHttpService shareInstance] excuteCmdToPullSociaties:1 lastId:[model.sortId integerValue] type:_unionType latitude:[[DPLbsServerEngine shareInstance] latitude] logitude:[[DPLbsServerEngine shareInstance] longitude]];
}

- (void)showErrorTips:(NSString*)message
{
    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:nil message:message delegate:nil cancelButtonTitle:nil otherButtonTitles:NSLocalizedString(@"BB_TXTID_确定", nil), nil];
    [alert show];
}

#pragma mark - table view delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (_viewType != TableViewType_Plain && _viewType != TableViewType_Group) {
        return SCREEN_HEIGHT - [self getNavStatusBarHeight];
    }
    return _size_S(88);
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (_viewType != TableViewType_Plain && _viewType != TableViewType_Group) {
        return;
    }
    if (indexPath.row < [_sociatyArray count]) {
        DPSociatyModel* model = _sociatyArray[indexPath.row];
        DPUnionPostViewController* postCtr = [[DPUnionPostViewController alloc] initWithUnionId:[model.unionId integerValue]];
        postCtr.title = model.unionName;
        [self.navigationController pushViewController:postCtr animated:YES];
    }
}

#pragma mark - table view datasource


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (_viewType != TableViewType_Plain && _viewType != TableViewType_Group) {
        return 1;
    }
    return [_sociatyArray count];
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
            empty = [DPEmptyView getEmptyViewWithFrame:epframe viewType:DPEmptyViewType_TopicListEmpty];
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
    
    static NSString* identifier = @"SociatyIdentifier";
    SociatyViewCell* cell = nil;
    cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (nil == cell) {
        cell = [[SociatyViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:identifier];
    }
    
    if (indexPath.row < [_sociatyArray count]) {
        DPSociatyModel* model = _sociatyArray[indexPath.row];
        [cell setSociaty:model];
    }else{
        [cell setSociaty:nil];
    }
    
    return cell;
}

@end

@interface SociatyViewCell ()

@end

@implementation SociatyViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.selectionStyle = UITableViewCellSelectionStyleDefault;
        [self addSubview:self.sociatyLogo];
        
        self.textLabel.textColor = [UIColor colorWithColorType:ColorType_DeepTxt];
        self.textLabel.font = [DPFont systemFontOfSize:FONT_SIZE_LARGE];
        
        self.detailTextLabel.textColor = [UIColor colorWithColorType:ColorType_BlueTxt];
        self.detailTextLabel.font = [DPFont systemFontOfSize:FONT_SIZE_LARGE];

        [self addSubview:self.ptIcon];
        [self addSubview:self.ptName];
    }
    return self;
}

- (UIImageView *)sociatyLogo
{
    if (nil == _sociatyLogo) {
        _sociatyLogo = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, _size_S(56), _size_S(56))];
        _sociatyLogo.layer.cornerRadius = _size_S(28);
        _sociatyLogo.layer.masksToBounds = YES;
        [_sociatyLogo setImage:[UIImage imageWithColor:RGBACOLOR(0xee, 0xee, 0xee, 1)]];
    }
    return _sociatyLogo;
}

- (void)setSociaty:(DPSociatyModel *)sociaty
{
    if (_sociaty == sociaty) {
        return;
    }
    _sociaty = sociaty;
    [_sociatyLogo setImage:[UIImage imageWithColor:RGBACOLOR(0xee, 0xee, 0xee, 1)]];
    if (_sociaty) {
        NSString* picPath = _sociaty.picPath;
        if ([picPath length]) {
            //async url image
            [self.sociatyLogo setImageURL:[NSURL URLWithString:picPath]];
        }
        self.textLabel.text = _sociaty.unionName;
        self.detailTextLabel.text = [NSString stringWithFormat: NSLocalizedString(@"BB_TXTID_%zd条内容", nil),[_sociaty.questionNum integerValue]];
        
        //版块地理位置
        SociatyType type = SociatyType_Public;
        NSString* name = _sociaty.locDesc;
        if ([name length]) {
            type = SociatyType_School;
        }else{
            NSInteger dist = [_sociaty.distance integerValue];
            if (dist < 3) {
                name = [NSString stringWithFormat:@"< 3 km"];
            }else{
                name = [NSString stringWithFormat:@"%zd km",dist];
            }
        }
        [self setPtType:type ptName:name];
    }else{
        self.textLabel.text = nil;
        self.detailTextLabel.text = nil;
        _ptIcon.backgroundColor = [UIColor clearColor];
        _ptIcon.text = nil;
        _ptName.text = nil;
    }
}

- (UILabel *)ptIcon
{
    if (_ptIcon == nil) {
        _ptIcon = [[UILabel alloc] initWithFrame:CGRectZero];
        _ptIcon.textColor = [UIColor colorWithColorType:ColorType_WhiteTxt];
        _ptIcon.textAlignment = NSTextAlignmentCenter;
        _ptIcon.font = [DPFont systemFontOfSize:FONT_SIZE_MIDDLE];
    }
    return _ptIcon;
}

- (UILabel *)ptName
{
    if (_ptName == nil) {
        _ptName = [[UILabel alloc] initWithFrame:CGRectZero];
        _ptName.textColor = [UIColor colorWithColorType:ColorType_LightTxt];
        _ptName.textAlignment = NSTextAlignmentCenter;
        _ptName.font = [DPFont systemFontOfSize:FONT_SIZE_MIDDLE];
    }
    return _ptName;
}

- (void)setPtType:(SociatyType)type ptName:(NSString*)name
{
    if (type == SociatyType_School) {
        _ptIcon.text = NSLocalizedString(@"BB_TXTID_校", nil);
        _ptIcon.backgroundColor = [UIColor colorWithColorType:ColorType_NavBar];
    }else{
        _ptIcon.text = NSLocalizedString(@"BB_TXTID_距", nil);
        _ptIcon.backgroundColor = [UIColor colorWithColorType:ColorType_OriginColor];
    }
    _ptName.text = name;
    
    [_ptIcon sizeToFit];
    [_ptName sizeToFit];
    
    _ptIcon.width = _ptIcon.width + _size_S(16);
    
    _ptName.height = _ptIcon.height = _ptIcon.height + _size_S(0);
    
    _ptIcon.layer.cornerRadius = _ptIcon.height/2;
    _ptIcon.layer.masksToBounds = YES;
}

- (void)setupUiAtrribute
{
    CGFloat insetY = _size_S(2);
    
    _sociatyLogo.left = _size_S(16);
    _sociatyLogo.centerY = self.height/2;
    
    _ptIcon.left = self.textLabel.left = _sociatyLogo.right + _size_S(12);
    self.textLabel.top = _sociatyLogo.top + insetY;
    self.detailTextLabel.right = SCREEN_WIDTH - _size_S(16);
    
    _ptName.left = CGRectGetMaxX(_ptIcon.frame) + _size_S(8);
    
    _ptIcon.bottom = _ptName.bottom = _sociatyLogo.bottom - insetY;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    [self setupUiAtrribute];
}

@end
