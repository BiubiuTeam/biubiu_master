//
//  DPAnswerUpdateService.m
//  biubiu
//
//  Created by haowenliang on 15/3/5.
//  Copyright (c) 2015年 dpsoft. All rights reserved.
//

/*
 回复列表的变动的情景：
 
 1，附近列表，首次进入，某个问题被加载，需要预加载该问题对应的回复列表
 
 2，附近列表，用户打开盒子，查看回复淡幕
 
 3，定时刷新问题回复列表
 
 4，详情页面，触发更新整个列表（回答数据可能被更新，点赞数，点踩数）
 
 5，详情页面，用户拉取更多问题列表
 
 6，详情页面，用户赞踩操作会触发更新某个回答数据（这里也会更新问题数据源）
 
 **/

#import "DPAnswerUpdateService.h"
#import "DPFileHelper.h"

@interface DPAnswerUpdateService ()
{
    NSMutableArray* _ansRequestSeq;
}

@end

@implementation DPAnswerUpdateService

+ (instancetype)shareInstance
{
    static DPAnswerUpdateService* s_instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        s_instance = [[DPAnswerUpdateService alloc] init];
    });
    return s_instance;
}

- (instancetype)init
{
    if (self = [super init]) {
        _ansRequestSeq = [NSMutableArray new];
        _answerListSet = [NSMutableDictionary new];
    }
    return self;
}

- (void)setup
{
    
}

- (void)forceToUpdateAnswerList:(NSInteger)questionId demandedCount:(NSInteger)count
{
    if (count == -1) {
        [self updateQuestionAnswerList:questionId completion:nil];
    }else{
        NSArray* ansList = [self getQuestionAnswerList:questionId];
        if ([ansList count] < MIN(ONEPAGE_COUNT, count)) {
            [self updateQuestionAnswerList:questionId completion:nil];
        }
    }
}

- (NSString*)keyForAnswerList:(NSInteger)questId
{
    return [NSString stringWithFormat:@"ANS_LIST_%zd",questId];
}

- (DPAnswerModel*)getAnswerDetail:(NSInteger)ansId questionId:(NSInteger)questId
{
    NSArray* values = [self getQuestionAnswerList:questId];
    if ([values count]) {
        for (DPAnswerModel* model in values) {
            if (model.ansId == ansId) {
                return model;
            }
        }
    }
    return nil;
}

- (void)updateAnswerDetail:(NSInteger)ansId questionId:(NSInteger)questId completion:(DPAnswerCallbackBlock)completion
{
    
}

- (void)replaceDemandedAnswer:(DPAnswerModel*)targetModel questionId:(NSInteger)questionId
{
    if (targetModel == nil) return;
    
    NSArray* orList = [self getQuestionAnswerList:questionId];
    NSMutableArray* mutList = [[NSMutableArray alloc] init];
    BOOL exsist = NO;
    NSInteger index = 0;
    if ([orList count]) {
        [mutList addObjectsFromArray:orList];
        for (DPAnswerModel* model in mutList) {
            if (model.ansId == targetModel.ansId) {
                index = [mutList indexOfObject:model];
                [mutList replaceObjectAtIndex:index withObject:targetModel];
                exsist = YES;
                break;
            }
        }
    }
    if (exsist == NO) {
        [mutList addObject:targetModel];
    }
    [_answerListSet setObject:mutList forKey:[self keyForAnswerList:questionId]];
    if (index < ONEPAGE_COUNT) {
        [self cacheQuestionAnswerList:questionId];
    }
}

- (void)updateDemandedAnswer:(NSInteger)ansId questionId:(NSInteger)questionId countType:(DPCountSrcType)srcType
{
    NSArray* orList = [self getQuestionAnswerList:questionId];
    NSMutableArray* mutList = [[NSMutableArray alloc] init];
    if ([orList count]) {
        [mutList addObjectsFromArray:orList];
        for (DPAnswerModel* model in mutList) {
            if (model.ansId == ansId) {
                switch (srcType) {
                    case DPCountSrcType_Upvotes:
                    {
                        model.likeFlag = @(1);
                        model.likeNum++;
                    }break;
                    case DPCountSrcType_Downvotes:
                    {
                        model.likeFlag = @(2);
                        model.unlikeNum++;
                    }break;
                    default:
                        break;
                }
                [_answerListSet setObject:mutList forKey:[self keyForAnswerList:questionId]];
                
                if ([mutList indexOfObject:model] < ONEPAGE_COUNT) {
                    [self cacheQuestionAnswerList:questionId];
                }
                return;
            }
        }
    }
}

- (void)cacheQuestionAnswerList:(NSInteger)questionId
{
    NSArray* orList = [self getQuestionAnswerList:questionId];
    NSMutableArray* mutList = [[NSMutableArray alloc] init];
    if ([orList count]) {
        [mutList addObjectsFromArray:orList];
    }
    //移除掉本地插入的数据
    for(NSUInteger index = [mutList count] ; index > 0; index--){
        DPAnswerModel* model = [mutList objectAtIndex:index-1];
        if ([model.localModel boolValue]) {
            [mutList removeObjectAtIndex:index-1];
        }
    }
    //将前30数据写入文件
    [DPFileHelper cacheAnswerList:[mutList subarrayWithRange:NSMakeRange(0, MIN(ONEPAGE_COUNT, [mutList count]))] questionId:questionId];
}

//获取某个问题的回复列表
- (NSArray*)getQuestionAnswerList:(NSInteger)questionId
{
    NSString* key = [self keyForAnswerList:questionId];
    NSArray* values = [_answerListSet objectForKey:key];
    if (![values count]) {
        values = [DPFileHelper getCacheAnswerListOfQuestionId:questionId];
    }
    return values;
}

