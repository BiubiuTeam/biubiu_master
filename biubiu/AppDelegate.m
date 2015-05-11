//
//  AppDelegate.m
//  biubiu
//
//  Created by haowenliang on 15/1/30.
//  Copyright (c) 2015年 dpsoft. All rights reserved.
//

#import "AppDelegate.h"
#import "AppDelegate+JPush.h"

#import "AppDelegate+BaiduMap.h"
#import "DPHttpService.h"

#import "DPNavigationController.h"
#import "DPNearbyViewController.h"
#import "DPMessageViewController.h"
#import "DPHomePageViewController.h"
#import "DPGroupTopicViewController.h"
#import "DPLbsServerEngine.h"

@interface AppDelegate ()
{
    UIImageView  *_redPointView;
}
@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    [[DPHttpService shareInstance] registOrLoginPlatform];
    // Override point for customization after application launch.
    [self registBaiduMap];
    //注册JPush
    [self registerJPushWithOptions:launchOptions];
    
    _viewControllers = [[NSMutableArray alloc] initWithCapacity:3];
    //UI
    DPNearbyViewController* nearbyViewCtr = [[DPNearbyViewController alloc] init];
//    nearbyViewCtr.title = NSLocalizedString(@"BB_TXTID_附近", @"");
    DPGroupTopicViewController* groupTopic = [[DPGroupTopicViewController alloc] initWithUnionType:UnionListType_Public];
    
    DPMessageViewController* messageViewCtr = [[DPMessageViewController alloc] init];
    messageViewCtr.title = NSLocalizedString(@"BB_TXTID_消息", @"");
    
    DPHomePageViewController* mineViewCtr = [[DPHomePageViewController alloc] init];
    mineViewCtr.title = NSLocalizedString(@"BB_TXTID_我的", @"");
    
    DPNavigationController *navController1 = [[DPNavigationController alloc] initWithRootViewController:nearbyViewCtr];
    DPNavigationController *navController2 = [[DPNavigationController alloc] initWithRootViewController:groupTopic];
    
    DPNavigationController *navController21 = [[DPNavigationController alloc] initWithRootViewController:messageViewCtr];
    DPNavigationController *navController3 = [[DPNavigationController alloc] initWithRootViewController:mineViewCtr];
    
    [_viewControllers addObjectsFromArray:@[navController1,navController2, navController21,navController3]];
    
    _tabBarController = [[UITabBarController alloc] init];
    _tabBarController.viewControllers = _viewControllers;//[NSArray arrayWithObjects:navController1,navController2,navController3, nil];
    _tabBarController.delegate = self;
    _tabBarController.tabBar.translucent = NO;

    UITabBar *tabBar = _tabBarController.tabBar;    
    UITabBarItem *nearbyTab = [tabBar.items objectAtIndex:0];
    UITabBarItem *groupTab = [tabBar.items objectAtIndex:1];
    UITabBarItem *msgTab = [tabBar.items objectAtIndex:2];
    UITabBarItem *mineTab = [tabBar.items objectAtIndex:3];
    
    nearbyTab.title = NSLocalizedString(@"BB_TXTID_附近", @"");
    [nearbyTab setFinishedSelectedImage:[LOAD_ICON_USE_POOL_CACHE(@"tabicon/bb_tabitem_nearby_selected") imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] withFinishedUnselectedImage:[LOAD_ICON_USE_POOL_CACHE(@"tabicon/bb_tabitem_nearby_normal") imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
    groupTab.title = NSLocalizedString(@"BB_TXTID_版块", @"");
    [groupTab setFinishedSelectedImage:[LOAD_ICON_USE_POOL_CACHE(@"tabicon/bb_tabitem_socialty_selected") imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] withFinishedUnselectedImage:[LOAD_ICON_USE_POOL_CACHE(@"tabicon/bb_tabitem_socialty_normal") imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
    
    msgTab.title = NSLocalizedString(@"BB_TXTID_消息", @"");
    [msgTab setFinishedSelectedImage:[LOAD_ICON_USE_POOL_CACHE(@"tabicon/bb_tabitem_message_selected") imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] withFinishedUnselectedImage:[LOAD_ICON_USE_POOL_CACHE(@"tabicon/bb_tabitem_message_normal")imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
    
    mineTab.title = NSLocalizedString(@"BB_TXTID_我的", @"");
    [mineTab setFinishedSelectedImage:[LOAD_ICON_USE_POOL_CACHE(@"tabicon/bb_tabitem_mine_selected") imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] withFinishedUnselectedImage:[LOAD_ICON_USE_POOL_CACHE(@"tabicon/bb_tabitem_mine_normal") imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
    
    _tabBarController.selectedIndex = 0;
    
    [[UITabBarItem appearance] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys: RGBACOLOR(0xa9, 0xa9, 0xa9, 1),UITextAttributeTextColor,[DPFont systemFontOfSize:FONT_SIZE_MIDDLE],  UITextAttributeFont,nil] forState:UIControlStateNormal];
    
    [[UITabBarItem appearance] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor colorWithColorType:ColorType_BlueTxt],UITextAttributeTextColor,[DPFont systemFontOfSize:FONT_SIZE_MIDDLE],  UITextAttributeFont, nil] forState:UIControlStateSelected];
    
    _window =[[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    _window.backgroundColor = [UIColor colorWithColorType:ColorType_WhiteBg];
    _window.rootViewController = _tabBarController;
    [_window makeKeyAndVisible];

    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    [BMKMapView willBackGround];
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // 程序返回后台 重置桌面icon未读数
    
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    //程序进入前台
    
    [application setApplicationIconBadgeNumber:0];
    [application cancelAllLocalNotifications];
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    [BMKMapView didForeGround];
    [[DPLbsServerEngine shareInstance] forceToUpdateLocation];
    
//    if (application) {
//        <#statements#>
//    }
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}
//简单做了红点，建议后续优化
- (UIImageView*)redPointView
{
    if (_redPointView == nil) {
        CGRect tabItemFrame = [AppDelegate frameForTabInTabBar:_tabBarController.tabBar withIndex:2];
        _redPointView = [[UIImageView alloc] initWithFrame:CGRectMake(CGRectGetMidX(tabItemFrame) + 15, tabItemFrame.origin.y, 8, 8)];
        _redPointView.clipsToBounds = YES;
        _redPointView.layer.cornerRadius = 4;
        _redPointView.layer.masksToBounds = YES;
        _redPointView.backgroundColor = [UIColor redColor];
    }
    return _redPointView;
}

- (void)updateTabCounter
{
    UITabBarItem *item = self.tabBarController.tabBar.items[2];
    [[self redPointView] removeFromSuperview];
    if([[DPLocalDataManager shareInstance] hasUnreadMessage]){
        [self.tabBarController.tabBar addSubview:[self redPointView]];
    }else{
        item.badgeValue = nil;
    }
}

+ (CGRect)frameForTabInTabBar:(UITabBar*)tabBar withIndex:(NSUInteger)index
{
    NSUInteger currentTabIndex = 0;
    
    for (UIView* subView in tabBar.subviews)
    {
        if ([subView isKindOfClass:NSClassFromString(@"UITabBarButton")])
        {
            if (currentTabIndex == index)
                return subView.frame;
            else
                currentTabIndex++;
        }
    }
    
    NSAssert(NO, @"Index is out of bounds");
    return CGRectNull;
}

- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController
{
}

@end
