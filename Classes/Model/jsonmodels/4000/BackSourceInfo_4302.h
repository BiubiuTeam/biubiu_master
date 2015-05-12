//
//  BackSourceInfo_4302.h
//  biubiu
//
//  Created by haowenliang on 15/2/12.
//  Copyright (c) 2015年 dpsoft. All rights reserved.
//

#import "BackSourceInfo.h"

typedef NS_ENUM(NSUInteger, PushItemType) {
    PushItemType_Answer = 1,
    PushItemType_Upvote = 2,
    PushItemType_Question = 3,
    PushItemType_Topic = 4,
    PushItemType_FloorAns = 5,
};

@protocol DPPushItemModel <NSObject>

@end

@interface DPPushItemModel : JSONModel

@property (nonatomic, strong) NSNumber<Optional>* ullId;
@property (nonatomic, strong) NSNumber<Optional>* questId;
@property (nonatomic, strong) NSNumber<Optional>* ansId;
@property (nonatomic, strong) NSNumber<Optional>* pubTime;
@property (nonatomic, strong) NSNumber<Optional>* type;

@property (nonatomic, strong) NSString<Optional>* quest;
@property (nonatomic, strong) NSString<Optional>* ans;

//工会相关
@property (nonatomic, strong) NSNumber<Optional>* unionId;//如果为0则表示非工会问题
@property (nonatomic, strong) NSString<Optional>* unionName;
@property (nonatomic, strong) NSNumber<Optional>* isPass;

- (NSComparisonResult)sortInDescending:(DPPushItemModel*)object;

//资源由后台处理
@property (nonatomic, strong) NSString<Optional>* typePic;
@property (nonatomic, strong) NSString<Optional>* secAns;

@end

@interface BackendReturnData_4302 : JSONModel
@property (nonatomic, strong) NSArray<Optional, ConvertOnDemand, DPPushItemModel>* contData;
@end

@interface BackSourceInfo_4302 : BackSourceInfo
@property (nonatomic, strong) BackendReturnData_4302<Optional>* returnData;
@end
