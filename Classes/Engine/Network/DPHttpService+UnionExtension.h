//
//  DPHttpService+UnionExtension.h
//  biubiu
//
//  Created by haowenliang on 15/3/27.
//  Copyright (c) 2015年 dpsoft. All rights reserved.
//

#import "DPHttpService.h"

typedef NS_ENUM(NSUInteger, QuestionType) {
    QuestionType_Nearby = 1,
    QuestionType_Union = 2,
};

@interface DPHttpService (UnionExtension)

/**
 *  发表操作添加工会参数
 */
- (void)excutePublishedCmd:(NSString*)content
                  latitude:(float)lat
                  logitude:(float)lon
                 signiture:(NSString*)sign
                  location:(NSString*)location
                 questType:(QuestionType)type
                   unionId:(NSInteger)unionid;

- (void)excuteLinkinCmd:(NSString*)dvcIdOld completion:(JSONObjectBlock)completeBlock;

@end
