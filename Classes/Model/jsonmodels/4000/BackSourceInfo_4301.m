//
//  BackSourceInfo_4301.m
//  biubiu
//
//  Created by haowenliang on 15/2/12.
//  Copyright (c) 2015年 dpsoft. All rights reserved.
//

#import "BackSourceInfo_4301.h"

@implementation DPPushModel

+(JSONKeyMapper*)keyMapper
{
    return [[JSONKeyMapper alloc] initWithDictionary:@{
                                                       @"allNum": @"unreadNum",
                                                       @"newLikeNum": @"unreadLikeNum",
                                                       @"newAnsNum": @"unreadAnsNum",
                                                       @"newQuestNum": @"unreadQuestNum"
                                                       }];
}


@end

@implementation BackSourceInfo_4301

@end
