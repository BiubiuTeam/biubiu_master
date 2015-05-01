//
//  BackSourceInfo_4102.h
//  BiuBiu
//
//  Created by haowenliang on 15/1/19.
//  Copyright (c) 2015年 dpsoft. All rights reserved.
//

//    function execCmd_4102()  //附近新消息确认
//    {
//        /*
//         请求包：
//         {
//         "cmd":0x4102,
//         "dvcId":"qdq12",    //设备Id
//         "latitude":32,      //经度
//         "longitude":23      //纬度
//         }
//         响应包：
//         */
//        return "{
//            \"statusCode\":0,
//            \"statusInfo\":\"success\",
//            \"returnData\":{
//              \"contData\":[
//                    {
//                        \"questId\":1231231,       //问题Id
//                        \"quest\":\"问题文本\",
//                        \"ansNum\":10,             //评论数
//                        \"pubTime\":1231231231        //发表时间戳
//                    },
//                    {
//                        \"questId\":1231231,       //问题Id
//                        \"quest\":\"问题文本\",
//                        \"ansNum\":10,             //评论数
//                        \"pubTime\":1231231231        //发表时间戳
//                    }
//                ]
//            }
//        }";
//    }
#import "BackSourceInfo.h"
#import "BackendReturnData.h"
#import "BackendContentData.h"

@protocol BackendContentData_4102 <BackendContentData>
@end

@interface BackendContentData_4102 : BackendContentData

@property (assign, nonatomic) int questId;   //问题Id
@property (assign, nonatomic) int ansNum;    //评论数
@property (assign, nonatomic) int pubTime;    //发表时间戳
@property (strong, nonatomic) NSString* quest;  //问题文本

@end

@interface BackendReturnData_4102 : BackendReturnData
@property (strong, nonatomic) NSArray<BackendContentData_4102,Optional>* contData;
@end

@interface BackSourceInfo_4102 : BackSourceInfo
@property (strong, nonatomic) BackendReturnData_4102<Optional>* returnData;
@end
