//
//  BackSourceInfo_3002.m
//  BiuBiu
//
//  Created by haowenliang on 15/1/19.
//  Copyright (c) 2015年 dpsoft. All rights reserved.
//

#import "BackSourceInfo_3002.h"

@implementation BackendContentData_3002

- (NSString<Optional> *)cont
{
    if ([_cont length]) {
        NSString* target = [_cont base64Decode];
        if ([target length]) {
            return target;
        }
    }
    return _cont;
}

@end

@implementation BackendReturnData_3002

@end

@implementation BackSourceInfo_3002

@end
