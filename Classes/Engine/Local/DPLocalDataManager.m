//
//  DPLocalDataManager.m
//  biubiu
//
//  Created by haowenliang on 15/2/3.
//  Copyright (c) 2015年 dpsoft. All rights reserved.
//

#import "DPLocalDataManager.h"
#import "SvUDIDTools.h"
#import "DPHttpService.h"
#import "DPFileHelper.h"
#import "AppDelegate.h"

#import "DPLbsServerEngine.h"

#import "BackSourceInfo_1001.h"
#import "BackSourceInfo_1004.h"
#import "BackSourceInfo_5001.h"
#import "BackSourceInfo_2005.h"
#import "BackSourceInfo_4301.h"

#import "DPAnswerUpdateService.h"
#define PLATFORM_CACHE_TIME (30)

#define UNREAD_REQ_CACHE_TIME (60)

#define FAIL_MAX_COUNT (5)

@interface DPLocalDataManager ()
{
    NSDate* _platformReqDate;
    BOOL _reqUnreadMessage;
    NSInteger _lastUnReadCount;
    
    NSUInteger _failedUnReadReqCount;
}
@property (nonatomic, strong) DPPushModel* pushMsgModel; //推送消息

@property (nonatomic, copy) DPPlatformInfoBlock platformCallback;

@property (nonatomic, strong) NSMutableDictionary* unReadDictionary;//未读消息
@end

@implementation DPLocalDataManager

+ (DPLocalDataManager*)shareInstance
{
    static DPLocalDataManager* _sDataMgr = nil;
    static dispatch_once_t onceTokenMgr;
    dispatch_once(&onceTokenMgr, ^{
        _sDataMgr = [[DPLocalDataManager alloc] init];
    });
    return _sDataMgr;
}

/**  *得到本机现在用的语言  * en:英文  zh-Hans:简体中文   zh-Hant:繁体中文    ja:日本  ......  */
+ (NSString*)getPreferredLanguage
{
    NSUserDefaults* defs = [NSUserDefaults standardUserDefaults];
    NSArray* languages = [defs objectForKey:@"AppleLanguages"];
    NSString* preferredLang = [languages objectAtIndex:0];
    NSLog(@"Preferred Language:%@", preferredLang);
    return preferredLang;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    self.msgListCallback = nil;
    self.platformCallback = nil;
    self.platformAccInfo = nil;
    self.messageList = nil;
    self.pushMsgModel = nil;
}

- (instancetype)init
{
    if (self = [super init]) {
        self.msgListCallback = nil;
        self.platformAccInfo = nil;
        self.platformCallback = nil;
        self.pushMsgModel = nil;
        
        _failedUnReadReqCount = 0;
        _reqUnreadMessage = NO;
        _lastUnReadCount = 0;
        
        self.messageList = [NSMutableArray arrayWithArray:[DPFileHelper getCacheUnreadMessageList]];

        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onPlatformAccountInfoUpdate:) name:kNotification_UpdateAccountInfo object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onMessageListHandler:) name:kNotification_PushMsgListCallBack object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onPlatformRegistCallback:) name:kNotification_RegistCallBack object:nil];
        
        self.platformAccInfo = [DPFileHelper cacheAccountInfo];
        
        NSDictionary* dict = [DPFileHelper tagOfUnreadList];
        if ([dict count]) {
            self.unReadDictionary = [NSMutableDictionary dictionaryWithDictionary:dict];
        }else{
            self.unReadDictionary = [NSMutableDictionary dictionary];
        }
    }
    return self;
}

#pragma mark -回复数据列表
- (void)getPostReplyList:(NSInteger)questId completion:(DPArrayCallbackBlock)callback
{
    NSArray* listObj = [[DPAnswerUpdateService shareInstance] getQuestionAnswerList:questId];
    if ([listObj count]) {
        if (callback) {
            callback(nil, listObj);
        }
    }else{
        __block DPArrayCallbackBlock completion = callback;
        [[DPAnswerUpdateService shareInstance] updateQuestionAnswerList:questId completion:^(NSArray *qanswerList, DPResponseType type) {
            if (completion) {
                completion(nil, listObj);
            }
            completion = nil;
        }];
    }
}

#pragma mark -轮询操作
- (void)runroopToCheckNewMessage
{
    if(_pushMsgModel == nil || [_pushMsgModel.unreadNum integerValue] < 1){
        if (_reqUnreadMessage == NO) {
            [self checkNewMessageUpdate];
        }
    }else{
        DPTrace("未读消息轮询，已有未读标记");
    }
    [NSTimer scheduledTimerWithTimeInterval:UNREAD_REQ_CACHE_TIME target:self selector:@selector(runroopToCheckNewMessage) userInfo:nil repeats:NO];
}

