//
//  DPHttpService.m
//  biubiu
//
//  Created by haowenliang on 15/2/2.
//  Copyright (c) 2015年 dpsoft. All rights reserved.
//

#import "DPHttpService.h"
#import "SvUDIDTools.h"
#import "NSStringAdditions.h"
#import "NSDictionaryAdditions.h"
#import "DPLbsServerEngine.h"
#import "BackSourceInfo_1001.h"
#import "BackSourceInfo_1004.h"

#import "BackSourceInfo_2001.h"
#import "BackSourceInfo_2009.h"

#import "BackSourceInfo_3001.h"
#import "BackSourceInfo_3002.h"

#import "BackSourceInfo_5001.h"
#import "APService.h"
@implementation DPHttpService

+ (DPHttpService*)shareInstance
{
    static DPHttpService* _sService = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sService = [[DPHttpService alloc] init];
    });
    return _sService;
}

#pragma mark -1字段
//1001
- (void)registOrLoginPlatform
{
    NSMutableDictionary* body = [NSMutableDictionary dictionary];
    [body setObject:[NSNumber numberWithInteger:0x1001] forKey:@"cmd"];
    [body setObject:[SvUDIDTools aliasUdid] forKey:@"alias"];
    
    [self postRequestWithBodyDictionary:body completion:^(id json, JSONModelError *err) {
        NSMutableDictionary* userInfo = [[NSMutableDictionary alloc] init];
        if (err == nil) {
            NSError* dError = nil;
            BackSourceInfo_1001* backSource = [[BackSourceInfo_1001 alloc] initWithDictionary:json error:&dError];
            if (dError) {
                DPTrace("0x1001数据解析 ： %@",dError);
                [userInfo setObject:@(-2) forKey:kNotification_StatusCode];
            }else if (backSource.statusCode == 0) {
                DPTrace("注册成功");
                [userInfo setObject:@(backSource.statusCode) forKey:kNotification_StatusCode];
            }else if(backSource.statusCode == 1){
                DPTrace("登陆成功");
                [userInfo setObject:@(backSource.statusCode) forKey:kNotification_StatusCode];
            }else{
                DPTrace("0x1001未知错误码 ：%zd, %@",backSource.statusCode,dError);
                [userInfo setObject:@(backSource.statusCode) forKey:kNotification_StatusCode];
            }
        }else{
            DPTrace("0x1001请求失败 ： %@",err);
            [userInfo setObject:@(-1) forKey:kNotification_StatusCode];
        }
        [[NSNotificationCenter defaultCenter] postNotificationName:kNotification_RegistCallBack object:nil userInfo:userInfo];
    }];
    
    
    [APService setTags:nil
                 alias:[SvUDIDTools aliasUdid]
      callbackSelector:@selector(tagsAliasCallback:tags:alias:)
                target:self];
}

- (void)tagsAliasCallback:(int)iResCode
                     tags:(NSSet *)tags
                    alias:(NSString *)alias
{
    NSLog(@"TagsAlias回调:%zd, %@", iResCode,alias);
}

//1004
- (void)updatePlatformInfo
{
    NSMutableDictionary* body = [NSMutableDictionary dictionary];
    [body setObject:[NSNumber numberWithInteger:0x1004] forKey:@"cmd"];
    [self postRequestWithBodyDictionary:body completion:^(id json, JSONModelError *err) {
        
        NSMutableDictionary* userInfo = [[NSMutableDictionary alloc] init];
        
        if (err == nil) {
            NSError* dError = nil;
            BackSourceInfo_1004* backSource = [[BackSourceInfo_1004 alloc] initWithDictionary:json error:&dError];
            if (backSource && backSource.statusCode == 0) {
                [userInfo setObject:backSource forKey:kNotification_ReturnObject];
            }else{
                DPTrace("0x1004数据解析 ： %@",dError);
            }
            [userInfo setObject:@(backSource.statusCode) forKey:kNotification_StatusCode];
            [userInfo setObject:@"" forKey:kNotification_StatusInfo];
        }else{
            [userInfo setObject:@(-1) forKey:kNotification_StatusCode];
            [userInfo setObject:[err description] forKey:kNotification_StatusInfo];
            
            DPTrace("0x1004请求失败 ： %@",err);
        }
        [[NSNotificationCenter defaultCenter] postNotificationName:kNotification_UpdateAccountInfo object:nil userInfo:userInfo];
    }];
}

