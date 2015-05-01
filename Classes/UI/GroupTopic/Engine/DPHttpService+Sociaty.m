//
//  DPHttpService+Sociaty.m
//  biubiu
//
//  Created by haowenliang on 15/3/25.
//  Copyright (c) 2015年 dpsoft. All rights reserved.
//

#import "DPHttpService+Sociaty.h"
#import "DPSociatyModel.h"
#import "DPLocationModel.h"
#import "BackSourceInfo_2004.h"
#import "DPQustionPool.h"

NSString*const kUnionCreationResult = @"_kUnionCreationResult_";
NSString*const kPullUnionListResult = @"_kPullUnionListResult_";
NSString*const kPullUnionPostsResult = @"_kPullUnionPostsResult_";

NSString*const kPullCheckingUnionListResult = @"_kPullCheckingUnionListResult_";
NSString*const kCheckingUnionResult = @"_kCheckingUnionResult_";

NSString*const kLocationUserPlace = @"_kLocationUserPlace_";
NSString*const kPullUnionPostListResult = @"_kPullUnionPostListResult_";

@implementation DPHttpService (Sociaty)

- (void)excuteCmdToCreateSociaty:(NSString*)sociatyName
                         picPath:(NSString*)path
                        location:(NSString*)curLocation
                        latitude:(int)lat
                        logitude:(int)lon
{
    if(![path length]){
        int i = rand()%9;
        path = [NSString stringWithFormat:@"http://img15.3lian.com/2015/f3/17/d/16%zd.jpg",i+1];
    }
    
    NSMutableDictionary* body = [NSMutableDictionary dictionary];
    [body setObject:[NSNumber numberWithInteger:0x2101] forKey:@"cmd"];
    
    [body setObject:sociatyName forKey:@"unionName"];
    [body setObject:path forKey:@"picPath"];
    if ([curLocation length]) {
        [body setObject:curLocation forKey:@"selfLocDesc"];
    }
    
    [body setObject:@(lat) forKey:@"latitude"];
    [body setObject:@(lon) forKey:@"longitude"];

    __block NSMutableDictionary* userInfo = [body mutableCopy];
    [self postRequestWithBodyDictionary:body completion:^(id json, JSONModelError *err) {
        if (nil == err) {
            BackSourceInfo* response = [[BackSourceInfo alloc] initWithDictionary:json error:&err];
            if (nil == err) {
                [userInfo setObject:response forKey:kNotification_ReturnObject];
            }else{
                [userInfo setObject:err forKey:kNotification_Error];
            }
        }else{
            [userInfo setObject:err forKey:kNotification_Error];
        }
        
        [[NSNotificationCenter defaultCenter] postNotificationName:kUnionCreationResult object:nil userInfo:userInfo];
    }];
}

- (void)excuteCmdToPullSociaties:(NSInteger)IdType
                          lastId:(NSInteger)lastId
                            type:(NSInteger)type
                        latitude:(int)lat
                        logitude:(int)lon
{
    NSMutableDictionary* body = [NSMutableDictionary dictionary];
    [body setObject:[NSNumber numberWithInteger:0x2102] forKey:@"cmd"];
    
    [body setObject:@(IdType) forKey:@"IdType"];
    [body setObject:@(lastId) forKey:@"lastId"];
    
    [body setObject:@(type) forKey:@"type"];
    
    [body setObject:@(lat) forKey:@"latitude"];
    [body setObject:@(lon) forKey:@"longitude"];
    
    __block NSMutableDictionary* userInfo = [body mutableCopy];
    [self postRequestWithBodyDictionary:body completion:^(id json, JSONModelError *err) {
        
        if (nil == err) {
            DPSociatyServerModel* response = [[DPSociatyServerModel alloc] initWithDictionary:json error:&err];
            if (nil == err) {
                [userInfo setObject:response.statusCode forKey:kNotification_StatusCode];
                if (response.statusInfo) {
                    [userInfo setObject:response.statusInfo forKey:kNotification_StatusInfo];
                }
                
                if ([response.statusCode intValue] == 0) {
                    if (response.unionList) {
                        [userInfo setObject:response.unionList forKey:kNotification_ReturnObject];
                    }
                }
            }else{
                [userInfo setObject:err forKey:kNotification_Error];
            }
        }else{
            [userInfo setObject:err forKey:kNotification_Error];
        }
        
        [[NSNotificationCenter defaultCenter] postNotificationName:kPullUnionListResult object:nil userInfo:userInfo];
    }];
}

- (void)excuteCmdToPullUnionPosts:(NSInteger)unionId
                           idType:(NSInteger)IdType
                           lastId:(NSInteger)lastId
{
    NSMutableDictionary* body = [NSMutableDictionary dictionary];
    [body setObject:[NSNumber numberWithInteger:0x2103] forKey:@"cmd"];
    
    [body setObject:@(IdType) forKey:@"IdType"];
    [body setObject:@(lastId) forKey:@"lastId"];
    [body setObject:@(unionId) forKey:@"unionId"];
    
    __block NSMutableDictionary* userInfo = [body mutableCopy];
    [self postRequestWithBodyDictionary:body completion:^(id json, JSONModelError *err) {
        if (err == nil) {
            BackSourceInfo_2004* source = [[BackSourceInfo_2004 alloc] initWithDictionary:json error:&err];
            if(err == nil){
                [userInfo setObject:@(source.statusCode) forKey:kNotification_StatusCode];
                BackendReturnData_2004* returnData = source.returnData;
                
                [[DPQustionPool pool] addQuestionListIntoPool:returnData.contData];
                if (returnData.contData) {
                    [userInfo setObject:returnData.contData forKey:kNotification_ReturnObject];
                }
                if (source.statusInfo) {
                    [userInfo setObject:source.statusInfo forKey:kNotification_StatusInfo];
                }
            }else{
                [userInfo setObject:err forKey:kNotification_Error];
                DPTrace("客户端数据转义出错");
            }
        }else{
            [userInfo setObject:err forKey:kNotification_Error];
            DPTrace("请求失败： %@", [err description]);
        }
        
        [[NSNotificationCenter defaultCenter] postNotificationName:kPullUnionPostListResult object:nil userInfo:userInfo];
    }];
}


