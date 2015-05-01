//
//  BackSourceInfo_2004.h
//  BiuBiu
//
//  Created by haowenliang on 15/1/19.
//  Copyright (c) 2015年 dpsoft. All rights reserved.
//

//
//    function execCmd_2004()   //拉取附近的发问列表

#import "BackSourceInfo.h"
#import "BackendReturnData.h"
#import "BackendContentData.h"
#import "BackSourceInfo_2001.h"

@interface BackendReturnData_2004 : BackendReturnData
@property (strong, nonatomic) NSArray<DPQuestionModel,Optional>* contData;
@end

@interface BackSourceInfo_2004 : BackSourceInfo
@property (strong, nonatomic) BackendReturnData_2004<Optional>* returnData;
@end