#pragma mark -2字段
/*
 请求包：
 {
 "cmd":0x2001,
 "dvcId":"qdq12",    //设备Id
 "IdType":1,        //1 上推拉取更久的信息   2 下拉刷出最新的数据
 "lastId":0         //上推模式会以这个Id为起点拉取更久的信息，下拉模式会以这个Id为起点拉取更新的信息，如果要直接刷新拉最新的数据，这里直接给0即可。默认一次10条
 }
 */
- (void)excuteCmdToLoadUserPostList:(NSInteger)type lastPostId:(NSInteger)lastId
{
    NSMutableDictionary* body = [NSMutableDictionary dictionary];
    [body setObject:[NSNumber numberWithInteger:0x2001] forKey:@"cmd"];
    [body setObject:@(type) forKey:@"IdType"];
    [body setObject:@(lastId) forKey:@"lastId"];
    
    [self postRequestWithBodyDictionary:body completion:^(id json, JSONModelError *err) {
        NSMutableDictionary* userInfo = [[NSMutableDictionary alloc] init];
        if (nil == err) {
            BackSourceInfo_2001* backSource = [[BackSourceInfo_2001 alloc] initWithDictionary:json error:nil];
            [userInfo setObject:@(backSource.statusCode) forKey:kNotification_StatusCode];
            [userInfo setObject:backSource.statusInfo forKey:kNotification_StatusInfo];
            BackendReturnData_2001* returnData = backSource.returnData;
            if ([returnData.contData count]) {
                [userInfo setObject:returnData.contData forKey:kNotification_ReturnObject];
            }
        }else{
            [userInfo setObject:@(-1) forKey:kNotification_StatusCode];
            [userInfo setObject:[NSString stringWithFormat:@"%@",[err description]] forKey:kNotification_StatusInfo];
        }
        [[NSNotificationCenter defaultCenter] postNotificationName:kNotification_LoadUserPostCallBack object:nil userInfo:userInfo];
    }];
}

- (void)excuteCmdToLoadUserPostListEx:(NSInteger)type lastPostId:(NSInteger)lastId completion:(JSONObjectBlock)completeBlock
{
    NSMutableDictionary* body = [NSMutableDictionary dictionary];
    [body setObject:[NSNumber numberWithInteger:0x2001] forKey:@"cmd"];
    [body setObject:@(type) forKey:@"IdType"];
    [body setObject:@(lastId) forKey:@"lastId"];
    [self postRequestWithBodyDictionary:body completion:completeBlock];
}

/*
 请求包：
 {
 "cmd":0x2002,
 "dvcId":"qdq12",    //设备Id
 "IdType":1,        //1 上推拉取更久的信息   2 下拉刷出最新的数据
 "lastId":0         //上推模式会以这个Id为起点拉取更久的信息，下拉模式会以这个Id为起点拉取更新的信息，如果要直接刷新拉最新的数据，这里直接给0即可。默认一次5条
 }
 响应包：
 */

- (void)excuteCmdToLoadUserFollowPostListEx:(NSInteger)type lastPostId:(NSInteger)lastId completion:(JSONObjectBlock)completeBlock
{
    NSMutableDictionary* body = [NSMutableDictionary dictionary];
    [body setObject:[NSNumber numberWithInteger:0x2002] forKey:@"cmd"];
    [body setObject:@(type) forKey:@"IdType"];
    [body setObject:@(lastId) forKey:@"lastId"];
    [self postRequestWithBodyDictionary:body completion:completeBlock];
}


