//
//  DPQuestionUpdateService.m
//  biubiu
//
//  Created by haowenliang on 15/3/5.
//  Copyright (c) 2015年 dpsoft. All rights reserved.
//

#import "DPQuestionUpdateService.h"
#import "DPQustionPool.h"

#import "DPLbsServerEngine.h"

@interface DPQuestionUpdateService ()
{
    NSMutableArray* _requestSeqList;
    
    NSMutableArray* _otherCacheList; //一些问题数据，不存在于附近，我提问，以及我参与的
}
@end

@implementation DPQuestionUpdateService

+ (instancetype)shareInstance
{
    static DPQuestionUpdateService* s_instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        s_instance = [[DPQuestionUpdateService alloc] init];
    });
    return s_instance;
}

- (instancetype)init
{
    if (self = [super init]) {
        _nearbyQuestionList = [NSMutableArray new];
        _myPostQuestionList = [NSMutableArray new];
        _myReplyQuestionList = [NSMutableArray new];
        
        _requestSeqList = [NSMutableArray new];
        _otherCacheList = [NSMutableArray new];
        
        [self setup];
    }
    return self;
}

- (void)setup
{
    NSArray* cacheList = [DPFileHelper getCacheNearbyList];
    if ([cacheList count]) {
        [_nearbyQuestionList addObjectsFromArray:cacheList];
    }
    
    NSArray* postList = [DPFileHelper getCacheMyPostList];
    if ([postList count]) {
        [_myPostQuestionList addObjectsFromArray:postList];
    }
    
    NSArray* followList = [DPFileHelper getCacheFollowList];
    if ([followList count]) {
        [_myReplyQuestionList addObjectsFromArray:followList];
    }
}

- (void)cleanUpMemory
{
//    [_myPostQuestionList removeAllObjects];
//    [_myReplyQuestionList removeAllObjects];
}

- (NSMutableArray *)myPostQuestionList
{
    if(![_myPostQuestionList count]){
        NSArray* cacheMyPost = [DPFileHelper getCacheMyPostList];
        if ([cacheMyPost count]) {
            [_myPostQuestionList addObjectsFromArray:cacheMyPost];
        }
    }
    return _myPostQuestionList;
}

- (NSMutableArray *)myReplyQuestionList
{
    if (![_myReplyQuestionList count]) {
        NSArray* cacheMyReply = [DPFileHelper getCacheFollowList];
        if ([cacheMyReply count]) {
            [_myReplyQuestionList addObjectsFromArray:cacheMyReply];
        }
    }
    return _myReplyQuestionList;
}

- (NSString*)keyForUpdateQuestion:(NSInteger)questId
{
    return [NSString stringWithFormat:@"Question_%zd",questId];
}

- (void)replaceMemoryCacheQuestion:(DPQuestionModel*)model
{
    [[DPQustionPool pool] replaceQuestionInPoolWithQuestion:model];
}

#pragma mark -单个问题
- (DPQuestionModel *)getQuestionModelWithID:(NSInteger)questId
{
    DPQuestionModel *retModel = [[DPQustionPool pool] getQuestionFromPoolOfId:questId];
    if (retModel == nil) {
        [self updateQuestionModelWithID:questId completion:nil];
    }
    return retModel;
}

- (void)updateQuestionModelWithID:(NSInteger)questId completion:(DPQuestionCallbackBlock)completion
{
    NSString* reqKey = [self keyForUpdateQuestion:questId];
    if ([_requestSeqList containsObject:reqKey]) {
        DPTrace("已有%zd更新请求",questId);
        return;
    }
    [_requestSeqList addObject:reqKey];
    
    float lat = [[DPLbsServerEngine shareInstance] latitude];
    float lon = [[DPLbsServerEngine shareInstance] longitude];

    NSMutableDictionary* body = [NSMutableDictionary dictionary];
    [body setObject:[NSNumber numberWithInteger:0x2009] forKey:@"cmd"];
    [body setObject:@(questId) forKey:@"questId"];
    [body setObject:@(lat) forKey:@"latitude"];
    [body setObject:@(lon) forKey:@"longitude"];
    
    __block DPQuestionCallbackBlock callBack = completion;
    [[DPHttpService shareInstance] postRequestWithBodyDictionary:body completion:^(id json, JSONModelError *err) {
        DPTrace("单个问题:%@",json);
        
        [_requestSeqList removeObject:[self keyForUpdateQuestion:questId]];
        
        DPResponseType type = DPResponseType_Failed;
        if (nil == err) {
            BackSourceInfo_2009* backSource = [[BackSourceInfo_2009 alloc] initWithDictionary:json error:&err];
            if (err == nil && backSource.statusCode && backSource.statusCode == 0) {
                if (backSource.returnData) {
                    DPQuestionModel* resultModel = backSource.returnData;
                    [self replaceMemoryCacheQuestion:resultModel];
                }
            }
        }
        if (callBack) {
            callBack([self getQuestionModelWithID:questId],type);
        }
        callBack = nil;
    }];
}

