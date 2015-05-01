//
//  DPQustionPool.m
//  biubiu
//
//  Created by haowenliang on 15/3/7.
//  Copyright (c) 2015年 dpsoft. All rights reserved.
//

#import "DPQustionPool.h"
#import "BackSourceInfo_2001.h"
#import "DPFileHelper.h"

@implementation DPQustionPool

+ (instancetype)pool
{
    static DPQustionPool* p_instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        p_instance = [[DPQustionPool alloc] init];
    });
    return p_instance;
}

- (instancetype)init
{
    if (self = [super init]) {
        [self setup];
    }
    return self;
}

- (void)setup
{
    _questionPool = [[NSMutableArray alloc] initWithCapacity:10];
    
    NSArray* cacheList = [DPFileHelper getCacheQuestionPoolList];
    if ([cacheList count]) {
        [_questionPool addObjectsFromArray:cacheList];
    }
}

- (void)cacheQuesitonPoolToFile
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(cacheQuesitonPoolToFile) object:nil];
    @synchronized(_questionPool){
        [DPFileHelper cacheQuestionPool:_questionPool];
    }
}

- (void)delayToCacheFile
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(cacheQuesitonPoolToFile) object:nil];
    [self performSelector:@selector(cacheQuesitonPoolToFile) withObject:nil afterDelay:0.3];
}

#pragma mark -

//从池子中找到某个问题
- (DPQuestionModel* )getQuestionFromPoolOfId:(NSInteger)questionId
{
    for (DPQuestionModel* model in _questionPool) {
        if (model.questId == questionId) {
            return model;
        }
    }
    return nil;
}

//从池子中拉取一个问题列表(附近，我发表的，我参与的)
- (NSArray*)getQuestionListFromPool:(NSArray*)idList
{
    if (![_questionPool count] || ![idList count]) {
        return nil;
    }
    NSMutableArray* array = [NSMutableArray new];
    @autoreleasepool {
        NSMutableArray* tmpList = [_questionPool mutableCopy];
        for(NSNumber* idValue in idList)
        {
            for(NSInteger index = 0; index < [tmpList count]; index++){
                DPQuestionModel* model = tmpList[index];
                if (model.questId == [idValue integerValue]) {
                    [array addObject:model];
                    break;
                }
            }
        }
    }
    return array;
}

//替换池子中的某个问题
- (void)replaceQuestionInPoolWithQuestion:(DPQuestionModel*)model
{
    if (model == nil)
        return;
    BOOL needToUpdateFile = NO;
    NSInteger index = 0;
    for(; index < [_questionPool count]; index++){
        DPQuestionModel* tmpModel = _questionPool[index];
        if (model.questId == tmpModel.questId) {
            [_questionPool replaceObjectAtIndex:index withObject:model];
            needToUpdateFile = YES;
            break;
        }
    }
    if (index >= [_questionPool count]) {
        [_questionPool addObject:model];
        needToUpdateFile = YES;
    }

    if (needToUpdateFile) {
        [self delayToCacheFile];
    }
}

//将一组数据存入问题池中，如果有重复数据，直接替换
- (void)addQuestionListIntoPool:(NSArray*)questionList
{
    if (![questionList count])
        return;
    for(DPQuestionModel* model in questionList){
        [self replaceQuestionInPoolWithQuestion:model];
    }
}


@end
