//
//  BackSourceInfo_2005.h
//  BiuBiu
//
//  Created by haowenliang on 15/1/19.
//  Copyright (c) 2015年 dpsoft. All rights reserved.
//

//    function execCmd_2005()   //拉取某个问题的回答列表


#import "BackSourceInfo.h"
#import "BackendReturnData.h"
#import "BackendContentData.h"

@protocol DPAnswerModel <BackendContentData>
@end
@interface DPAnswerModel : BackendContentData
@property (strong, nonatomic) NSNumber<Ignore>* localModel;//本地数据
@property (strong, nonatomic) NSNumber<Optional>* floorId;//楼层次序

@property (assign, nonatomic) NSNumber<Optional>* sortId; //对客户端来说，这个是做排序用

@property (strong, nonatomic) NSString<Optional>* nick; //回答人代号
@property (strong, nonatomic) NSString<Optional>* toNick; //被回答人代号

@property (assign, nonatomic) int ansId;       //问题Id
@property (strong, nonatomic) NSString* ans; //问题文本
@property (assign, nonatomic) int likeNum;                //问题的点赞数(问题本身的)
@property (assign, nonatomic) int unlikeNum;              //踩数量(问题本身的)
@property (assign, nonatomic) int pubTime;        //发表时间戳

@property (strong, nonatomic) NSString<Optional>* selfLocDesc; //自定义的地理位置名称

@property (strong, nonatomic) NSNumber<Optional>* isImpeach;//是否举报过
@property (strong, nonatomic) NSNumber<Optional>* likeFlag;//是否赞踩过
@property (strong, nonatomic) NSNumber<Optional>* isMine;//是否归属个人

@property (strong, nonatomic) NSNumber<Optional>* isQuester;//题主标志，0不是，1是

@property (nonatomic, strong) DPAnswerModel<Optional,ConvertOnDemand>* otherAnsData;

- (NSComparisonResult)AscendingSort:(DPAnswerModel*)model;
- (NSComparisonResult)DecendingSort:(DPAnswerModel*)model;

@end

@interface BackendReturnData_2005 : BackendReturnData
@property (strong, nonatomic) NSArray<DPAnswerModel,Optional>* contData;
@end

@interface BackSourceInfo_2005 : BackSourceInfo
@property (strong, nonatomic) BackendReturnData_2005<Optional>* returnData;
@end