#pragma mark -附近列表
- (NSString*)keyForUpdateNearbyList
{
    return @"NearbyQuestionList";
}

- (NSString*)keyForPullMoreNearbyList
{
    return @"PullMoreNearbyQuestionList";
}

- (NSArray *)nearbyQuestionList
{
    return _nearbyQuestionList;
}

- (void)updateNearbyQuestionListWithCompletion:(DPQuestionListCallbackBlock)completion
{
    if ([_requestSeqList containsObject:[self keyForUpdateNearbyList]]) {
        DPTrace("已有附近列表更新请求");
        return;
    }
    [_requestSeqList addObject:[self keyForUpdateNearbyList]];
    [_requestSeqList removeObject:[self keyForPullMoreNearbyList]];
    
    float lat = [[DPLbsServerEngine shareInstance] latitude];
    float lon = [[DPLbsServerEngine shareInstance] longitude];
    
    __block DPQuestionListCallbackBlock callBack = completion;
    
    [[DPHttpService shareInstance] excuteCmdToLoadNearbyPostListEx:2 lastPostId:0 latitude:lat logitude:lon completion:^(id json, JSONModelError *err) {
        if ([_requestSeqList containsObject:[self keyForUpdateNearbyList]] == NO) {
            callBack = nil;
            return;
        }
        [_requestSeqList removeObject:[self keyForUpdateNearbyList]];
        
        DPResponseType type = DPResponseType_Failed;
        if (err == nil) {
            BackSourceInfo_2004* source = [[BackSourceInfo_2004 alloc] initWithDictionary:json error:&err];
            if(err == nil){
                [_nearbyQuestionList removeAllObjects];
                type = DPResponseType_Succeed;
                BackendReturnData_2004* returnData = source.returnData;
                for(DPQuestionModel* model in returnData.contData){
                    [_nearbyQuestionList addObject:[NSNumber numberWithInteger:model.questId]];
                }
                [DPFileHelper cacheNearbyList:_nearbyQuestionList];
                
                [[DPQustionPool pool] addQuestionListIntoPool:returnData.contData];
            }else{
                type = DPResponseType_NoUpdate;
                DPTrace("客户端数据转义出错");
            }
        }else{
            type = DPResponseType_Failed;
            DPTrace("请求失败： %@", [err description]);
        }
        
        if (callBack) {
            callBack([self nearbyQuestionList],type);
        }
        callBack = nil;
    }];
}

- (void)pullMoreNearbyQuestionListWithCompletion:(DPQuestionListCallbackBlock)completion
{
    if ([_requestSeqList containsObject:[self keyForPullMoreNearbyList]]) {
        DPTrace("已有附近列表拉取更多请求");
        return;
    }
    [_requestSeqList addObject:[self keyForPullMoreNearbyList]];
    [_requestSeqList removeObject:[self keyForUpdateNearbyList]];
    
    float lat = [[DPLbsServerEngine shareInstance] latitude];
    float lon = [[DPLbsServerEngine shareInstance] longitude];
    
    NSNumber* tmpID = [[self nearbyQuestionList] lastObject];
    DPQuestionModel* data = [self getQuestionModelWithID:tmpID.integerValue];
    
    __block DPQuestionListCallbackBlock callBack = completion;
    
    [[DPHttpService shareInstance] excuteCmdToLoadNearbyPostListEx:1 lastPostId:[data.sortId integerValue] latitude:lat logitude:lon completion:^(id json, JSONModelError *err) {
        if ([_requestSeqList containsObject:[self keyForPullMoreNearbyList]] == NO) {
            callBack = nil;
            return;
        }
        [_requestSeqList removeObject:[self keyForPullMoreNearbyList]];
        
        DPResponseType type = DPResponseType_Failed;
        if (err == nil) {
            BackSourceInfo_2004* source = [[BackSourceInfo_2004 alloc] initWithDictionary:json error:&err];
            if(err == nil){
                BackendReturnData_2004* returnData = source.returnData;
                if([returnData.contData count]){
                    type = DPResponseType_Succeed;
                    for(DPQuestionModel* model in returnData.contData){
                        [_nearbyQuestionList addObject:[NSNumber numberWithInteger:model.questId]];
                    }
                    [[DPQustionPool pool] addQuestionListIntoPool:returnData.contData];
                }else{
                    type = DPResponseType_NoMore;
                }
            }else{
                type = DPResponseType_Failed;
                DPTrace("客户端数据转义出错");
            }
        }else{
            type = DPResponseType_Failed;
            DPTrace("请求失败： %@", [err description]);
        }
        
        if (callBack) {
            callBack([self nearbyQuestionList],type);
        }
        callBack = nil;
    }];
}