/*
 请求包：
 {
 "cmd":0x2003,
 "dvcId":"qdq12",    //设备Id
 "questId":1212412   //问题Id
 }
 */
- (void)excuteCmdUnfollowQuestion:(NSInteger)questId
{
    NSMutableDictionary* body = [NSMutableDictionary dictionary];
    [body setObject:[NSNumber numberWithInteger:0x2003] forKey:@"cmd"];
    [body setObject:@(questId) forKey:@"questId"];
    [self postRequestWithBodyDictionary:body completion:^(id json, JSONModelError *err) {
        NSMutableDictionary* userInfo = [[NSMutableDictionary alloc] init];
        if (nil == err) {
            BackSourceInfo* backSource = [[BackSourceInfo alloc] initWithDictionary:json error:nil];
            [userInfo setObject:@(backSource.statusCode) forKey:kNotification_StatusCode];
            [userInfo setObject:backSource.statusInfo forKey:kNotification_StatusInfo];
        }else{
            [userInfo setObject:@(-1) forKey:kNotification_StatusCode];
            [userInfo setObject:[NSString stringWithFormat:@"%@",[err description]] forKey:kNotification_StatusInfo];
        }
        [[NSNotificationCenter defaultCenter] postNotificationName:kNotification_UnfollowPostCallBack object:nil userInfo:userInfo];
    }];
}


/*
 请求包：
 {
 "cmd":0x2004,
 "dvcId":"qdq12",    //设备Id
 "latitude":32,     //经度
 "longitude":12,    //纬度
 "IdType":1,        //1 上推拉取更久的信息   2 下拉刷出最新的数据
 "lastId":0         //上推模式会以这个Id为起点拉取更久的信息，下拉模式会以这个Id为起点拉取更新的信息，如果要直接刷新拉最新的数据，这里直接给0即可。默认一次10条
 }
 */
- (void)excuteCmdToLoadNearbyPostListEx:(NSInteger)type
                             lastPostId:(NSInteger)lastId
                               latitude:(float)lat
                               logitude:(float)lon
                             completion:(JSONObjectBlock)completeBlock
{
    NSMutableDictionary* body = [NSMutableDictionary dictionary];
    [body setObject:[NSNumber numberWithInteger:0x2004] forKey:@"cmd"];
    [body setObject:@(type) forKey:@"IdType"];
    [body setObject:@(lastId) forKey:@"lastId"];
    [body setObject:@(lat) forKey:@"latitude"];
    [body setObject:@(lon) forKey:@"longitude"];
    [self postRequestWithBodyDictionary:body completion:completeBlock];
}

/*
 请求包：
 {
 "cmd":0x2005,
 "dvcId":"qdq12",    //设备Id
 "questId":3223324,  //问题Id
 "IdType":1,        //1 上推拉取更久的信息   2 下拉刷出最新的数据
 "lastId":0         //上推模式会以这个Id为起点拉取更久的信息，下拉模式会以这个Id为起点拉取更新的信息，如果要直接刷新拉最新的数据，这里直接给0即可。默认一次10条
 }
 */
- (void)excuteCmdToLoadPostReplyList:(NSInteger)questId
                            loadType:(NSInteger)type
                             lastReplyId:(NSInteger)lastId
                             completion:(JSONObjectBlock)completeBlock
{
    NSMutableDictionary* body = [NSMutableDictionary dictionary];
    [body setObject:[NSNumber numberWithInteger:0x2005] forKey:@"cmd"];
    [body setObject:@(questId) forKey:@"questId"];
    [body setObject:@(type) forKey:@"IdType"];
    [body setObject:@(lastId) forKey:@"lastId"];
    [self postRequestWithBodyDictionary:body completion:completeBlock];
}

