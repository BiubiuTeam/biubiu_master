//
//  BackSourceInfo_2002.h
//  BiuBiu
//
//  Created by haowenliang on 15/1/19.
//  Copyright (c) 2015年 dpsoft. All rights reserved.
//

//    function execCmd_2002()   //拉取我参与的问题列表

#import "BackSourceInfo.h"
#import "BackendReturnData.h"
#import "BackendContentData.h"
#import "BackendAnsData.h"
#import "BackSourceInfo_2001.h"

@interface BackendReturnData_2002 : BackendReturnData
@property (strong, nonatomic) NSArray<DPQuestionModel,Optional>* contData;
@end

@interface BackSourceInfo_2002 : BackSourceInfo

@property (strong, nonatomic) BackendReturnData_2002<Optional>* returnData;
@end