#pragma mark -我发表的
- (NSString*)keyForUpdateMyPostList
{
    return @"MyPostQuestionList";
}

- (NSString*)keyForPullMoreMyPostList
{
    return @"PullMoreMyPostQuestionList";
}

- (void)updateMyPostQuestionListWithCompletion:(DPQuestionListCallbackBlock)completion
{
    if ([_requestSeqList containsObject:[self keyForUpdateMyPostList]]) {
        DPTrace("已有我发表的问题列表更新请求");
        return;
    }
    [_requestSeqList addObject:[self keyForUpdateMyPostList]];
    [_requestSeqList removeObject:[self keyForPullMoreMyPostList]];
    
    __block DPQuestionListCallbackBlock callBack = completion;
    [[DPHttpService shareInstance] excuteCmdToLoadUserPostListEx:1 lastPostId:0 completion:^(id json, JSONModelError *err) {
        if ([_requestSeqList containsObject:[self keyForUpdateMyPostList]] == NO) {
            callBack = nil;
            return;
        }
        [_requestSeqList removeObject:[self keyForUpdateMyPostList]];
        
        DPResponseType resType = DPResponseType_Failed;
        if (nil == err) {
            BackSourceInfo_2001* backSource = [[BackSourceInfo_2001 alloc] initWithDictionary:json error:&err];
            BackendReturnData_2001* returnData = backSource.returnData;
            if (err == nil ) {
                resType = DPResponseType_Succeed;
                [_myPostQuestionList removeAllObjects];
                for(DPQuestionModel* model in returnData.contData){
                    [_myPostQuestionList addObject:[NSNumber numberWithInteger:model.questId]];
                }
                [DPFileHelper cacheUserPostList:_myPostQuestionList];
                [[DPQustionPool pool] addQuestionListIntoPool:returnData.contData];
            }else{
                DPTrace("类型转换出错:%@",err);
            }
        }else{
            DPTrace("加载失败");
        }
        
        if(callBack){
            callBack([self myPostQuestionList], resType);
        }
        callBack = nil;
    }];
}

- (void)pullMoreMyPostQuestionListWithCompletion:(DPQuestionListCallbackBlock)completion
{
    if ([_requestSeqList containsObject:[self keyForPullMoreMyPostList]]) {
        DPTrace("已有我发表的问题列表更新请求");
        return;
    }
    [_requestSeqList addObject:[self keyForPullMoreMyPostList]];
    [_requestSeqList removeObject:[self keyForUpdateMyPostList]];
    
    __block DPQuestionListCallbackBlock callBack = completion;
    
    DPQuestionModel* lastData = [[DPQustionPool pool] getQuestionFromPoolOfId:[[_myPostQuestionList lastObject] integerValue]];
    [[DPHttpService shareInstance] excuteCmdToLoadUserPostListEx:1 lastPostId:[lastData.sortId integerValue] completion:^(id json, JSONModelError *err) {
        if ([_requestSeqList containsObject:[self keyForPullMoreMyPostList]] == NO) {
            callBack = nil;
            return;
        }
        [_requestSeqList removeObject:[self keyForPullMoreMyPostList]];
        
        DPResponseType resType = DPResponseType_Failed;
        if (nil == err) {
            BackSourceInfo_2001* backSource = [[BackSourceInfo_2001 alloc] initWithDictionary:json error:&err];
            if (err == nil) {
                resType = DPResponseType_Succeed;
                BackendReturnData_2001* returnData = backSource.returnData;
                for(DPQuestionModel* model in returnData.contData){
                    [_myPostQuestionList addObject:[NSNumber numberWithInteger:model.questId]];
                }
                [[DPQustionPool pool] addQuestionListIntoPool:returnData.contData];
            }
        }else{
            DPTrace("加载失败");
        }
        if(callBack){
            callBack([self myPostQuestionList], resType);
        }
        callBack = nil;
    }];
}

