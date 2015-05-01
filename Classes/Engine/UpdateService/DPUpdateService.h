//
//  DPUpdateService.h
//  biubiu
//
//  Created by haowenliang on 15/3/5.
//  Copyright (c) 2015年 dpsoft. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DPHttpService.h"
#import "DPFileHelper.h"

typedef NS_ENUM(NSUInteger, DPCountSrcType) {
    DPCountSrcType_Questions,
    DPCountSrcType_Answers,
    DPCountSrcType_Upvotes,
    DPCountSrcType_Downvotes,
    DPCountSrcType_Reports,
};

typedef NS_ENUM(NSUInteger, DPResponseType) {
    DPResponseType_Failed,
    DPResponseType_Succeed,
    DPResponseType_NoMore,
    DPResponseType_NoUpdate,
};
@class DPAnswerModel;
@class DPQuestionModel;
typedef void (^DPQuestionCallbackBlock)(DPQuestionModel* question, DPResponseType type);
typedef void (^DPQuestionListCallbackBlock)(NSArray* questionList, DPResponseType type);

typedef void (^DPAnswerCallbackBlock)(DPAnswerModel* answer, DPResponseType type);
typedef void (^DPAnswerListCallbackBlock)(NSArray* qanswerList, DPResponseType type);

@interface DPUpdateService : NSObject

+ (instancetype)shareInstance;

@end