/*
 请求包：
 {
 "cmd":0x2006,
 "dvcId":"qdq12",    //设备Id
 "latitude":32, //经度
 "longitude":12,    //纬度
 "quest":"问题文本",
 "sign":"署名"
 }
 */
- (void)excuteCmdToPublishAPost:(NSString*)content
                           latitude:(float)lat
                           logitude:(float)lon
                      signiture:(NSString*)sign
                       location:(NSString*)location
{
    NSMutableDictionary* body = [NSMutableDictionary dictionary];
    [body setObject:[NSNumber numberWithInteger:0x2006] forKey:@"cmd"];
    [body setObject:content forKey:@"quest"];
    [body setObject:@(lat) forKey:@"latitude"];
    [body setObject:@(lon) forKey:@"longitude"];
    if (![sign length]) {
        sign = @"";//NSLocalizedString(@"BB_TXTID_匿名", nil);
    }
    [body setObject:sign forKey:@"sign"];
    
    if ([location length]) {
        [body setObject:location forKey:@"selfLocDesc"];
    }
    
    [self postRequestWithBodyDictionary:body completion:^(id json, JSONModelError *err) {
        NSMutableDictionary* userInfo = [[NSMutableDictionary alloc] init];
        if (nil == err) {
            BackSourceInfo* backSource = [[BackSourceInfo alloc] initWithDictionary:json error:nil];
            [userInfo setObject:@(backSource.statusCode) forKey:kNotification_StatusCode];
            [userInfo setObject:backSource.statusInfo forKey:kNotification_StatusInfo];
        }else{
            [userInfo setObject:@(-1) forKey:kNotification_StatusCode];
            [userInfo setObject:[NSString stringWithFormat:@"%@",[err description]] forKey:kNotification_StatusInfo];
        }
        [[NSNotificationCenter defaultCenter] postNotificationName:kNotification_NewPostCallBack object:nil userInfo:userInfo];
    }];
}

/*
 请求包：
 {
 "cmd":0x2007,
 "dvcId":"qdq12",    //设备Id
 "questId":1231241,  //问题Id
 "ans":"回答文本",
 "toNick":"被回答人代号",    //如果针对问题回答而非某个人某个评论的回答，则此处为空。
 }
 */
- (void)excuteCmdToAnswerThePost:(NSString*)content
                       questId:(NSInteger)questId
                           ansId:(NSInteger)ansId
                          toNick:(NSString*)toNick
                        location:(NSString*)location
{
    NSMutableDictionary* body = [NSMutableDictionary dictionary];
    [body setObject:[NSNumber numberWithInteger:0x2007] forKey:@"cmd"];
    [body setObject:content forKey:@"ans"];
    [body setObject:@(questId) forKey:@"questId"];
    [body setObject:@(ansId) forKey:@"ansId"];
    
    if ([toNick length]) {
        [body setObject:toNick forKey:@"toNick"];
    }
    
    if ([location length]) {
        [body setObject:location forKey:@"selfLocDesc"];
    }
    
    __block NSMutableDictionary* userInfo = [[NSMutableDictionary alloc] init];
    [userInfo setObject:body forKey:kNotification_CmdObject];
    
    [self postRequestWithBodyDictionary:body completion:^(id json, JSONModelError *err) {
        if (nil == err) {
            BackSourceInfo* backSource = [[BackSourceInfo alloc] initWithDictionary:json error:nil];
            [userInfo setObject:@(backSource.statusCode) forKey:kNotification_StatusCode];
            [userInfo setObject:backSource.statusInfo forKey:kNotification_StatusInfo];
        }else{
            [userInfo setObject:@(-1) forKey:kNotification_StatusCode];
            [userInfo setObject:[NSString stringWithFormat:@"%@",[err description]] forKey:kNotification_StatusInfo];
        }
        [[NSNotificationCenter defaultCenter] postNotificationName:kNotification_AnswerPostCallBack object:nil userInfo:userInfo];
    }];
}

