//
//  AppDelegate+BaiduMap.m
//  biubiu
//
//  Created by haowenliang on 15/3/28.
//  Copyright (c) 2015年 dpsoft. All rights reserved.
//

/**
 *  接入百度地图所遇到的问题：
 *   Manager start failed
 *      可能原因有两个：
 *      1）appid 对应的bundle id 不正确
 *      2）bundle display name 跟注册appid的时候的app名称不一致
 *
 *   地图一直显示为网格
 *      1）注册appid对应的bundle id与app的实际bundle id不一致
 */

#import "AppDelegate+BaiduMap.h"

@implementation AppDelegate (BaiduMap)

- (void)registBaiduMap
{
    // 要使用百度地图，请先启动BaiduMapManager
    _mapManager = [[BMKMapManager alloc]init];
    // 如果要关注网络及授权验证事件，请设定     generalDelegate参数
    BOOL ret = [_mapManager start:@"QMQiW0Gu7Qd1HVDTFp4zsPFN"  generalDelegate:self];
    if (!ret) {
        DPTrace("baidu map manager start failed!");
    }else{
        DPTrace("baidu map manager start succeed!");
    }
}

- (void)onGetNetworkState:(int)iError
{
    if (0 == iError) {
        NSLog(@"联网成功");
    }
    else{
        NSLog(@"onGetNetworkState %d",iError);
    }
    
}

- (void)onGetPermissionState:(int)iError
{
    if (0 == iError) {
        NSLog(@"授权成功");
    }
    else {
        NSLog(@"onGetPermissionState %d",iError);
    }
}

@end
