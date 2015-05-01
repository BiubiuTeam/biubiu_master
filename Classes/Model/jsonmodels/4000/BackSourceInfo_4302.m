//
//  BackSourceInfo_4302.m
//  biubiu
//
//  Created by haowenliang on 15/2/12.
//  Copyright (c) 2015年 dpsoft. All rights reserved.
//

#import "BackSourceInfo_4302.h"


@implementation DPPushItemModel

- (NSString<Optional> *)quest
{
    if (_quest) {
        NSString* target = [_quest base64Decode];
        if ([target length]) {
            return target;
        }
    }
    return _quest;
}

- (NSString<Optional> *)ans
{
    if (_ans) {
        NSString* target = [_ans base64Decode];
        if ([target length]) {
            return target;
        }
    }
    return _ans;
}

- (NSComparisonResult)sortInDescending:(DPPushItemModel*)object
{
    NSInteger selfId = [_ullId integerValue];
    NSInteger objId = [[object ullId] integerValue];

    if (selfId > objId) {
        return NSOrderedAscending;
    }
    return NSOrderedDescending;
}
@end

@implementation BackendReturnData_4302

@end


@implementation BackSourceInfo_4302

@end
