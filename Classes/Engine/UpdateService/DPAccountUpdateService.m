//
//  DPAccountUpdateService.m
//  biubiu
//
//  Created by haowenliang on 15/3/5.
//  Copyright (c) 2015年 dpsoft. All rights reserved.
//

#import "DPAccountUpdateService.h"

@implementation DPAccountUpdateService

+ (instancetype)shareInstance
{
    static DPAccountUpdateService* s_instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        s_instance = [[DPAccountUpdateService alloc] init];
    });
    return s_instance;
}

@end
