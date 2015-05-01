//
//  DPQustionPool.h
//  biubiu
//
//  Created by haowenliang on 15/3/7.
//  Copyright (c) 2015年 dpsoft. All rights reserved.
//

/**
 问题池，将所有的问题都扔到一个池子里面，保证数据的一致性，减少内存中存储多份相同的问题数据
 
 eg.
    附近，请求列表数据，仅需要记住问题id，将问题数据源扔到pool里面进行管理
 
    读取时从pool里面获取
 **/
#import <Foundation/Foundation.h>

@class DPQuestionModel;

@interface DPQustionPool : NSObject
{
    NSMutableArray* _questionPool;
}

+ (instancetype)pool;

//从池子中找到某个问题
- (DPQuestionModel*)getQuestionFromPoolOfId:(NSInteger)questionId;
//从池子中拉取一个问题列表(附近，我发表的，我参与的)
- (NSArray*)getQuestionListFromPool:(NSArray*)idList;
//替换池子中的某个问题
- (void)replaceQuestionInPoolWithQuestion:(DPQuestionModel*)model;

//将一组数据存入问题池中，如果有重复数据，直接替换
- (void)addQuestionListIntoPool:(NSArray*)questionList;

@end