- (void)excuteCmdToPullUnionPosts:(NSInteger)unionId
                           idType:(NSInteger)IdType
                           lastId:(NSInteger)lastId
                       completion:(JSONObjectBlock)completion
{
    NSMutableDictionary* body = [NSMutableDictionary dictionary];
    [body setObject:[NSNumber numberWithInteger:0x2103] forKey:@"cmd"];
    [body setObject:@(IdType) forKey:@"IdType"];
    [body setObject:@(lastId) forKey:@"lastId"];
    [body setObject:@(unionId) forKey:@"unionId"];
    
    [self postRequestWithBodyDictionary:body completion:completion];
}


#pragma mark -工会审核模块的Api
- (void)excuteCmdToLoadCheckingUnions:(NSInteger)IdType
                               lastId:(NSInteger)lastId
{
    NSMutableDictionary* body = [NSMutableDictionary dictionary];
    [body setObject:[NSNumber numberWithInteger:0x6003] forKey:@"cmd"];
    [body setObject:@(IdType) forKey:@"IdType"];
    [body setObject:@(lastId) forKey:@"lastId"];
    [body setObject:@(5) forKey:@"specCode"];
    
    __block NSMutableDictionary* userInfo = [body mutableCopy];
    [self postRequestWithBodyDictionary:body completion:^(id json, JSONModelError *err) {
        if (nil == err) {
            DPSociatyServerModel* response = [[DPSociatyServerModel alloc] initWithDictionary:json error:&err];
            if (nil == err) {
                [userInfo setObject:response.statusCode forKey:kNotification_StatusCode];
                if (response.statusInfo) {
                    [userInfo setObject:response.statusInfo forKey:kNotification_StatusInfo];
                }
                
                if ([response.statusCode intValue] == 0) {
                    if (response.unionList) {
                        [userInfo setObject:response.unionList forKey:kNotification_ReturnObject];
                    }
                }
            }else{
                [userInfo setObject:err forKey:kNotification_Error];
            }
        }else{
            [userInfo setObject:err forKey:kNotification_Error];
        }
        
        [[NSNotificationCenter defaultCenter] postNotificationName:kPullCheckingUnionListResult object:nil userInfo:userInfo];
    }];
}

- (void)excuteCmdToCheckingTheUnions:(NSUInteger)unionId passed:(BOOL)pass
{
    NSMutableDictionary* body = [NSMutableDictionary dictionary];
    [body setObject:[NSNumber numberWithInteger:0x6004] forKey:@"cmd"];
    [body setObject:@(5) forKey:@"specCode"];
    if (pass) {
        [body setObject:@[@(unionId)] forKey:@"unionConfirmId"];
    }else{
        [body setObject:@[@(unionId)] forKey:@"unionBanId"];
    }
    
    __block NSMutableDictionary* userInfo = [body mutableCopy];
    [self postRequestWithBodyDictionary:body completion:^(id json, JSONModelError *err) {
        if (nil == err) {
            BackSourceInfo* response = [[BackSourceInfo alloc] initWithDictionary:json error:&err];
            if (nil == err) {
                [userInfo setObject:@(response.statusCode) forKey:kNotification_StatusCode];
                if (response.statusInfo) {
                    [userInfo setObject:response.statusInfo forKey:kNotification_StatusInfo];
                }
            }else{
                [userInfo setObject:err forKey:kNotification_Error];
            }
        }else{
            [userInfo setObject:err forKey:kNotification_Error];
        }
        
        [[NSNotificationCenter defaultCenter] postNotificationName:kCheckingUnionResult object:nil userInfo:userInfo];
    }];
}


- (void)excuteCmdToLocationUserPlaceAtLatitude:(int)lat
                                      logitude:(int)lon
{
    NSMutableDictionary* body = [NSMutableDictionary dictionary];
    [body setObject:[NSNumber numberWithInteger:0x1005] forKey:@"cmd"];
    [body setObject:@(lat) forKey:@"latitude"];
    [body setObject:@(lon) forKey:@"longitude"];
    __block NSMutableDictionary* userInfo = [body mutableCopy];
    [self postRequestWithBodyDictionary:body completion:^(id json, JSONModelError *err) {
        if (nil == err) {
            DPLocationModel* response = [[DPLocationModel alloc] initWithDictionary:json error:&err];
            if (nil == err) {
                [userInfo setObject:response.statusCode forKey:kNotification_StatusCode];
                if (response.statusInfo) {
                    [userInfo setObject:response.statusInfo forKey:kNotification_StatusInfo];
                }
                if ([response.locationDes length]) {
                    [userInfo setObject:response.locationDes forKey:kNotification_ReturnObject];
                }
            }else{
                [userInfo setObject:err forKey:kNotification_Error];
            }
        }else{
            [userInfo setObject:err forKey:kNotification_Error];
        }
        
        [[NSNotificationCenter defaultCenter] postNotificationName:kLocationUserPlace object:nil userInfo:userInfo];
    }];
}
@end
