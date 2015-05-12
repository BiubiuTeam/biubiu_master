//
//  DPSetEventHandler.m
//  BiuBiu
//
//  Created by haowenliang on 14/12/21.
//  Copyright (c) 2014年 dpsoft. All rights reserved.
//

#import "DPSetEventHandler.h"
#import "DPImageViewController.h"
#import "DPDeviceHelper.h"
#import "DPWebViewController.h"
#import "DPContactUsViewController.h"
#import "DPFeedBackViewController.h"
#import "DPShortNoticeView.h"
#import "DPHttpService.h"
#import "DPUnionCheckInViewController.h"
@interface DPSetEventHandler ()<UIActionSheetDelegate>

@end

@implementation DPSetEventHandler

- (instancetype)init
{
    if (self = [super init]) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(versionUpdateOpt:) name:@"KNOTIFICATION_VERSION_UPDATE" object:nil];
    }
    return self;
}

- (void)dealloc
{
    self.eventCtr = nil;
    self.delegate = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (UIViewController *)eventCtr
{
    if (nil == _eventCtr) {
        if (_delegate && [_delegate isKindOfClass:[UIViewController class]]) {
            return (UIViewController*)_delegate;
        }
        //取当前栈顶的ViewController
        
    }
    return _eventCtr;
}


- (void)versionUpdateOpt:(NSNotification*)notification
{
    if (_delegate && [_delegate respondsToSelector:@selector(versionUpdateOpt:)]) {
        [_delegate versionUpdateOpt:self];
    }
}

- (void)operationForActionValue:(SettingCellModel*)cellModel
{
    NSString* title = cellModel.cellTitleTxt;
    
    switch (cellModel.cellValue) {
        case DPCellValue_NewReplyNotify:
            break;
        case DPCellValue_Nonthing:{
            UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
            [pasteboard setString:cellModel.cellDetailTxt];
            [DPShortNoticeView showTips:@"Copy Done" atRootView:self.eventCtr.view];
            return;
        }break;
        case DPCellValue_AboutBB:
        {
            NSString* imgName = NSLocalizedString(@"BB_SRCID_AboutBiubiu", nil);
            UIImage* image = LOAD_ICON_USE_POOL_CACHE(imgName);
            DPImageViewController* ctr = [[DPImageViewController alloc] initWithImage:image];
//            DPWebViewController* ctr = [[DPWebViewController alloc] initWithHtml:@"resource/about/about"];
            ctr.title = title;//NSLocalizedString(@"BB_TXTID_关于biubiu", @"");
            [[self.eventCtr navigationController] pushViewController:ctr animated:YES];
            
        }break;
        case DPCellValue_CheckUpdate:
        {
            if ([DPDeviceHelper biubiuUpdateAppStoreVersion])
            {
#if appStoreOrAdhoc
                NSString* str = @"https://itunes.apple.com/us/app/pu-su-nong-li/id966457609?l=zh&ls=1&mt=8";
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:str]];
#else
                [DPDeviceHelper installAppNewVersionFromPGY];
#endif
            }else {
                //如果没有更新，无需跳转
#if !appStoreOrAdhoc
                [DPDeviceHelper openDetailsOfAppFromPGY];
#endif
                return;
            }
        }break;
        case DPCellValue_ContactUs:
        {
            DPContactUsViewController* ctr = [[DPContactUsViewController alloc] init];
            [[self.eventCtr navigationController] pushViewController:ctr animated:YES];
        }break;
        case DPCellValue_UserFeedBack:
        {
            DPFeedBackViewController* ctr = [[DPFeedBackViewController alloc] init];
            [[self.eventCtr navigationController] pushViewController:ctr animated:YES];
        }break;
        case DPCellValue_ClearCache:
        {
            UIActionSheet* sheet = [[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"BB_TXTID_是否确定清除缓存数据",nil) delegate:self cancelButtonTitle:NSLocalizedString(@"BB_TXTID_取消",nil) destructiveButtonTitle:NSLocalizedString(@"BB_TXTID_清除缓存",nil) otherButtonTitles:nil, nil];
            
            [sheet showInView:self.eventCtr.view];
        }break;
        case DPCellValue_UserProtocol:
        {
            NSString* fileName = NSLocalizedString(@"BB_SRCID_Protocol", nil);
            DPWebViewController* ctr = [[DPWebViewController alloc] initWithHtml:fileName];
            ctr.canResetTitle = NO;
            ctr.title = title;//NSLocalizedString(@"BB_TXTID_用户协议", @"");
            [[self.eventCtr navigationController] pushViewController:ctr animated:YES];
        }break;
        case DPCellValue_GiveMeFive: //跳转AppStore
        {
            NSString* str = @"https://itunes.apple.com/us/app/pu-su-nong-li/id966457609?l=zh&ls=1&mt=8";
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:str]];
        }break;
        case DPCellValue_TestGate:
        {
            DPUnionCheckInViewController* ctr = [[DPUnionCheckInViewController alloc] init];
            [[self.eventCtr navigationController] pushViewController:ctr animated:YES];
        }break;
        default:
            break;
    }
}

- (void)newReplyNotifySwitchState:(BOOL)isOn
{
    NSNumber* number = isOn?@1:@2;
    __block NSDictionary* dict = @{@"isPush":number};
    [[DPHttpService shareInstance] updatePlatformSetting:dict completion:^(id json, JSONModelError *err) {
        if (err == nil) {
            BackSourceInfo* backSource = [[BackSourceInfo alloc] initWithDictionary:json error:&err];
            if (backSource.statusCode == 0) {
                NSNumber* ispush = [dict objectForKey:@"isPush"];
                BOOL isOn = [ispush integerValue] == 1?YES:NO;
                NSUserDefaults *accountDefaults = [NSUserDefaults standardUserDefaults];
                [accountDefaults setObject:@(isOn) forKey:@"_NewMessagePush_"];
                [accountDefaults synchronize];
            }
        }
    }];
}

- (BOOL)isNewMessagePushOn
{
    NSUserDefaults *accountDefaults = [NSUserDefaults standardUserDefaults];
    NSNumber* pushOn = [accountDefaults objectForKey:@"_NewMessagePush_"];
    if(pushOn == nil || [pushOn boolValue])
        return YES;
    return NO;
}

@end
