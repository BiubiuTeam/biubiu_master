//
//  DPHttpService.h
//  biubiu
//
//  Created by haowenliang on 15/2/2.
//  Copyright (c) 2015年 dpsoft. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <JSONModel/JSONAPI.h>

#define BBServer_Cgi (@"http://183.131.76.109/cgi/user_svc.php")

#define kNotification_CmdObject @"_kNotification_CmdObject_"
#define kNotification_StatusCode @"_kNotification_StatusCode_"
#define kNotification_StatusInfo @"_kNotification_StatusInfo_"
#define kNotification_ReturnObject @"_kNotification_ReturnObject_"

#define kNotification_Error @"_kNotification_Error_"


#define kNotification_RegistCallBack @"_kNotification_RegistCallBack_" //设备注册、登陆回调

#define kNotification_ChangeLocationAuthorizationStatus @"_kNotification_ChangeLocationAuthorizationStatus_"

#define kNotification_UnfollowPostCallBack @"_kNotification_UnfollowPostCallBack_" //取消关注某个问题
#define kNotification_LoadUserPostCallBack @"_kNotification_LoadUserPostCallBack_" //加载用户提问列表
#define kNotification_AnswerPostCallBack @"_kNotification_AnswerPostCallBack_" //回答问题请求
#define kNotification_NewPostCallBack @"_kNotification_NewPostCallBack_" //发表提问回调
#define kNotification_FetchPostCallBack @"_kNotification_FetchPostCallBack_" //拉取问题详情回调
#define kNotification_FetchAnswerCallBack @"_kNotification_FetchAnswerCallBack_" //拉取回答详情回调
#define kNotification_VoteOptCallBack @"_kNotification_VoteOptCallBack_" //赞踩的操作回调

#define kNotification_FeedbackPost @"_kNotification_FeedbackPost_" //反馈发表成功
#define kNotification_UpdateAccountInfo @"_kNotification_UpdateAccountInfo_" //帐户信息加载成功


//推送
#define kNotification_PushMsgListCallBack @"_kNotification_PushMsgListCallBack_" //列表回调



@interface DPHttpService : NSObject

+ (DPHttpService*)shareInstance;
- (void)postRequestWithBody:(NSString*)bodyString completion:(JSONObjectBlock)completeBlock;
- (void)postRequestWithBodyDictionary:(NSDictionary*)bodyDict completion:(JSONObjectBlock)completeBlock;

//设备注册
- (void)registOrLoginPlatform;
- (void)updatePlatformInfo;

//写操作
//2006
- (void)excuteCmdToPublishAPost:(NSString*)content
                       latitude:(float)lat
                       logitude:(float)lon
                      signiture:(NSString*)sign
                       location:(NSString*)location BB_DEPRECATED_IOS(2_0, 2_1, "use excutePublishedCmd:latitude:logitude:signiture:location:questType:unionId:");

//2007
- (void)excuteCmdToAnswerThePost:(NSString*)content
                         questId:(NSInteger)questId
                          toNick:(NSString*)toNick
                        location:(NSString*)location;

//读操作
//2001
- (void)excuteCmdToLoadUserPostList:(NSInteger)type lastPostId:(NSInteger)lastId;
- (void)excuteCmdToLoadUserPostListEx:(NSInteger)type lastPostId:(NSInteger)lastId completion:(JSONObjectBlock)completeBlock;

//2002
- (void)excuteCmdToLoadUserFollowPostListEx:(NSInteger)type lastPostId:(NSInteger)lastId completion:(JSONObjectBlock)completeBlock;
//2004
- (void)excuteCmdToLoadNearbyPostListEx:(NSInteger)type
                             lastPostId:(NSInteger)lastId
                               latitude:(float)lat
                               logitude:(float)lon
                             completion:(JSONObjectBlock)completeBlock;
//2005
- (void)excuteCmdToLoadPostReplyList:(NSInteger)questId
                            loadType:(NSInteger)type
                         lastReplyId:(NSInteger)lastId
                          completion:(JSONObjectBlock)completeBlock;

//2008
- (void)excuteCmdToVoteQuestion:(NSInteger)questId
                          ansId:(NSInteger)ansId
                           like:(NSInteger)likeOrNot;
//2009
- (void)excuteCmdToFetchQuestion:(NSInteger)questId
                        latitude:(float)lat
                        logitude:(float)lon;
//用户反馈
- (void)uploadFeedbackWithMessage:(NSString*)message;
- (void)downloadFeedbacksWithCompletion:(JSONObjectBlock)completion;

/**
 4301-4303
 */
- (void)excuteCmdToPullPushInfo:(JSONObjectBlock)completion
                       latitude:(float)lat
                       logitude:(float)lon;

- (void)excuteCmdToPullNewMessage:(NSInteger)IdType
                           lastId:(NSInteger)lastId
                         latitude:(float)lat
                         logitude:(float)lon;

- (void)excuteCmdToDeletePushMsg:(NSArray*)delIds
                      completion:(JSONObjectBlock)completion;


//举报
- (void)reportPost:(NSInteger)postId;
- (void)reportAnswer:(NSInteger)ansId;
- (void)reportItem:(NSInteger)objId type:(NSInteger)type completion:(JSONObjectBlock)block;
- (void)reportSomething:(NSInteger)contType objectId:(NSInteger)contId reason:(NSInteger)reason message:(NSString*)message;
@end
