//
//  DPFileHelper.h
//  Longan
//
//  Created by haowenliang on 14-6-15.
//  Copyright (c) 2014年 dpsoft. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DPFileHelper : NSObject

//消息列表已读标记
+ (NSDictionary*)tagOfUnreadList;
+ (BOOL)saveTagOfUnreadList:(NSDictionary*)tagDict;

/**
 *  回复列表缓存
 *
 */
+ (BOOL)cacheAnswerList:(NSArray*)ansList questionId:(NSInteger)questionId;
+ (NSArray*)getCacheAnswerListOfQuestionId:(NSInteger)questionId;
+ (void)deleteQuestionAnswerList:(NSInteger)questionId;

//未读消息列表
+ (BOOL)saveCacheUnreadMessageList:(NSArray* )unreadList;
+ (NSArray*)getCacheUnreadMessageList;
+ (void)deleteUnreadMessageList;

/**
 *  用户信息
 */
+ (id)cacheAccountInfo;
+ (BOOL)saveCacheAccountInfo:(id)accountInfo;
/**
 *  问题池子
 */
+ (NSArray*)getCacheQuestionPoolList;
+ (BOOL)cacheQuestionPool:(NSArray*)pool;

/**
 *   附近的列表
 */
+ (NSArray*)getCacheNearbyList;

+ (BOOL)cacheNearbyList:(NSArray* )recentPosts;
+ (void)deleteNearbyList;

/**
 *  我的提问
 */
+ (NSArray* )getCacheMyPostList;
+ (BOOL)cacheUserPostList:(NSArray* )recentPosts;

+ (void)deleteUserPostList;

/**
 *  我回答的
 */
+ (NSArray* )getCacheFollowList;
+ (BOOL)saveCacheUserFollowPosts:(NSArray* )followList;
+ (void)deleteUserFollowList;

/*  消息流
 *
 */
+ (NSString*)biuBiuListFilePath;

/*  缓存列表
 *
 */
+ (BOOL)saveCacheMsgList:(NSArray*)msgArray toFile:(NSString*)name;

/*  删除缓存文件
 *
 */
+ (void)deleteBiuBiuCacheFile:(NSString*)name;

/*  从文件获取缓存消息列表
 *
 */
+ (NSArray*)getCacheMsgList:(NSString*)name;

/* 一些基本的操作方法
 *
 */
+ (NSString*)docDir;
+ (NSString*)tmpDir;
+ (void)createPath:(NSString *)path;
+ (void)removePath:(NSString*)path;
+ (BOOL)isFileExist:(NSString *)path;

/*  将array写入doc沙盒里的filename文件
 *
 */
+ (BOOL)writeArrayInDocumentDir:(NSArray*)array toFile:(NSString*)filename;


/*
 *
 */
+ (UIImage *) GetImageFromRender: (CGContextRef) context;
@end