/*
 请求包：
 {
 "cmd":0x2008,
 "dvcId":"qdq12",    //设备Id
 "questId":1,      //问题Id
 "ansId":1231241,  //回答Id(如果只是对某个问题点赞，则这里为0)
 "like":1            //1赞 2踩
 }
 响应包：
 */
- (void)excuteCmdToVoteQuestion:(NSInteger)questId
                          ansId:(NSInteger)ansId
                           like:(NSInteger)likeOrNot
{
    NSMutableDictionary* body = [NSMutableDictionary dictionary];
    [body setObject:[NSNumber numberWithInteger:0x2008] forKey:@"cmd"];
    [body setObject:@(ansId) forKey:@"ansId"];
    [body setObject:@(questId) forKey:@"questId"];
    [body setObject:@(likeOrNot) forKey:@"like"];
    
    __block NSMutableDictionary* userInfo = [[NSMutableDictionary alloc] init];
    [userInfo setObject:body forKey:kNotification_CmdObject];
    [self postRequestWithBodyDictionary:body completion:^(id json, JSONModelError *err) {
        if (nil == err) {
            BackSourceInfo* backSource = [[BackSourceInfo alloc] initWithDictionary:json error:nil];
            [userInfo setObject:@(backSource.statusCode) forKey:kNotification_StatusCode];
            [userInfo setObject:backSource.statusInfo forKey:kNotification_StatusInfo];
        }else{
            [userInfo setObject:@(-1) forKey:kNotification_StatusCode];
            [userInfo setObject:[NSString stringWithFormat:@"%@",[err description]] forKey:kNotification_StatusInfo];
        }
        [[NSNotificationCenter defaultCenter] postNotificationName:kNotification_VoteOptCallBack object:nil userInfo:userInfo];
    }];
}

/*
 请求包：
 {
 "cmd":0x2009,
 "dvcId":"qdq12",   //设备Id
 "latitude":32,     //经度
 "longitude":12,    //纬度
 "questId":19
 }
 */
- (void)excuteCmdToFetchQuestion:(NSInteger)questId
                       latitude:(float)lat
                       logitude:(float)lon
{
    NSMutableDictionary* body = [NSMutableDictionary dictionary];
    [body setObject:[NSNumber numberWithInteger:0x2009] forKey:@"cmd"];
    [body setObject:@(questId) forKey:@"questId"];
    [body setObject:@(lat) forKey:@"latitude"];
    [body setObject:@(lon) forKey:@"longitude"];
    
    [self postRequestWithBodyDictionary:body completion:^(id json, JSONModelError *err) {
        NSMutableDictionary* userInfo = [[NSMutableDictionary alloc] init];
        if (nil == err) {
            BackSourceInfo_2009* backSource = [[BackSourceInfo_2009 alloc] initWithDictionary:json error:&err];
            if (err == nil) {
                [userInfo setObject:@(backSource.statusCode) forKey:kNotification_StatusCode];
                [userInfo setObject:backSource.statusInfo forKey:kNotification_StatusInfo];
                if (backSource.returnData) {
                    [userInfo setObject:backSource.returnData forKey:kNotification_ReturnObject];
                }
            }else{
                [userInfo setObject:@(-2) forKey:kNotification_StatusCode];
                [userInfo setObject:[NSString stringWithFormat:@"%@",[err description]] forKey:kNotification_StatusInfo];
            }
        }else{
            [userInfo setObject:@(-1) forKey:kNotification_StatusCode];
            [userInfo setObject:[NSString stringWithFormat:@"%@",[err description]] forKey:kNotification_StatusInfo];
        }
        [[NSNotificationCenter defaultCenter] postNotificationName:kNotification_FetchPostCallBack object:nil userInfo:userInfo];
    }];
}

/*
 请求包：
 {
 "cmd":0x200a,
 "dvcId":"qdq12",    //设备Id
 "latitude":32,     //经度
 "longitude":12,    //纬度
 "questId":3223324,  //问题Id
 "ansId":123,       //回答Id
 }
 */
