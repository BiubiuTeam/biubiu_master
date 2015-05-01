//
//  DPSociatyModel.m
//  biubiu
//
//  Created by haowenliang on 15/3/24.
//  Copyright (c) 2015年 dpsoft. All rights reserved.
//

// 尝试去掉base64编码
#import "DPSociatyModel.h"
@implementation DPSociatyModel

- (NSString *)unionName
{
    return _unionName;
}

@end

@implementation DPSociatyServerModel

+(JSONKeyMapper*)keyMapper
{
    return [[JSONKeyMapper alloc] initWithDictionary:@{ @"statusCode":  @"statusCode", @"statusInfo":@"statusInfo",  @"returnData.contData": @"unionList" }];
}

@end