//
//  DPUnionCheckInViewController.m
//  biubiu
//
//  Created by haowenliang on 15/3/26.
//  Copyright (c) 2015年 dpsoft. All rights reserved.
//

#import "DPUnionCheckInViewController.h"
#import "DPShortNoticeView.h"
#import "DPSociatyModel.h"

#import "DPHttpService+Sociaty.h"
#include <objc/runtime.h>
#import "DPGroupTopicViewController.h"

@interface CheckInCell : SociatyViewCell

@end

@implementation CheckInCell


- (void)setSociaty:(DPSociatyModel *)sociaty
{
    [super setSociaty:sociaty];
    
    self.detailTextLabel.text = [NSString stringWithFormat:@"%@",sociaty.unionId];
}

@end

@interface DPUnionCheckInViewController ()<UIActionSheetDelegate>

@property (nonatomic, strong) NSMutableArray* sociatyArray;

@end

@implementation DPUnionCheckInViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self.tableView setShowsHorizontalScrollIndicator:NO];
    [self.tableView setShowsVerticalScrollIndicator:NO];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    self.sociatyArray = [NSMutableArray array];
    
    [self resetBackBarButtonWithImage];
    self.title = @"工会审核测试页面";
    [self removeTableHeaderView];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(unionListCallback:) name:kPullCheckingUnionListResult object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(unionCheckinCallback:) name:kCheckingUnionResult object:nil];
    [[DPHttpService shareInstance] excuteCmdToLoadCheckingUnions:1 lastId:0];
}

- (void)unionListCallback:(NSNotification*)notification
{
    NSArray* list = [notification.userInfo objectForKey:kNotification_ReturnObject];
    if ([list count]) {
        [list enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            NSLog(@"%@",obj);
            
            if ([obj isKindOfClass:[DPSociatyModel class]]) {
                DPSociatyModel* model = (DPSociatyModel*)obj;
                [_sociatyArray addObject:model];
            }
        }];
        [self.tableView reloadData];
    }
}

- (void)unionCheckinCallback:(NSNotification*)notification
{
    NSDictionary* userInfo = notification.userInfo;
    NSString* tips = @"";
    if ([[userInfo objectForKey:kNotification_StatusCode] integerValue] == 0) {
        //操作成功
        NSArray* comfirm = [userInfo objectForKey:@"unionConfirmId"];
        NSArray* reject = [userInfo objectForKey:@"unionBanId"];
        NSNumber* value = @(0);
        if([comfirm count]){
            //通过操作
            value = [comfirm firstObject];
            tips = [NSString stringWithFormat:@"通过%@操作成功",[comfirm firstObject]];
        }else if([reject count]){
            //取消操作
            value = [reject firstObject];
            tips = [NSString stringWithFormat:@"拒绝%@操作成功",[reject firstObject]];
        }
        
        __block DPSociatyModel* model = nil;
        [_sociatyArray enumerateObjectsUsingBlock:^(DPSociatyModel* obj, NSUInteger idx, BOOL *stop) {
            if ([obj.unionId integerValue] == [value integerValue]) {
                model = obj;
                *stop = YES;
            }
        }];
        if (model) {
            [_sociatyArray removeObject:model];
            [self.tableView reloadData];
        }
        
        [DPShortNoticeView showTips:tips atRootView:self.view];
    }else{
        [DPShortNoticeView showTips:@"操作失败" atRootView:self.view];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - table view delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return _size_S(88);
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    if (indexPath.row < [_sociatyArray count]) {
        DPSociatyModel* model = _sociatyArray[indexPath.row];

        [self showSheet:model];
    }
}

- (void)showSheet:(DPSociatyModel*)model
{
    UIActionSheet *actionSheet = [[UIActionSheet alloc]
                                  initWithTitle:nil
                                  delegate:self
                                  cancelButtonTitle:@"取消"
                                  destructiveButtonTitle:nil
                                  otherButtonTitles:@"通过", @"拒绝",nil];
    
    actionSheet.actionSheetStyle = UIActionSheetStyleBlackOpaque;
    
    objc_setAssociatedObject(actionSheet, "AssociatedDelegateObject", model, OBJC_ASSOCIATION_RETAIN_NONATOMIC);

    [actionSheet showInView:self.view];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    // later try to get the object:
    DPSociatyModel* model = objc_getAssociatedObject(actionSheet, "AssociatedDelegateObject");
    
    if (buttonIndex == 0) {
        [[DPHttpService shareInstance] excuteCmdToCheckingTheUnions:[model.unionId integerValue] passed:YES];
    }else if (buttonIndex == 1) {
        [[DPHttpService shareInstance] excuteCmdToCheckingTheUnions:[model.unionId integerValue] passed:NO];
    }
    // process the associated object, then release it:
    objc_removeAssociatedObjects(actionSheet);
}

- (void)actionSheetCancel:(UIActionSheet *)actionSheet
{
    // process the associated object, then release it:
    objc_removeAssociatedObjects(actionSheet);
}
#pragma mark - table view datasource


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_sociatyArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString* identifier = @"SociatyIdentifier";
    CheckInCell* cell = nil;
    cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (nil == cell) {
        cell = [[CheckInCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:identifier];
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
