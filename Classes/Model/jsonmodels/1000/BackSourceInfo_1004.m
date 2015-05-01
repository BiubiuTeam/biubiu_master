//
//  BackSourceInfo_1004.m
//  BiuBiu
//
//  Created by haowenliang on 15/1/19.
//  Copyright (c) 2015年 dpsoft. All rights reserved.
//

#import "BackSourceInfo_1004.h"

@implementation BackendReturnData_1004

- (NSNumber<Optional> *)closeAppeal
{
    if (appStoreOrAdhoc == (NO) && _closeAppeal == nil) {
        return @2;
    }
    return _closeAppeal;
}

@end

@implementation BackSourceInfo_1004

@end
