//
//  BackSourceInfo_2007.h
//  BiuBiu
//
//  Created by haowenliang on 15/1/19.
//  Copyright (c) 2015年 dpsoft. All rights reserved.
//

//function execCmd_2007()   //回答问题


#import "BackSourceInfo.h"
#import "BackSourceInfo_2005.h"

@interface BackSourceInfo_2007 : BackSourceInfo

@property (nonatomic, strong) DPAnswerModel<Optional,ConvertOnDemand>* returnData;

@end
