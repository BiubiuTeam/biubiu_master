//
//  AppDelegate+JPush.m
//  biubiu
//
//  Created by haowenliang on 15/5/8.
//  Copyright (c) 2015年 dpsoft. All rights reserved.
//

#import "AppDelegate+JPush.h"
#import "APService.h"
#import "SvUDIDTools.h"
#import "DPQuestionUpdateService.h"
#import "DPDetailViewController.h"

@implementation AppDelegate (JPush)


- (void)registerJPushWithOptions:(NSDictionary *)launchOptions
{
    [self registerRemoteNotification];
    
    // Override point for customization after application launch.
    [APService registerForRemoteNotificationTypes:(UIRemoteNotificationTypeBadge |
                                                   UIRemoteNotificationTypeSound |
                                                   UIRemoteNotificationTypeAlert)
                                       categories:nil];
    [APService setupWithOption:launchOptions];
}

//自定义方法
- (void)registerRemoteNotification
{
#if !TARGET_IPHONE_SIMULATOR
    UIApplication *application = [UIApplication sharedApplication];
    
    //iOS8 注册APNS
    if ([application respondsToSelector:@selector(registerForRemoteNotifications)]) {
        [application registerForRemoteNotifications];
        UIUserNotificationType notificationTypes = UIUserNotificationTypeBadge | UIUserNotificationTypeSound | UIUserNotificationTypeAlert;
        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:notificationTypes categories:nil];
        [application registerUserNotificationSettings:settings];
    }else{
        UIRemoteNotificationType notificationTypes = UIRemoteNotificationTypeBadge |
        UIRemoteNotificationTypeSound |
        UIRemoteNotificationTypeAlert;
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:notificationTypes];
    }
#endif
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    DPTrace(@"%@", [NSString stringWithFormat:@"Device Token: %@", deviceToken]);
    [APService registerDeviceToken:deviceToken];
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error
{
    DPTrace(@"did Fail To Register For Remote Notifications With Error: %@", error);
}

#if __IPHONE_OS_VERSION_MAX_ALLOWED > __IPHONE_7_1
- (void)application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings
{
    
}

// Called when your app has been activated by the user selecting an action from
// a local notification.
// A nil action identifier indicates the default action.
// You should call the completion handler as soon as you've finished handling
// the action.
- (void)application:(UIApplication *)application handleActionWithIdentifier:(NSString *)identifier forLocalNotification:(UILocalNotification *)notification completionHandler:(void (^)())completionHandler
{
    
}

// Called when your app has been activated by the user selecting an action from
// a remote notification.
// A nil action identifier indicates the default action.
// You should call the completion handler as soon as you've finished handling
// the action.
- (void)application:(UIApplication *)application handleActionWithIdentifier:(NSString *)identifier forRemoteNotification:(NSDictionary *)userInfo completionHandler:(void (^)())completionHandler
{
    
}
#endif


- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    [APService handleRemoteNotification:userInfo];
    [self parseNotificationData:userInfo];
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler: (void (^)(UIBackgroundFetchResult))completionHandler {
    
    [APService handleRemoteNotification:userInfo];
    [self parseNotificationData:userInfo];
    
    completionHandler(UIBackgroundFetchResultNewData);
}

- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification
{
    [APService showLocalNotificationAtFront:notification identifierKey:nil];
}

- (void)parseNotificationData:(NSDictionary*)userInfo
{
//    [APService deleteLocalNotificationWithIdentifierKey:[userInfo objectForKey:@"_j_msgid"]];
    NSDictionary* dict = [userInfo objectForKey:@"aps"];
    if ([dict count]) {
         NSInteger badge = [[dict objectForKey:@"badge"] integerValue];
        [[DPLocalDataManager shareInstance] setUnreadMessageCount:badge];
    }
    
    NSDictionary* questionDict = [userInfo objectForKey:@"question"];
    DPQuestionModel* question = nil;
    if (questionDict) {
        question = [[DPQuestionModel alloc] initWithDictionary:questionDict error:nil];
        [[DPQuestionUpdateService shareInstance] replaceMemoryCacheQuestion:question];
    }
    NSLog(@"收到推送: %@",questionDict);
    //如果程序在前台
    //1，设置红点
    [[DPLocalDataManager shareInstance] setHasUnreadMessage:YES];
    [self updateTabCounter];
    
    //2，直接触发列表刷新
//    [[DPLocalDataManager shareInstance] forceToLoadNewestList];
    
#if !TARGET_IPHONE_SIMULATOR
    BOOL isAppActivity = [[UIApplication sharedApplication] applicationState] == UIApplicationStateActive;
    if (isAppActivity) {

    }else if(question){
        //从通知栏点击进入，打开问题详情页
        DPDetailViewController* detail = [[DPDetailViewController alloc] initWithPost:question];
        detail.inputBarIsFirstResponse = NO;
        
        UINavigationController* nav = (UINavigationController*)_tabBarController.selectedViewController;
        if ([nav.topViewController isKindOfClass:[DPDetailViewController class]]) {
            [nav popViewControllerAnimated:NO];
        }
        [nav pushViewController:detail animated:YES];
    }
#endif
}

@end
