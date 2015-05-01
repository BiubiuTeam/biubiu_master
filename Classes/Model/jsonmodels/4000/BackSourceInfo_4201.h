//
//  BackSourceInfo_4201.h
//  BiuBiu
//
//  Created by haowenliang on 15/1/19.
//  Copyright (c) 2015年 dpsoft. All rights reserved.
//

//    function execCmd_4201()  //我参与的新赞拉取
//    {
//        /*
//         请求包：
//         {
//         "cmd":0x4201,
//         "dvcId":"qdq12",         //设备Id
//         "questId":[12345,23232]  //问题Id
//         }
//         响应包：
//         */
//        return "{
//            \"statusCode\":0,
//            \"statusInfo\":\"success\",
//            \"returnData\":{
//              \"contData\":[
//                    {
//                        \"questId\":12345,    //问题Id
//                        \"newLikeNum\":123    //新点赞数
//                        \"newAnsNum\":123     //新回答数
//                    },
//                    {
//                        \"questId\":12345,    //问题Id
//                        \"newLikeNum\":123    //新点赞数
//                        \"newAnsNum\":123     //新回答数
//                    }
//                ]
//            }
//        }";
//    }
#import "BackSourceInfo.h"
#import "BackendReturnData.h"
#import "BackendContentData.h"

@protocol BackendContentData_4201 <BackendContentData>
@end

@interface BackendContentData_4201 : BackendContentData

@property (assign, nonatomic) int questId;    //问题Id
@property (assign, nonatomic) int newLikeNum;   //新点赞数
@property (assign, nonatomic) int newAnsNum;     //新回答数

@end

@interface BackendReturnData_4201 : BackendReturnData

@property (strong, nonatomic) NSArray<BackendContentData_4201,Optional>* contData;

@end

@interface BackSourceInfo_4201 : BackSourceInfo
@property (strong, nonatomic) BackendReturnData_4201<Optional>* returnData;
@end
