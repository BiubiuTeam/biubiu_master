//
//  DPAnswerUpdateService.h
//  biubiu
//
//  Created by haowenliang on 15/3/5.
//  Copyright (c) 2015年 dpsoft. All rights reserved.
//

#import "DPUpdateService.h"
#import "BackSourceInfo_2005.h"

@interface DPAnswerUpdateService : DPUpdateService
{
    NSMutableDictionary* _answerListSet; //回复列表集合
}
- (void)forceToUpdateAnswerList:(NSInteger)questionId demandedCount:(NSInteger)count;
- (void)updateDemandedAnswer:(NSInteger)ansId questionId:(NSInteger)questionId countType:(DPCountSrcType)srcType;
- (void)appendQuestionAnswerList:(NSInteger)questionId answers:(NSArray*)list;
- (void)insertQuestionLocalAnswer:(DPAnswerModel*)model questionId:(NSInteger)questionId;

- (DPAnswerModel*)getAnswerDetail:(NSInteger)ansId questionId:(NSInteger)questId;
- (void)updateAnswerDetail:(NSInteger)ansId questionId:(NSInteger)questId completion:(DPAnswerCallbackBlock)completion;

//获取某个问题的回复列表
- (NSArray*)getQuestionAnswerList:(NSInteger)questionId;
- (void)updateQuestionAnswerList:(NSInteger)questionId completion:(DPAnswerListCallbackBlock)completion;

- (void)pullMoreAnswerList:(NSInteger)questionId completion:(DPAnswerListCallbackBlock)completion;



@end
