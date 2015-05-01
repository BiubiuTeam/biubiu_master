//
//  BackSourceInfo_4101.h
//  BiuBiu
//
//  Created by haowenliang on 15/1/19.
//  Copyright (c) 2015年 dpsoft. All rights reserved.
//

//    function execCmd_4101()  //附近新消息推送
//    {
//        /*
//         请求包：
//         {
//         "cmd":0x4101,
//         "dvcId":"qdq12",  //设备Id
//         "latitude":32,    //经度
//         "longitude":23    //纬度
//         }
//         响应包：
//         */
//        return "{
//            \"statusCode\":0,
//            \"statusInfo\":\"success\",
//            \"returnData\":{
//                \"newQuestNum\":20   //新问题数
//            }
//        }";
//    }
#import "BackSourceInfo.h"
#import "BackendReturnData.h"

@interface BackendReturnData_4101 : BackendReturnData
@property (assign, nonatomic) int newQuestNum;  //新问题数
@end

@interface BackSourceInfo_4101 : BackSourceInfo
@property (strong, nonatomic) BackendReturnData_4101<Optional>* returnData;
@end