#pragma mark -我参与的
- (NSString*)keyForUpdateMyReplyList
{
    return @"MyReplyQuestionList";
}

- (NSString*)keyForPullMoreMyReplyList
{
    return @"PullMoreMyReplyQuestionList";
}

- (void)updateMyReplyQuestionListWithCompletion:(DPQuestionListCallbackBlock)completion
{
    if ([_requestSeqList containsObject:[self keyForUpdateMyReplyList]]) {
        DPTrace("已有我参与的问题列表更新请求");
        return;
    }
    [_requestSeqList addObject:[self keyForUpdateMyReplyList]];
    [_requestSeqList removeObject:[self keyForPullMoreMyReplyList]];

    __block DPQuestionListCallbackBlock callBack = completion;
    [[DPHttpService shareInstance] excuteCmdToLoadUserFollowPostListEx:1 lastPostId:0 completion:^(id json, JSONModelError *err) {
        if ([_requestSeqList containsObject:[self keyForUpdateMyReplyList]] == NO) {
            callBack = nil;
            return;
        }
        [_requestSeqList removeObject:[self keyForUpdateMyReplyList]];
        
        DPResponseType resType = DPResponseType_Failed;
        if (nil == err) {
            BackSourceInfo_2002* backSource = [[BackSourceInfo_2002 alloc] initWithDictionary:json error:&err];
            if (err == nil ) {
                BackendReturnData_2002* returnData = backSource.returnData;
                resType = DPResponseType_Succeed;
                [_myReplyQuestionList removeAllObjects];

                for(DPQuestionModel* model in returnData.contData){
                    [_myReplyQuestionList addObject:[NSNumber numberWithInteger:model.questId]];
                }
                [DPFileHelper saveCacheUserFollowPosts:_myReplyQuestionList];
                [[DPQustionPool pool] addQuestionListIntoPool:returnData.contData];
            }else{
                DPTrace("类型转换出错:%@",err);
            }
        }else{
            DPTrace("加载失败");
        }
        
        if(callBack){
            callBack([self myReplyQuestionList], resType);
        }
        callBack = nil;
    }];
}

- (void)pullMoreMyReplyQuestionListWithCompletion:(DPQuestionListCallbackBlock)completion
{
    if ([_requestSeqList containsObject:[self keyForPullMoreMyReplyList]]) {
        DPTrace("已有我参与的问题列表更新请求");
        return;
    }
    [_requestSeqList addObject:[self keyForPullMoreMyReplyList]];
    [_requestSeqList removeObject:[self keyForUpdateMyReplyList]];
    
    __block DPQuestionListCallbackBlock callBack = completion;
    
    DPQuestionModel* lastData = [[DPQustionPool pool] getQuestionFromPoolOfId:[[_myReplyQuestionList lastObject] integerValue]];
    [[DPHttpService shareInstance] excuteCmdToLoadUserFollowPostListEx:1 lastPostId:[lastData.sortId integerValue] completion:^(id json, JSONModelError *err)  {
        if ([_requestSeqList containsObject:[self keyForPullMoreMyReplyList]] == NO) {
            callBack = nil;
            return;
        }
        [_requestSeqList removeObject:[self keyForPullMoreMyReplyList]];
        
        DPResponseType resType = DPResponseType_Failed;
        if (nil == err) {
            BackSourceInfo_2002* backSource = [[BackSourceInfo_2002 alloc] initWithDictionary:json error:&err];
            if (err == nil) {
                resType = DPResponseType_Succeed;
                BackendReturnData_2002* returnData = backSource.returnData;
                if ([returnData.contData count]) {
                    for(DPQuestionModel* model in returnData.contData){
                        [_myReplyQuestionList addObject:[NSNumber numberWithInteger:model.questId]];
                    }
                }else{
                    resType = DPResponseType_NoMore;
                }
                [[DPQustionPool pool] addQuestionListIntoPool:returnData.contData];
            }
        }else{
            DPTrace("加载失败");
        }
        if(callBack){
            callBack([self myReplyQuestionList], resType);
        }
        callBack = nil;
    }];
}


@end
