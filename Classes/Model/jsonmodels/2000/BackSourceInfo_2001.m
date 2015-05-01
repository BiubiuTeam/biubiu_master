//
//  BackSourceInfo_2001.m
//  BiuBiu
//
//  Created by haowenliang on 15/1/19.
//  Copyright (c) 2015年 dpsoft. All rights reserved.
//

#import "BackSourceInfo_2001.h"

@implementation DPQuestionModel

- (NSString *)quest
{
    if ([_quest length]) {
        NSString* target = [_quest base64Decode];
        if ([target length]) {
            return target;
        }
    }
    return _quest;
}

- (NSString<Optional> *)sign
{
    if ([_sign length]) {
        NSString* target =  [_sign base64Decode];
        if ([target length]) {
            return target;
        }
    }
    return _sign;
}

- (void)dealloc
{
    DPTrace("问题数据源释放");
}
@end

@implementation BackendReturnData_2001

@end

@implementation BackSourceInfo_2001

@end