- (void)excuteCmdToFetchAnswer:(NSInteger)questId
                         ansId:(NSInteger)ansId
                      latitude:(float)lat
                      logitude:(float)lon
{
    NSMutableDictionary* body = [NSMutableDictionary dictionary];
    [body setObject:[NSNumber numberWithInteger:0x200a] forKey:@"cmd"];
    [body setObject:@(questId) forKey:@"questId"];
    [body setObject:@(ansId) forKey:@"ansId"];
    [body setObject:@(lat) forKey:@"latitude"];
    [body setObject:@(lon) forKey:@"longitude"];
    
    [self postRequestWithBodyDictionary:body completion:^(id json, JSONModelError *err){
        NSMutableDictionary* userInfo = [[NSMutableDictionary alloc] init];
        if (nil == err) {
            BackSourceInfo_2009* backSource = [[BackSourceInfo_2009 alloc] initWithDictionary:json error:&err];
            if (err == nil) {
                [userInfo setObject:@(backSource.statusCode) forKey:kNotification_StatusCode];
                [userInfo setObject:backSource.statusInfo forKey:kNotification_StatusInfo];
                if (backSource.returnData) {
                    [userInfo setObject:backSource.returnData forKey:kNotification_ReturnObject];
                }
            }else{
                [userInfo setObject:@(-2) forKey:kNotification_StatusCode];
                [userInfo setObject:[NSString stringWithFormat:@"%@",[err description]] forKey:kNotification_StatusInfo];
            }
        }else{
            [userInfo setObject:@(-1) forKey:kNotification_StatusCode];
            [userInfo setObject:[NSString stringWithFormat:@"%@",[err description]] forKey:kNotification_StatusInfo];
        }
        [[NSNotificationCenter defaultCenter] postNotificationName:kNotification_FetchAnswerCallBack object:nil userInfo:userInfo];
    }];
}

#pragma mark -3字段
/*
 "cmd":0x3001,
 "dvcId":"qdq12",    //设备Id
 "comment":"反馈信息",
 "verId":1, //版本Id
 "osVer":"Android4.3.1" //操作系统信息
 */
- (void)uploadFeedbackWithMessage:(NSString*)message
{
    NSMutableDictionary* body = [NSMutableDictionary dictionary];
    [body setObject:[NSNumber numberWithInteger:0x3001] forKey:@"cmd"];
    [body setObject:@1 forKey:@"verId"];
    [body setObject:[NSString stringWithFormat:@"iOS%zd",SYSTEM_VERSION] forKey:@"osVer"];
    [body setObject:message forKey:@"comment"];
    
    [self postRequestWithBodyDictionary:body completion:^(id json, JSONModelError *err) {
        NSMutableDictionary* userInfo = [[NSMutableDictionary alloc] init];
        if (nil == err) {
            BackSourceInfo_3001* backSource = [[BackSourceInfo_3001 alloc] initWithDictionary:json error:nil];
            [userInfo setObject:@(backSource.statusCode) forKey:kNotification_StatusCode];
            [userInfo setObject:backSource.statusInfo forKey:kNotification_StatusInfo];
        }else{
            [userInfo setObject:@(-1) forKey:kNotification_StatusCode];
            [userInfo setObject:[NSString stringWithFormat:@"%@",[err description]] forKey:kNotification_StatusInfo];
        }
        [[NSNotificationCenter defaultCenter] postNotificationName:kNotification_FeedbackPost object:nil userInfo:userInfo];
    }];
}

