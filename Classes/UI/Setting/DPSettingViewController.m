//
//  DPSettingViewController.m
//  BiuBiu
//
//  Created by haowenliang on 14/12/21.
//  Copyright (c) 2014年 dpsoft. All rights reserved.
//

#import "DPSettingViewController.h"
#import "SettingCellModel.h"
#import "DPDeviceHelper.h"
#import "SvUDIDTools.h"
#import "DPSetEventHandler.h"

#define CELL_ADDITIONAL_VIEW_INSET _size_S(10)//new 图标和左Label的间距
#define SETTING_CELL_DEFAULT_HEIGHT _size_S(64)//单元高度
#define SETTING_CELL_FOOTER_HEIGHT _size_S(20)//分组间距高度

@interface DPAdditionalTableViewCell : UITableViewCell

@end

@implementation DPAdditionalTableViewCell

- (void)layoutSubviews
{
    [super layoutSubviews];
    UIView* additionView = [self viewWithTag:0x9999];
    if (additionView) {
        additionView.center = CGPointMake(self.textLabel.right + additionView.width/2 + CELL_ADDITIONAL_VIEW_INSET, self.height/2);
    }
}

@end

@interface DPSettingViewController ()<DPSetEventHandlerProtocol>
{
    BOOL _newMsgForFeedBack;
}

@property (nonatomic, strong) NSMutableArray* tableDataSrc;
@property (nonatomic, strong) DPSetEventHandler* eventHandler;

@end

@implementation DPSettingViewController

