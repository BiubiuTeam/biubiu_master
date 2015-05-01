//
//  DPLocationModel.m
//  biubiu
//
//  Created by haowenliang on 15/4/1.
//  Copyright (c) 2015年 dpsoft. All rights reserved.
//

#import "DPLocationModel.h"

@implementation DPLocationModel

+(JSONKeyMapper*)keyMapper
{
    return [[JSONKeyMapper alloc] initWithDictionary:@{ @"statusCode":  @"statusCode", @"statusInfo":@"statusInfo",  @"returnData.locDesc": @"locationDes" }];
}

@end
