//
//  BackSourceInfo_4002.h
//  BiuBiu
//
//  Created by haowenliang on 15/1/19.
//  Copyright (c) 2015年 dpsoft. All rights reserved.
//



//    //这里会把新消息全拉出来
//    function execCmd_4002()  //足迹新回答消息已读确认
//    {
//        /*
//         请求包：
//         {
//         "cmd":0x4002,
//         "dvcId":"qdq12",    //设备Id
//         "questId":[12345,23232]  //问题Id
//         }
//         响应包：
//         */
//        return "{
//          \"statusCode\":0,
//          \"statusInfo\":\"success\",
//          \"returnData\":{
//              \"contData\":[
//                    {
//                        \"questId\":12345,   //问题Id
//                        \"ansData\":[
//                        {
//                            \"ansId\":1231231,       //问题Id
//                            \"ans\":\"问题文本\",
//                            \"likeNum\":2,                //问题的点赞数(问题本身的)
//                            \"unlikeNum\":1,              //踩数量(问题本身的)
//                            \"pubTime\":1231231231        //发表时间戳
//                        },
//                        {
//                            \"ansId\":1231231,       //问题Id
//                            \"ans\":\"问题文本\",
//                            \"likeNum\":2,                //问题的点赞数(问题本身的)
//                            \"unlikeNum\":1,              //踩数量(问题本身的)
//                            \"pubTime\":1231231231        //发表时间戳
//                        }
//                        ]
//                    },
//                    {
//                        \"questId\":12345,   //问题Id
//                        \"ansData\":[
//                        {
//                            \"ansId\":1231231,       //问题Id
//                            \"ans\":\"问题文本\",
//                            \"likeNum\":2,                //问题的点赞数(问题本身的)
//                            \"unlikeNum\":1,              //踩数量(问题本身的)
//                            \"pubTime\":1231231231        //发表时间戳
//                        },
//                        {
//                            \"ansId\":1231231,       //问题Id
//                            \"ans\":\"问题文本\",    
//                            \"likeNum\":2,                //问题的点赞数(问题本身的)
//                            \"unlikeNum\":1,              //踩数量(问题本身的)
//                            \"pubTime\":1231231231        //发表时间戳
//                        }
//                        ]
//                    },
//              ]
//          }
//      }";
//    }

#import "BackSourceInfo.h"
#import "BackendReturnData.h"
#import "BackendContentData.h"
#import "BackendAnsData.h"

@protocol BackendContentData_4002 <BackendContentData>
@end
@interface BackendContentData_4002 : BackendContentData

@property (assign, nonatomic) int questId;   //问题Id
@property (strong, nonatomic) NSArray<BackendAnsData,Optional,ConvertOnDemand>* ansData;    //新回答内容

@end

@interface BackendReturnData_4002 : BackendReturnData
@property (strong, nonatomic) NSArray<BackendContentData_4002,Optional>* contData;
@end


@interface BackSourceInfo_4002 : BackSourceInfo
@property (strong, nonatomic) BackendReturnData_4002<Optional>* returnData;
@end
