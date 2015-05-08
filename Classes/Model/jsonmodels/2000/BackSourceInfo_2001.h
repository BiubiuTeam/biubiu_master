//
//  BackSourceInfo_2001.h
//  BiuBiu
//
//  Created by haowenliang on 15/1/19.
//  Copyright (c) 2015年 dpsoft. All rights reserved.
//

//    function execCmd_2001()   //足迹拉取用户发问列表

#import "BackSourceInfo.h"
#import "BackendReturnData.h"
#import "BackendContentData.h"

@protocol DPQuestionModel
@end

//回答
@interface DPQuestionModel : JSONModel

@property (strong, nonatomic) NSNumber<Optional>* sortId; //对客户端来说，这个是做排序用
@property (assign, nonatomic) int questId;   //问题Id
@property (strong, nonatomic) NSString* quest; //问题文本
@property (strong, nonatomic) NSString<Optional>* locDesc;    //地理位置名称
@property (strong, nonatomic) NSString<Optional>* sign;
@property (assign, nonatomic) int ansNum; //评论数
@property (assign, nonatomic) int likeNum;                //问题的点赞数(问题本身的)
@property (assign, nonatomic) int unlikeNum;              //踩数量(问题本身的)
@property (assign, nonatomic) int pubTime;        //发表时间戳
@property (strong, nonatomic) NSString<Optional>* selfLocDesc; //自定义的地理位置名称

@property (strong, nonatomic) NSNumber<Optional>* likeFlag; //点赞标志，0没点，1点赞，2点踩
@property (strong, nonatomic) NSNumber<Optional>* isImpeach;//是否举报过
@property (strong, nonatomic) NSNumber<Optional>* isMine;//是否归属个人

@property (strong, nonatomic) NSNumber<Optional>* longitude;
@property (strong, nonatomic) NSNumber<Optional>* latitude;

@property (strong, nonatomic) NSNumber<Optional>* opType; //问题类型，1常规用户发的问题，2管理员推送的类型

@property (strong, nonatomic) NSNumber<Optional>* isCreator;

@property (strong, nonatomic) NSNumber<Optional>* distance; //距离
@property (strong, nonatomic) NSNumber<Optional>* isYellow; //是否标黄
@end

@interface BackendReturnData_2001 : JSONModel
@property (strong, nonatomic) NSArray<DPQuestionModel,Optional>* contData;
@end

@interface BackSourceInfo_2001 : BackSourceInfo

@property (strong, nonatomic) BackendReturnData_2001<Optional>* returnData;
@end
