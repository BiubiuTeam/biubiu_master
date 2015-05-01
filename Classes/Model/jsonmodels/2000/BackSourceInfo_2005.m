//
//  BackSourceInfo_2005.m
//  BiuBiu
//
//  Created by haowenliang on 15/1/19.
//  Copyright (c) 2015年 dpsoft. All rights reserved.
//

#import "BackSourceInfo_2005.h"

@implementation DPAnswerModel

- (NSString *)ans
{
    if ([_ans length]) {
        NSString* target = [_ans base64Decode];
        if ([target length]) {
            return target;
        }
    }
    return _ans;
}

- (NSString<Optional> *)nick
{
    if ([_nick length]) {
        NSString* target = [_nick base64Decode];
        if ([target length]) {
            return target;
        }
    }
    return _nick;
}

- (NSString<Optional> *)toNick
{
    if ([_toNick length]) {
        NSString* target = [_toNick base64Decode];
        if ([target length]) {
            return target;
        }
    }
    return _toNick;
}

- (NSComparisonResult)AscendingSort:(DPAnswerModel*)model
{
    if (self.ansId > model.ansId) {
        return NSOrderedDescending;
    }else{
        return NSOrderedAscending;
    }
    return NSOrderedSame;
}

- (NSComparisonResult)DecendingSort:(DPAnswerModel*)model
{
    if (self.ansId > model.ansId) {
        return NSOrderedAscending;
    }else{
        return NSOrderedDescending;
    }
    return NSOrderedSame;
}

- (void)dealloc
{
    DPTrace("回复数据源释放");
}
@end

@implementation BackendReturnData_2005

@end

@implementation BackSourceInfo_2005

@end
