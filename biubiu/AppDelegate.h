//
//  AppDelegate.h
//  biubiu
//
//  Created by haowenliang on 15/1/30.
//  Copyright (c) 2015年 dpsoft. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BMapKit.h"


@interface AppDelegate : UIResponder <UIApplicationDelegate,UITabBarControllerDelegate,BMKGeneralDelegate>
{
    BMKMapManager* _mapManager;
    UITabBarController * _tabBarController;
}
@property (strong, nonatomic) BMKMapManager* mapManager;

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) UITabBarController *tabBarController;

@property (strong, nonatomic, readonly) NSMutableArray* viewControllers;

- (void)updateTabCounter;
@end

