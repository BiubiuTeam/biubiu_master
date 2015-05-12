//
//  BackSourceInfo_1004.h
//  BiuBiu
//
//  Created by haowenliang on 15/1/19.
//  Copyright (c) 2015年 dpsoft. All rights reserved.
//

//    function execCmd_1004()   //用户信息查询
//    {
//        /*
//         请求包：
//         {
//         "cmd":0x1004,
//         "dvcId":"qdq12",    //设备Id
//         }
//         响应包：
//         */
//        return "{
//            \"statusCode\":0,
//            \"statusInfo\":\"success\",
//            \"returnData\":{
//                \"score\": 156,    //积分
//                \"recDay\": 24,    //加入天数
//                \"questionNum\": 25,     //提出的问题数
//                \"answerNum\": 44,       //得到的答案数
//                \"otherAnswerNum\": 46,  //回答别人问题数
//                \"otherLikeNum\": 12,    //得到的赞
//                \"isNewAnsPush\": 1      //是否推送足迹新回答 这三个字段均是1推送 0不推送
//                \"isNewLikePush\": 1     //是否推送参与的新赞
//                \"isNewQuestPush\": 1    //是否推送附近新问题
//            }
//        }";
//    }
#import "BackSourceInfo.h"

@interface BackendReturnData_1004 : JSONModel

@property (assign, nonatomic) int score;    //积分
@property (assign, nonatomic) int recDay;    //加入天数
@property (assign, nonatomic) int questionNum;     //提出的问题数
@property (assign, nonatomic) int answerNum;       //得到的答案数
@property (assign, nonatomic) int otherAnswerNum;  //回答别人问题数
@property (assign, nonatomic) int otherLikeNum;    //得到的赞
@property (assign, nonatomic) int isNewAnsPush;      //是否推送足迹新回答 这三个字段均是1推送 0不推送
@property (assign, nonatomic) int isNewLikePush;     //是否推送参与的新赞
@property (assign, nonatomic) int isNewQuestPush;    //是否推送附近新问题

@property (nonatomic, strong) NSNumber<Optional>* rank;
@property (nonatomic, strong) NSNumber<Optional>* rankRate;

@property (nonatomic, strong) NSNumber<Optional>* unionNum;//创建版块数目

//做能力预埋，明知不可为而为之
@property (nonatomic, strong) NSNumber<Optional>* closeAppeal;//3隐藏致老用户入口
@property (nonatomic, strong) NSNumber<Optional>* openCheckin;//3审核入口

@property (nonatomic, strong) NSNumber<Optional>* isPush;//是否允许总的推送
@property (nonatomic, strong) NSNumber<Optional>* creUnionFlag;//允许创建版块 1允许0不允许
@end

@interface BackSourceInfo_1004 : BackSourceInfo
@property (strong, nonatomic) BackendReturnData_1004<Optional,ConvertOnDemand>* returnData;
@end