- (void)dealloc
{
    DPTrace("设置页面释放");
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (BOOL)hidesBottomBarWhenPushed
{
    return YES;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = NSLocalizedString(@"BB_TXTID_设置", @"");
    
    [self resetBackBarButtonWithImage];
    [self initializeTableDataSrc];
    
    _eventHandler = [[DPSetEventHandler alloc] init];
    _eventHandler.delegate = self;
    _eventHandler.eventCtr = self;
}

- (void)initializeTableDataSrc
{
    _tableDataSrc = nil;
    _tableDataSrc = [NSMutableArray new];
    
//    NSMutableArray* section0 = [NSMutableArray array];
//    SettingCellModel* tmp1 = [SettingCellModel new];
//    tmp1.cellTitleTxt = NSLocalizedString(@"BB_TXTID_新评论通知",@"");
//    tmp1.selectionStyle = UITableViewCellSelectionStyleNone;
//    tmp1.accessoryType = DP_TableCell_AccessorySwitch;
//    tmp1.cellValue = DPCellValue_NewReplyNotify;
//    [section0 addObject:tmp1];


    NSMutableArray* section1 = [NSMutableArray array];
    SettingCellModel* tmp2 = [SettingCellModel new];
    tmp2.cellTitleTxt = NSLocalizedString(@"BB_TXTID_用户反馈",@"");
    tmp2.cellDetailTxt = @"";
    tmp2.cellValue = DPCellValue_UserFeedBack;
    [section1 addObject:tmp2];
//    
//    SettingCellModel* tmp10 = [SettingCellModel new];
//    tmp10.cellTitleTxt = NSLocalizedString(@"BB_TXTID_清除缓存",@"");
//    tmp10.accessoryType = DP_TableCell_AccessoryNone;
//    tmp10.cellValue = DPCellValue_ClearCache;
//    tmp10.cellDetailTxt = [DPDeviceHelper cacheFolderSize];
//    [section1 addObject:tmp10];
//    

//    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    // app版本
//    NSString *app_Version = [infoDictionary objectForKey:@"CFBundleShortVersionString"];
    
#if 1
#else
    SettingCellModel* tmp11 = [SettingCellModel new];
    tmp11.cellTitleTxt = NSLocalizedString(@"BB_TXTID_版本更新",@"");
    tmp11.cellDetailTxt = NSLocalizedString(@"BB_TXTID_已是最新版本", @"");
    //[NSString stringWithFormat:@"%@%@",NSLocalizedString(@"BB_TXTID_当前Version", @""),app_Version];
    tmp11.cellValue = DPCellValue_CheckUpdate;
    tmp11.accessoryType = DP_TableCell_AccessoryNone;
    [section1 addObject:tmp11];
#endif
    [_tableDataSrc addObject:section1];
    
    NSMutableArray* section2 = [NSMutableArray array];
    SettingCellModel* tmp20 = [SettingCellModel new];
    tmp20.cellTitleTxt = NSLocalizedString(@"BB_TXTID_关于biubiu",@"");
    tmp20.cellDetailTxt = @"";
    tmp20.cellValue = DPCellValue_AboutBB;
    [section2 addObject:tmp20];
    
    SettingCellModel* tmp21 = [SettingCellModel new];
    tmp21.cellTitleTxt = NSLocalizedString(@"BB_TXTID_联系我们",@"");
    tmp21.cellDetailTxt = @"";
    tmp21.cellValue = DPCellValue_ContactUs;
    [section2 addObject:tmp21];
    
    SettingCellModel* tmp22 = [SettingCellModel new];
    tmp22.cellTitleTxt = NSLocalizedString(@"BB_TXTID_用户协议",@"");
    tmp22.cellDetailTxt = @"";
    tmp22.cellValue = DPCellValue_UserProtocol;
    [section2 addObject:tmp22];
    
    SettingCellModel* tmp23 = [SettingCellModel new];
    tmp23.cellTitleTxt = NSLocalizedString(@"BB_TXTID_给个赞吧！",@"");
    tmp23.cellDetailTxt = @"";
    tmp23.cellValue = DPCellValue_GiveMeFive;
    [section2 addObject:tmp23];
    
    [_tableDataSrc addObject:section2];

//    NSMutableArray* section3 = [NSMutableArray array];
//    
//    NSNumber* close = [[[DPLocalDataManager shareInstance] platformAccInfo] closeAppeal];
//    if (close && [close integerValue] == 3) {
//        
//    }else{
//        SettingCellModel* tmp30 = [SettingCellModel new];
//        tmp30.cellTitleTxt = NSLocalizedString(@"BB_TXTID_致biubiu的老用户",@"");
//        tmp30.cellDetailTxt = nil;
//        tmp30.cellValue = DPCellValue_Appeal;
//        tmp30.accessoryType = DP_TableCell_AccessoryDisclosureIndicator;
//        [section3 addObject:tmp30];
//    }
//    
//    NSNumber* checkin = [[[DPLocalDataManager shareInstance] platformAccInfo] openCheckin];
//    if(appStoreOrAdhoc == (NO) || (checkin && [checkin integerValue] == 3)){
//        SettingCellModel* tmp32 = [SettingCellModel new];
//        tmp32.cellTitleTxt = @"审核工会入口";
//        tmp32.cellDetailTxt = [SvUDIDTools UDID];
//        tmp32.cellValue = DPCellValue_TestGate;
//        tmp32.accessoryType = DP_TableCell_AccessoryDisclosureIndicator;
//        [section3 addObject:tmp32];
//    }
//    
//    [_tableDataSrc addObject:section3];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    UIView* footer = [[UIView alloc] init];
    footer.backgroundColor = [UIColor clearColor];
    return footer;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return SETTING_CELL_FOOTER_HEIGHT;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return SETTING_CELL_DEFAULT_HEIGHT;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [_tableDataSrc count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section >= [_tableDataSrc count])
        return 0;
    NSMutableArray* sectionSrc = [_tableDataSrc objectAtIndex:section];
    return [sectionSrc count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSMutableArray* arr = _tableDataSrc[indexPath.section];
    SettingCellModel* tmp = arr[indexPath.row];
    //重置用户反馈的accessoryType
    if ([tmp cellValue] == DPCellValue_UserFeedBack) {
        [tmp setAccessoryType:_newMsgForFeedBack?DP_TableCell_AccessoryRedPoint:DP_TableCell_AccessoryDisclosureIndicator];
    }
    
    static NSString* reuseIndentifier = @"reuseIdentifier";
    DPAdditionalTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIndentifier];
    if (nil == cell) {
        cell = [[DPAdditionalTableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:reuseIndentifier];
    }
    cell.textLabel.text = tmp.cellTitleTxt;
    cell.textLabel.font = [DPFont systemFontOfSize:FONT_SIZE_LARGE];
    cell.detailTextLabel.text = tmp.cellDetailTxt;
    cell.detailTextLabel.font = [DPFont systemFontOfSize:FONT_SIZE_MIDDLE];
    
    cell.selectionStyle = [tmp selectionStyle];
    cell.userInteractionEnabled = [tmp userInteractionEnabled];
    
    UIView* customAccessView = [self getCustomAccessoryViewForType:[tmp accessoryType]];
    cell.accessoryView = customAccessView;
    cell.accessoryType = (UITableViewCellAccessoryType)[tmp accessoryType];
    //多余的视图
    UIView* additionView = [cell viewWithTag:0x9999];
    [additionView removeFromSuperview];
    //更新
    if([tmp cellValue] == DPCellValue_CheckUpdate)
    {
        if ([DPDeviceHelper biubiuUpdateAppStoreVersion]) {
            DPTrace("有新版本发布");
            UIImageView* newIcon = [[UIImageView alloc] initWithImage:LOAD_ICON_USE_POOL_CACHE(@"bb_new_icon.png")];
            newIcon.tag = 0x9999;
            [cell addSubview:newIcon];
            
            cell.detailTextLabel.text = NSLocalizedString(@"BB_TXTID_有新版本可用", @"");
            cell.selectionStyle = UITableViewCellSelectionStyleDefault;
        }else{
            DPTrace("没有新版本");
            cell.detailTextLabel.text = tmp.cellDetailTxt;
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
    }
    
    return cell;
}

- (UIView*)getCustomAccessoryViewForType:(DP_TableCell_Type)type
{
    switch (type) {
        case DP_TableCell_AccessorySwitch:
        {
            UISwitch *switchView = [[UISwitch alloc] initWithFrame:CGRectZero];
            switchView.onTintColor = [UIColor colorWithColorType:ColorType_NavBar];
            [switchView setOn:NO animated:NO];
            [switchView addTarget:self action:@selector(switchChanged:) forControlEvents:UIControlEventValueChanged];
            
            return switchView;
        }break;
        case DP_TableCell_AccessoryRedPoint:
        {
            UIImageView* redPoint = [[UIImageView alloc] initWithImage:LOAD_ICON_USE_POOL_CACHE(@"bb_redpoint.png")];
            redPoint.backgroundColor = [UIColor clearColor];
            return redPoint;
        }break;
        default:
            break;
    }
    return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSMutableArray* arr = _tableDataSrc[indexPath.section];
    SettingCellModel* tmp = arr[indexPath.row];
    [_eventHandler operationForActionValue:tmp];
}

- (void) switchChanged:(id)sender
{
    UISwitch* switchControl = sender;
    NSLog( @"The switch is %@", switchControl.on ? @"ON" : @"OFF" );
    [_eventHandler newReplyNotifySwitchState:switchControl.on];
}

#pragma mark -Event Delegate

- (void)versionUpdateOpt:(DPSetEventHandler*)handler
{
    [self.tableView reloadData];
}

- (void)feedBackReplyOpt:(DPSetEventHandler *)handler
{
    _newMsgForFeedBack = YES;
    [self.tableView reloadData];
}

@end