- (void)removeQuestionAnswerList:(NSInteger)questionId
{
    NSString* key = [self keyForAnswerList:questionId];
    [_answerListSet removeObjectForKey:key];
}

- (void)addQuestionAnswerList:(NSInteger)questionId answers:(NSArray*)list
{
    if ([list count]) {
        NSString* key = [self keyForAnswerList:questionId];
        [_answerListSet setObject:list forKey:key];
        [self cacheQuestionAnswerList:questionId];
    }
}

- (void)insertQuestionLocalAnswer:(DPAnswerModel*)model questionId:(NSInteger)questionId
{
    if (model) {
        NSArray* orList = [self getQuestionAnswerList:questionId];
        NSMutableArray* mutList = [[NSMutableArray alloc] init];
        if ([orList count]) {
            [mutList addObjectsFromArray:orList];
            
            DPAnswerModel* last = [orList lastObject];
            model.ansId = [[NSDate date] timeIntervalSince1970];
            model.sortId = last.sortId;
            
            model.floorId = [NSNumber numberWithInteger:([last.floorId integerValue]+1)];
        }
        model.isMine = @(YES);
        model.pubTime = [[NSDate date] timeIntervalSince1970];
        model.localModel = @(YES);
        [mutList addObject:model];
        
        [_answerListSet setObject:mutList forKey:[self keyForAnswerList:questionId]];
    }
}

- (DPAnswerModel*)getQuestionLastBackendAnswer:(NSInteger)questionId
{
    NSArray* replyList = [self getQuestionAnswerList:questionId];
    DPAnswerModel* model = nil;
    for (NSInteger index = replyList.count; index > 0; index--) {
        model = replyList[index-1];
        if ([model.localModel boolValue]) {
            continue;
        }
        break;
    }
    return model;
}

- (void)appendQuestionAnswerList:(NSInteger)questionId answers:(NSArray*)list
{
    if ([list count]) {
        NSString* key = [self keyForAnswerList:questionId];
        NSArray* orList = [self getQuestionAnswerList:questionId];
        NSMutableArray* mutList = [[NSMutableArray alloc] init];
        if ([orList count]) {
            [mutList addObjectsFromArray:orList];
        }
        
        for(NSUInteger index = [mutList count] ; index > 0; index--){
            DPAnswerModel* model = [mutList objectAtIndex:index-1];
            if ([model.localModel boolValue]) {
                [mutList removeObjectAtIndex:index-1];
            }
        }
        [mutList addObjectsFromArray:list];
        [_answerListSet setObject:mutList forKey:key];
    }
}

- (void)updateQuestionAnswerList:(NSInteger)questionId completion:(DPAnswerListCallbackBlock)completion
{
    NSString* key = [self keyForAnswerList:questionId];
    if ([_ansRequestSeq containsObject:key]) {
        DPTrace("*****************已有%@回复列表请求**********",key);
        return;
    }
    [_ansRequestSeq addObject:key];
    
    NSInteger replyId = 0;
    __block DPAnswerListCallbackBlock callback = completion;
    [[DPHttpService shareInstance] excuteCmdToLoadPostReplyList:questionId loadType:2 lastReplyId:replyId completion:^(id json, JSONModelError *err)
    {
        [_ansRequestSeq removeObject:[self keyForAnswerList:questionId]];
        DPResponseType resType = DPResponseType_Failed;
        if (nil == err) {
            BackSourceInfo_2005* replyInfo = [[BackSourceInfo_2005 alloc] initWithDictionary:json error:&err];
            if (nil == err) {
                resType = DPResponseType_Succeed;
                [self removeQuestionAnswerList:questionId];
                BackendReturnData_2005* subInfo = (BackendReturnData_2005*)replyInfo.returnData;
                NSArray* subArray = subInfo.contData;
                if([subArray count]){
                    [self addQuestionAnswerList:questionId answers:subArray];
                }
            }
        }
        
        if(callback){
            callback([self getQuestionAnswerList:questionId], resType);
        }
        callback = nil;
    }];
}

- (void)pullMoreAnswerList:(NSInteger)questionId completion:(DPAnswerListCallbackBlock)completion
{
    NSString* key = [self keyForAnswerList:questionId];
    if ([_ansRequestSeq containsObject:key]) {
        DPTrace("*****************已有%@回复列表请求**********",key);
        return;
    }
    [_ansRequestSeq addObject:key];
    
    DPAnswerModel* replyData = [self getQuestionLastBackendAnswer:questionId];
    __block DPAnswerListCallbackBlock callback = completion;
    [[DPHttpService shareInstance] excuteCmdToLoadPostReplyList:questionId loadType:1 lastReplyId:replyData.ansId completion:^(id json, JSONModelError *err) {
        [_ansRequestSeq removeObject:[self keyForAnswerList:questionId]];
        
        DPResponseType resType = DPResponseType_Failed;
        if (nil == err) {
            BackSourceInfo_2005* replyInfo = [[BackSourceInfo_2005 alloc] initWithDictionary:json error:&err];
            if (nil == err) {
                if (replyInfo.statusCode == 0) {
                    resType = DPResponseType_Succeed;
                    BackendReturnData_2005* subInfo = (BackendReturnData_2005*)replyInfo.returnData;
                    if([subInfo.contData count]){
                        [self appendQuestionAnswerList:questionId answers:subInfo.contData];
                    }else{
                        resType = DPResponseType_NoMore;
                    }
                }
            }
        }
        if(callback){
            callback([self getQuestionAnswerList:questionId], resType);
        }
        callback = nil;
    }];
}

@end