- (void)downloadFeedbacksWithCompletion:(JSONObjectBlock)completion
{
    NSMutableDictionary* body = [NSMutableDictionary dictionary];
    [body setObject:[NSNumber numberWithInteger:0x3002] forKey:@"cmd"];
    [self postRequestWithBodyDictionary:body completion:^(id json, JSONModelError *err) {
        if (nil == err) {
            BackSourceInfo_3002* backSource = [[BackSourceInfo_3002 alloc] initWithDictionary:json error:nil];
            if (backSource.statusCode == 0) {
                BackendReturnData_3002* returnData = backSource.returnData;
                if (completion) {
                    completion(returnData.contData, nil);
                }
            }else{
                if (completion) {
                    completion(nil, err);
                }
            }
        }else{
            if (completion) {
                completion(nil, err);
            }
        }
    }];
}

#pragma mark -4字段
/*
 请求包：
 {
 "cmd":0x4301,
 "dvcId":"qdq12",         //设备Id
 "latitude":32,     //经度
 "longitude":23,    //纬度
 }
 */
- (void)excuteCmdToPullPushInfo:(JSONObjectBlock)completion
                       latitude:(float)lat
                       logitude:(float)lon
{
    NSMutableDictionary* body = [NSMutableDictionary dictionary];
    [body setObject:[NSNumber numberWithInteger:0x4301] forKey:@"cmd"];
    [body setObject:@(lat) forKey:@"latitude"];
    [body setObject:@(lon) forKey:@"longitude"];
    
    [self postRequestWithBodyDictionary:body completion:completion];
}

/*
 请求包：
 {
 "cmd":0x4302,
 "dvcId":"qdq12",         //设备Id
 "latitude":32,     //经度
 "longitude":23,    //纬度
 "IdType":1,        //1 上推拉取更久的信息   2 下拉刷出最新的数据
 "lastId":0
 }
 */
- (void)excuteCmdToPullNewMessage:(NSInteger)IdType
                           lastId:(NSInteger)lastId
                         latitude:(float)lat
                         logitude:(float)lon
{
    NSMutableDictionary* body = [NSMutableDictionary dictionary];
    [body setObject:[NSNumber numberWithInteger:0x4302] forKey:@"cmd"];
    [body setObject:@(IdType) forKey:@"IdType"];
    [body setObject:@(lastId) forKey:@"lastId"];
    [body setObject:@(lat) forKey:@"latitude"];
    [body setObject:@(lon) forKey:@"longitude"];
    
    __block NSMutableDictionary* userInfo = [[NSMutableDictionary alloc] init];
    [userInfo setObject:body forKey:kNotification_CmdObject];
    [self postRequestWithBodyDictionary:body completion:^(id json, JSONModelError *err) {
        DPTrace("%@",json);
        if (json) {
            [userInfo setObject:json forKey:kNotification_ReturnObject];
        }
        if (err) {
            [userInfo setObject:err forKey:kNotification_StatusInfo];
        }
        
        [[NSNotificationCenter defaultCenter] postNotificationName:kNotification_PushMsgListCallBack object:nil userInfo:userInfo];
    }];
}

/*
 请求包：
 {
 "cmd":0x4302,
 "dvcId":"qdq12",         //设备Id
 "delId":[12345,2456]     //这里的Id就是4302里回包的ullId
 }
 */

- (void)excuteCmdToDeletePushMsg:(NSArray*)delIds completion:(JSONObjectBlock)completion
{
    if (![delIds count]) {
        completion = nil;
        return;
    }
    NSMutableDictionary* body = [NSMutableDictionary dictionary];
    [body setObject:[NSNumber numberWithInteger:0x4303] forKey:@"cmd"];
    [body setObject:delIds forKey:@"delId"];
    
    [self postRequestWithBodyDictionary:body completion:completion];
}



#pragma mark -5字段
//"cmd":0x5001,
//"dvcId":"qdq12",    //设备Id
//"contType":1,       //举报内容类型  1举报某个问题  2举报某个评论 3举报某个用户
//"contId":121231     //对应的Id
//"reason":1          //举报原因
//"reasonCont":"用户对举报原因的自己的描述"
- (void)reportPost:(NSInteger)postId
{
    [self reportSomething:1 objectId:postId reason:1 message:@"暂不支持填写该字段"];
}

