//
//  BackSourceInfo_4001.h
//  BiuBiu
//
//  Created by haowenliang on 15/1/19.
//  Copyright (c) 2015年 dpsoft. All rights reserved.
//


//    //推送类命令，拉取不清空数据，确认才清空
//    function execCmd_4001()  //足迹新回答消息推送
//    {
//        /*
//         请求包：
//         {
//         "cmd":0x4001,
//         "dvcId":"qdq12",    //设备Id
//         "questId":[12345,23232]  //问题Id
//         }
//         响应包：
//         */
//        return "{
//          \"statusCode\":0,
//          \"statusInfo\":\"success\",
//          \"returnData\":{
//          \"contData\":[
//                    {
//                        \"questId\":12345,   //问题Id
//                        \"newAnsNum\":123    //新回答数
//                    },
//                    {
//                        \"questId\":12345,   //问题Id
//                        \"newAnsNum\":123    //新回答数
//                    }
//              ]
//          }
//      }";
//    }

#import "BackSourceInfo.h"
#import "BackendReturnData.h"
#import "BackendContentData.h"

@protocol BackendContentData_4001 <BackendContentData>
@end

@interface BackendContentData_4001 : BackendContentData

@property (assign, nonatomic) int questId;   //问题Id
@property (assign, nonatomic) int newAnsNum;    //新回答数

@end

@interface BackendReturnData_4001 : BackendReturnData
@property (strong, nonatomic) NSArray<BackendContentData_4001,Optional>* contData;
@end

@interface BackSourceInfo_4001 : BackSourceInfo
@property (strong, nonatomic) BackendReturnData_4001<Optional>* returnData;
@end
