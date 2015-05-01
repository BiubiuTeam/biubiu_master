//
//  BackSourceInfo_3002.h
//  BiuBiu
//
//  Created by haowenliang on 15/1/19.
//  Copyright (c) 2015年 dpsoft. All rights reserved.
//

//    function execCmd_3002()  //用户反馈查询(随机拉取)

#import "BackSourceInfo.h"

@protocol BackendContentData_3002
@end

@interface BackendContentData_3002 : JSONModel

@property (strong, nonatomic) NSString<Optional>* cont;   //反馈内容

@end

@interface BackendReturnData_3002 : JSONModel
@property (strong, nonatomic) NSArray<BackendContentData_3002,Optional,ConvertOnDemand>* contData;
@end

@interface BackSourceInfo_3002 : BackSourceInfo

@property (strong, nonatomic) BackendReturnData_3002<Optional,ConvertOnDemand>* returnData;

@end
