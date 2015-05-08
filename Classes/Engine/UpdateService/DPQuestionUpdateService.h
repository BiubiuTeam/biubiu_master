//
//  DPQuestionUpdateService.h
//  biubiu
//
//  Created by haowenliang on 15/3/5.
//  Copyright (c) 2015年 dpsoft. All rights reserved.
//

#import "DPUpdateService.h"
#import "BackSourceInfo_2001.h"
#import "BackSourceInfo_2002.h"
#import "BackSourceInfo_2009.h"
#import "BackSourceInfo_2004.h"

@interface DPQuestionUpdateService : DPUpdateService
{
    NSMutableArray* _nearbyQuestionList;
    NSMutableArray* _myPostQuestionList;
    NSMutableArray* _myReplyQuestionList;
}

@property (nonatomic, strong, readonly) NSMutableArray* nearbyQuestionList;
@property (nonatomic, strong, readonly) NSMutableArray* myPostQuestionList;
@property (nonatomic, strong, readonly) NSMutableArray* myReplyQuestionList;

- (void)cleanUpMemory;

//单个问题的更新
- (void)replaceMemoryCacheQuestion:(DPQuestionModel*)model;
- (DPQuestionModel*)getQuestionModelWithID:(NSInteger)questId;
- (void)updateQuestionModelWithID:(NSInteger)questId completion:(DPQuestionCallbackBlock)completion;

//附近页面
- (void)updateNearbyQuestionListWithCompletion:(DPQuestionListCallbackBlock)completion;
- (void)pullMoreNearbyQuestionListWithCompletion:(DPQuestionListCallbackBlock)completion;

//我发表的
- (void)updateMyPostQuestionListWithCompletion:(DPQuestionListCallbackBlock)completion;
- (void)pullMoreMyPostQuestionListWithCompletion:(DPQuestionListCallbackBlock)completion;

//我参与的
- (void)updateMyReplyQuestionListWithCompletion:(DPQuestionListCallbackBlock)completion;
- (void)pullMoreMyReplyQuestionListWithCompletion:(DPQuestionListCallbackBlock)completion;

//添加赞和踩
- (DPQuestionModel*)updateDemandedQuestion:(NSInteger)questionId countType:(DPCountSrcType)srcType;
@end