- (void)onPlatformRegistCallback:(NSNotification*)notification
{
    NSDictionary* userInfo = notification.userInfo;
    NSInteger retCode = [[userInfo objectForKey:kNotification_StatusCode] integerValue];
    if (retCode == 0 || retCode == 1) {
        [[DPHttpService shareInstance] updatePlatformInfo];
        
        [self runroopToCheckNewMessage];
    }else{
        DPTrace("需要提示用户，账户注册失败否？");
    }
}

#pragma mark - 对外接口

- (NSInteger)numberOfUnreadMessage
{
    if (_pushMsgModel == nil) {
        return 0;
    }
    return [_pushMsgModel.unreadNum integerValue];
}

- (BOOL)messageReadTag:(NSInteger)messageId
{
    NSString* key = [NSString stringWithFormat:@"UNREAD_%zd",messageId];
    NSString* value = [_unReadDictionary objectForKey:key];
    if (value == nil) {
        return NO;
    }
    return [value boolValue];
}

- (void)setMessageReadTag:(NSInteger)messageId readTag:(BOOL)read
{
    if ([self messageReadTag:messageId] == read) {
        return;
    }
    
    NSString* key = [NSString stringWithFormat:@"UNREAD_%zd",messageId];
    NSString* value = [NSString stringWithFormat:@"%zd",read];
    [_unReadDictionary setObject:value forKey:key];
    
    [DPFileHelper saveTagOfUnreadList:_unReadDictionary];
}

//加载设备数据
- (void)loadPlatformAccountInfoCompletion:(DPPlatformInfoBlock)callback
{
    self.platformCallback = callback;
    if (_platformCallback == nil) {
        return;
    }
    if (_platformAccInfo) {
        _platformCallback(YES,_platformAccInfo);
        if (_platformReqDate && abs([_platformReqDate timeIntervalSinceNow]) > PLATFORM_CACHE_TIME) {
            //超过缓存时间，更新数据
            [[DPHttpService shareInstance] updatePlatformInfo];
        }
    }else{
        [[DPHttpService shareInstance] updatePlatformInfo];
    }
}

- (void)setMsgListCallback:(DPArrayCallbackBlock)msgListCallback
{
    _msgListCallback = [msgListCallback copy];
    if (_msgListCallback) {
        _msgListCallback(nil, _messageList);
    }
}

//请求新数据
- (BOOL)hasNewMessageUnRead
{
    if (_pushMsgModel /*&& [_pushMsgModel.unreadNum integerValue] > _lastUnReadCount*/) {
        return YES;
    }
    //如果连续请求失败10次，则认为后台挂掉了
    if (_failedUnReadReqCount > FAIL_MAX_COUNT) {
        return YES;
    }
    return NO;
}

- (void)removeNewMessageModel
{
    _lastUnReadCount = [_pushMsgModel.unreadNum integerValue];
    self.pushMsgModel = nil;
    _failedUnReadReqCount = 0;
    AppDelegate* delegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    [delegate updateTabCounter];
}

- (void)deleteUnreadMessageAtIndex:(NSInteger)index
{
    if (index < [_messageList count]) {
        DPPushItemModel* model = _messageList[index];
        [self clearUnReadMessageList:@[model.ullId]];
        [_messageList removeObjectAtIndex:index];
        
        [DPFileHelper saveCacheUnreadMessageList:_messageList];
    }
}

- (void)clearUnReadMessageList:(NSArray*)list
{
    if (![list count]) {
        return;
    }
    [[DPHttpService shareInstance] excuteCmdToDeletePushMsg:list completion:^(id json, JSONModelError *err) {
        if (err == nil) {
            BackSourceInfo* retInfo = [[BackSourceInfo alloc] initWithDictionary:json error:&err];
            if (err == nil && retInfo.statusCode == 0) {
                DPTrace("标志已读操作成功");
                _lastUnReadCount -= [list count];
            }else{
                DPTrace("标志已读操作失败，Status Code : %zd, Status Info : %@", retInfo.statusCode, retInfo.statusInfo);
            }
        }else{
            DPTrace("标志已读操作失败，Error : %@", err);
        }
    }];
}

- (void)checkNewMessageUpdate
{
    float lat = [[DPLbsServerEngine shareInstance] latitude];
    float lon = [[DPLbsServerEngine shareInstance] longitude];
    
    [[DPHttpService shareInstance] excuteCmdToPullPushInfo:^(id json, JSONModelError *err) {
        if (json) {
            BackSourceInfo_4301* model = [[BackSourceInfo_4301 alloc] initWithDictionary:json error:&err];
            if (model.statusCode == 0) {
                self.pushMsgModel = model.returnData;
                DPTrace("更新推送消息成功，当前新消息状况如下：%@",_pushMsgModel);
            }else{
                self.pushMsgModel = nil;
                DPTrace("更新推送消息失败1");
            }
        }else{
            self.pushMsgModel = nil;
            DPTrace("更新推送消息失败2");
            DPTrace("%@",err);
            if (err) {
                _failedUnReadReqCount++;
            }
        }
        AppDelegate* delegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
        [delegate updateTabCounter];
    } latitude:lat logitude:lon];
}

