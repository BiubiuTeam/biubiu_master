//
//  DPHttpService+UnionExtension.m
//  biubiu
//
//  Created by haowenliang on 15/3/27.
//  Copyright (c) 2015年 dpsoft. All rights reserved.
//

#import "DPHttpService+UnionExtension.h"

@implementation DPHttpService (UnionExtension)

- (void)excutePublishedCmd:(NSString*)content
                  latitude:(float)lat
                  logitude:(float)lon
                 signiture:(NSString*)sign
                  location:(NSString*)location
                 questType:(QuestionType)type
                   unionId:(NSInteger)unionid
{
    NSMutableDictionary* body = [NSMutableDictionary dictionary];
    [body setObject:[NSNumber numberWithInteger:0x2006] forKey:@"cmd"];
    [body setObject:content forKey:@"quest"];
    [body setObject:@(lat) forKey:@"latitude"];
    [body setObject:@(lon) forKey:@"longitude"];
    
    if (![sign length]) {
        sign = @"";
    }
    [body setObject:sign forKey:@"sign"];
    
    if ([location length]) {
        [body setObject:location forKey:@"selfLocDesc"];
    }
    
    [body setObject:@(type) forKey:@"questType"];
    [body setObject:@(unionid) forKey:@"unionId"];
    
    __block NSMutableDictionary* userInfo = [body mutableCopy];
    [self postRequestWithBodyDictionary:body completion:^(id json, JSONModelError *err) {
        if (nil == err) {
            BackSourceInfo* backSource = [[BackSourceInfo alloc] initWithDictionary:json error:nil];
            [userInfo setObject:@(backSource.statusCode) forKey:kNotification_StatusCode];
            [userInfo setObject:backSource.statusInfo forKey:kNotification_StatusInfo];
        }else{
            [userInfo setObject:@(-1) forKey:kNotification_StatusCode];
            [userInfo setObject:[NSString stringWithFormat:@"%@",[err description]] forKey:kNotification_StatusInfo];
        }
        [[NSNotificationCenter defaultCenter] postNotificationName:kNotification_NewPostCallBack object:nil userInfo:userInfo];
    }];
}

- (void)excuteLinkinCmd:(NSString*)dvcIdOld completion:(JSONObjectBlock)completeBlock
{
    NSMutableDictionary* body = [NSMutableDictionary dictionary];
    [body setObject:[NSNumber numberWithInteger:0x1006] forKey:@"cmd"];
    [body setObject:dvcIdOld forKey:@"dvcIdOld"];
    [self postRequestWithBodyDictionary:body completion:completeBlock];
}
@end
