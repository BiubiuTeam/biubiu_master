//
//  DPUnionPostManager.m
//  biubiu
//
//  Created by haowenliang on 15/3/27.
//  Copyright (c) 2015年 dpsoft. All rights reserved.
//

#import "DPUnionPostManager.h"
#import "DPHttpService+Sociaty.h"
#import "BackSourceInfo_2004.h"
#import "DPQustionPool.h"
#import "DPFileHelper+Union.h"

@interface DPUnionPostManager ()

@end

@implementation DPUnionPostManager

+ (instancetype)shareInstance
{
    static DPUnionPostManager* s_instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        s_instance = [[DPUnionPostManager alloc] init];
    });
    return s_instance;
}

- (void)clearRegistedUnionInfo
{
    self.completion = nil;
    _currentUnionId = 0;
    [_unionPostList removeAllObjects];
}

- (void)resetRegistedUnion:(NSInteger)unionId completion:(DPUnionPostCallbackBlock)completion
{
    self.completion = completion;
    _currentUnionId = unionId;
    [_unionPostList removeAllObjects];
    
    //从持续化存储的文件中，获取工会的缓存数据
    NSArray* cache = [DPFileHelper getCacheUnionPostList:_currentUnionId];
    if ([cache count]) {
        [_unionPostList addObjectsFromArray:cache];
    }
}

- (instancetype)init
{
    if (self = [super init]) {
        _unionPostList = [[NSMutableArray alloc] initWithCapacity:1];
    }
    return self;
}


- (void)updateUnionPostList
{
    if (_currentUnionId == 0) {
        return;
    }
    __weak DPUnionPostManager* mgr = self;
    [[DPHttpService shareInstance] excuteCmdToPullUnionPosts:_currentUnionId idType:1 lastId:0 completion:^(id json, JSONModelError *err) {
        if (err == nil) {
            BackSourceInfo_2004* source = [[BackSourceInfo_2004 alloc] initWithDictionary:json error:&err];
            if(err == nil){
                BackendReturnData_2004* returnData = source.returnData;
                [mgr.unionPostList removeAllObjects];
                for (DPQuestionModel* model in returnData.contData) {
                    [mgr.unionPostList addObject:@(model.questId)];
                }
                [[DPQustionPool pool] addQuestionListIntoPool:returnData.contData];
                [DPFileHelper cacheUnionPostList:mgr.unionPostList toUnion:_currentUnionId];
                if (mgr.completion) {
                    mgr.completion(0,YES);
                }
            }else{
                
                if (mgr.completion) {
                    mgr.completion(0,NO);
                }
                DPTrace("客户端数据转义出错");
            }
        }else{
            
            if (mgr.completion) {
                mgr.completion(0,NO);
            }
            DPTrace("请求失败： %@", [err description]);
        }
    }];
}

- (void)loadMoreUnionPostList
{
    if (_currentUnionId == 0 || [_unionPostList count] == 0) {
        return;
    }
    NSNumber* lastId = [_unionPostList lastObject];
    DPQuestionModel* model = [[DPQustionPool pool] getQuestionFromPoolOfId:[lastId integerValue]];
    __weak DPUnionPostManager* mgr = self;
    [[DPHttpService shareInstance] excuteCmdToPullUnionPosts:_currentUnionId idType:1 lastId:[model.sortId integerValue] completion:^(id json, JSONModelError *err) {
        if (err == nil) {
            BackSourceInfo_2004* source = [[BackSourceInfo_2004 alloc] initWithDictionary:json error:&err];
            if(err == nil){
                BackendReturnData_2004* returnData = source.returnData;
                for (DPQuestionModel* model in returnData.contData) {
                    [_unionPostList addObject:@(model.questId)];
                }
                [[DPQustionPool pool] addQuestionListIntoPool:returnData.contData];
                if (mgr.completion) {
                    mgr.completion(1,YES);
                }
            }else{
                if (mgr.completion) {
                    mgr.completion(1,NO);
                }
                DPTrace("客户端数据转义出错");
            }
        }else{
            if (mgr.completion) {
                mgr.completion(1,NO);
            }
            DPTrace("请求失败： %@", [err description]);
        }
    }];
}


@end
