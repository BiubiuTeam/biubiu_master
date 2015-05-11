//
//  DPLocalDataManager.h
//  biubiu
//
//  Created by haowenliang on 15/2/3.
//  Copyright (c) 2015年 dpsoft. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BackSourceInfo_1004.h"
#import "BackSourceInfo_4301.h"
#import "BackSourceInfo_4302.h"
#import "BackSourceInfo_4303.h"

typedef void (^DPArrayCallbackBlock)(NSError* error, NSArray* result);

typedef void (^DPPlatformInfoBlock)(BOOL succeed, BackendReturnData_1004* result);

@class BackendReturnData_1004; //用户数据


@interface DPLocalDataManager : NSObject

@property (nonatomic, copy) DPArrayCallbackBlock msgListCallback;

@property (nonatomic, strong) NSMutableArray* messageList;//新消息列表

@property (nonatomic, assign) BOOL hasUnreadMessage;

+ (DPLocalDataManager*)shareInstance;

@property (nonatomic, strong) BackendReturnData_1004* platformAccInfo;

- (void)loadPlatformAccountInfoCompletion:(DPPlatformInfoBlock)callback;

- (void)getPostReplyList:(NSInteger)questId completion:(DPArrayCallbackBlock)callback;

- (void)loadPushMessageList:(NSInteger)type lastId:(NSInteger)lastId;

- (BOOL)messageReadTag:(NSInteger)messageId;
- (void)setMessageReadTag:(NSInteger)messageId readTag:(BOOL)read;
- (void)deleteUnreadMessageAtIndex:(NSInteger)index;

@end