//加载当前新消息列表
- (void)loadPushMessageList:(NSInteger)type lastId:(NSInteger)lastId
{
    if (type == 2) {
        [self removeNewMessageModel];
    }
    
    float lat = [[DPLbsServerEngine shareInstance] latitude];
    float lon = [[DPLbsServerEngine shareInstance] longitude];
    _reqUnreadMessage = YES;
    [[DPHttpService shareInstance] excuteCmdToPullNewMessage:type lastId:lastId latitude:lat logitude:lon];
}

#pragma mark -通知处理
- (void)onPlatformAccountInfoUpdate:(NSNotification*)notification
{
    NSDictionary* userInfo = [notification userInfo];
    if (userInfo && [userInfo count]) {
        _platformReqDate = [NSDate date];
        
        NSInteger retCode = [[userInfo objectForKey:kNotification_StatusCode] integerValue];
        if (retCode == 0) {
            BackSourceInfo_1004* rspObject = [userInfo objectForKey:kNotification_ReturnObject];
            
            self.platformAccInfo = rspObject.returnData;
            if(_platformAccInfo){
                [DPFileHelper saveCacheAccountInfo:_platformAccInfo];
            }
            if (_platformCallback) {
                _platformCallback(YES, _platformAccInfo);
            }
        }else{
            if (_platformCallback) {
                _platformCallback(NO, _platformAccInfo);
            }
        }
    }
}

- (void)onMessageListHandler:(NSNotification*)notification
{
    NSDictionary* userInfo = [notification userInfo];
    if (userInfo && [userInfo count]) {
        id json = [userInfo objectForKey:kNotification_ReturnObject];
        if (json) {
            NSError* localErr = nil;
            BackSourceInfo_4302* rspObject = [[BackSourceInfo_4302 alloc] initWithDictionary:json error:&localErr];
            if (localErr == nil) {
                if( rspObject.statusCode == 0){
                    @synchronized(_messageList){
                        BackendReturnData_4302* retData = [rspObject returnData];
                        if (retData && [retData.contData count]) {
                            
                            NSArray* newList = retData.contData;
                            if ([newList count] < _lastUnReadCount) {
                                //还有数据未拉取完
                                DPPushItemModel* nextPoint = [newList lastObject];
                                _lastUnReadCount = _lastUnReadCount - [newList count];
                                [self loadPushMessageList:1 lastId:[[nextPoint ullId] integerValue]];
                            }
                            
                            NSMutableArray* tmpArray = [_messageList mutableCopy];
                            [tmpArray addObjectsFromArray:newList];
                            NSArray* sortedArray = [tmpArray sortedArrayUsingSelector:@selector(sortInDescending:)];
                            //去重
                            [_messageList removeAllObjects];
                            for (NSInteger p1 = 0 ; p1 < [sortedArray count]; p1++) {
                                DPPushItemModel* curModel = [sortedArray objectAtIndex:p1];
                                BOOL contains = NO;
                                for (NSInteger p2 = 0; p2 < [_messageList count]; p2++) {
                                    DPPushItemModel* tmpModel = [sortedArray objectAtIndex:p2];
                                    if ([curModel.ullId integerValue] == [tmpModel.ullId integerValue]) {
                                        contains = YES;
                                        break;
                                    }
                                }
                                if (contains == NO) {
                                    [_messageList addObject:curModel];
                                }
                            }
                            if (_msgListCallback) {
                                _msgListCallback(nil, _messageList);
                            }
                            [DPFileHelper saveCacheUnreadMessageList:_messageList];
                        }else{
                            //数据为空
//                            DPTrace("新消息列表请求数据为空： %@",cmdObj);
                            if (_msgListCallback) {
                                _msgListCallback(nil, _messageList);
                            }
                        }
                    }
                }else{
                    //数据请求失败
                    DPTrace("新消息列表请求失败： %@",rspObject);
                    if (_msgListCallback) {
                        if ([rspObject.statusInfo length]) {
                            NSError* err = [[NSError alloc] initWithDomain:rspObject.statusInfo code:-1 userInfo:nil];
                            _msgListCallback(err, _messageList);
                        }else{
                            _msgListCallback(nil, _messageList);
                        }
                    }
                }
            }else{
                //数据转换失败
                DPTrace("新消息列表数据转换失败： %@",localErr);
                if (_msgListCallback) {
                    _msgListCallback(localErr, _messageList);
                }
            }
        }else{
            JSONModelError* err = [userInfo objectForKey:kNotification_StatusInfo];
            DPTrace("新消息列表请求发送失败： %@",err);
            if (_msgListCallback) {
                _msgListCallback(err, _messageList);
            }
        }
    }
    _reqUnreadMessage = NO;
}

@end
