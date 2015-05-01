//
//  BackendAnsData.h
//  BiuBiu
//
//  Created by haowenliang on 15/1/20.
//  Copyright (c) 2015年 dpsoft. All rights reserved.
//

#import "JSONModel.h"
@protocol BackendAnsData
@end

@interface BackendAnsData : JSONModel

@property (assign, nonatomic) int ansId;       //问题Id
@property (strong, nonatomic) NSString* ans; //问题文本
@property (assign, nonatomic) int likeNum;                //问题的点赞数(问题本身的)
@property (assign, nonatomic) int unlikeNum;              //踩数量(问题本身的)
@property (assign, nonatomic) int pubTime;        //发表时间戳

@end