- (void)reportAnswer:(NSInteger)ansId
{
    [self reportSomething:2 objectId:ansId reason:1 message:@"暂不支持填写该字段"];
}

- (void)reportItem:(NSInteger)objId type:(NSInteger)type completion:(JSONObjectBlock)block
{
    NSMutableDictionary* body = [NSMutableDictionary dictionary];
    [body setObject:[NSNumber numberWithInteger:0x5001] forKey:@"cmd"];
    [body setObject:@(type) forKey:@"contType"];
    [body setObject:@(objId) forKey:@"contId"];
    [body setObject:@(1) forKey:@"reason"];
    [body setObject:@"暂不支持填写该字段" forKey:@"reasonCont"];
    
    [self postRequestWithBodyDictionary:body completion:block];
}

- (void)reportSomething:(NSInteger)contType objectId:(NSInteger)contId reason:(NSInteger)reason message:(NSString*)message
{
    NSMutableDictionary* body = [NSMutableDictionary dictionary];
    [body setObject:[NSNumber numberWithInteger:0x5001] forKey:@"cmd"];
    [body setObject:@(contType) forKey:@"contType"];
    [body setObject:@(contId) forKey:@"contId"];
    [body setObject:@(reason) forKey:@"reason"];
    [body setObject:message forKey:@"reasonCont"];
    
    [self postRequestWithBodyDictionary:body completion:^(id json, JSONModelError *err) {
//        BackSourceInfo_5001* backSource = [[BackSourceInfo_5001 alloc] initWithDictionary:json error:nil];
//        DPTrace("举报结果如下：%zd - %@", backSource.statusCode, backSource.statusInfo);
    }];
}


#pragma mark -private methods
- (void)postRequestWithBody:(NSString*)bodyString completion:(JSONObjectBlock)completeBlock
{
    //make post, get requests
    [JSONHTTPClient setTimeoutInSeconds:15];
    [JSONHTTPClient postJSONFromURLWithString:BBServer_Cgi bodyString:bodyString completion:^(id json, JSONModelError *err) {
//        DPTrace("\nJSON：\n %@ \nError: \n %@",json,err);

        if (completeBlock) {
            completeBlock(json, err);
        }
    }];
}

- (void)postRequestWithBodyDictionary:(NSDictionary*)bodyDict completion:(JSONObjectBlock)completeBlock
{
    NSMutableDictionary* body = [NSMutableDictionary dictionaryWithDictionary:bodyDict];
    NSInteger cmd = [[bodyDict objectForKey:@"cmd"] integerValue];
    if (cmd != 0x1001 && cmd != 0x1004 && cmd != 0x3001 && cmd != 0x3002) {
        if ([[DPLbsServerEngine shareInstance] isEnabledAndAuthorize] == NO) {
            JSONModelError* error = [[JSONModelError alloc] initWithDomain:@"Local-Error" code:-1 userInfo:nil
                                     ];
            completeBlock(nil, error);
            DPTrace("请求本地拦截，%@命令需求用户允许地理位置权限",[NSString hexValue:[bodyDict objectForKey:@"cmd"]]);
            return;
        }
    }
    [body setObject:[SvUDIDTools UDID] forKey:@"dvcId"];
    [body setObject:[DPHttpService localVersion] forKey:@"appVersion"];
    
    NSString* jsonString = [body jsonStringWithPrettyPrint:NO];
    
    DPTrace("%@命令请求",[NSString hexValue:[bodyDict objectForKey:@"cmd"]]);
    DPTrace("\n请求body：\n%@\n",jsonString);
    
    [self postRequestWithBody:jsonString completion:completeBlock];
}

+ (NSString*)localVersion
{
    static NSString *localVersion = nil;
    if (![localVersion length]) {
        NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
        localVersion = [infoDictionary objectForKey:@"CFBundleShortVersionString"];
    }
    return [localVersion length]?localVersion:@"";
}
@end
