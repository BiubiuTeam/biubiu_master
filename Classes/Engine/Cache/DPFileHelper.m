//
//  DPFileHelper.m
//  Longan
//
//  Created by haowenliang on 14-6-15.
//  Copyright (c) 2014年 dpsoft. All rights reserved.
//

#import "DPFileHelper.h"
#import "NSKeyedUnarchiverAdditions.h"

@implementation DPFileHelper

+ (NSString*)biuBiuListFilePath
{
    NSString *path = [NSString stringWithFormat:@"%@/contents", [DPFileHelper docDir]];
    DPTrace("\nCacheFilePath: %@\n",path);
    return path;
}

+ (void)deleteBiuBiuCacheFile:(NSString*)name
{
    NSString* filePath = [self biuBiuListFilePath];
    NSString* fileName = [NSString stringWithFormat:@"%@/%@",filePath,name];
    [DPFileHelper removePath:fileName];
}

+ (BOOL)saveCacheMsgList:(NSArray*)msgArray toFile:(NSString*)name
{
    if (![msgArray count]) {
        return NO;
    }
    NSString* filePath = [self biuBiuListFilePath];
    [self createPath:filePath];
    NSString* fileName = [NSString stringWithFormat:@"%@/%@",filePath,name];
    return [NSKeyedArchiver archiveRootObject:msgArray toFile:fileName];
}

+ (NSArray*)getCacheMsgList:(NSString*)name
{
    NSString* fileName = [NSString stringWithFormat:@"%@/%@",[self biuBiuListFilePath],name];
    NSArray* list = nil;
    @try {
        list = [NSKeyedUnarchiver unarchiveObjectWithFileNoException:fileName];
    }
    @catch (NSException *exception) {}
    @finally {}
    
    return list;
}

#pragma mark -回复列表数据
+ (NSString*)fileNameOfQuestAns:(NSInteger)questionId
{
    return [NSString stringWithFormat:@"AnswerListOfQuestion_%zd",questionId];
}

+ (BOOL)cacheAnswerList:(NSArray*)ansList questionId:(NSInteger)questionId
{
    return [self saveCacheMsgList:ansList toFile:[self fileNameOfQuestAns:questionId]];
}

+ (NSArray*)getCacheAnswerListOfQuestionId:(NSInteger)questionId
{
    return [self getCacheMsgList:[self fileNameOfQuestAns:questionId]];
}

+ (void)deleteQuestionAnswerList:(NSInteger)questionId
{
    [self deleteBiuBiuCacheFile:[self fileNameOfQuestAns:questionId]];
}

#pragma mark -账户数据

+ (id)cacheAccountInfo
{
    NSString* fileName = [NSString stringWithFormat:@"%@/UserAccountInfo",[self biuBiuListFilePath]];
    @try {
        return [NSKeyedUnarchiver unarchiveObjectWithFileNoException:fileName];
    }
    @catch (NSException *exception) {}
    @finally {}
    return nil;
}

+ (BOOL)saveCacheAccountInfo:(id)accountInfo
{
    NSString* filePath = [self biuBiuListFilePath];
    [self createPath:filePath];
    NSString* fileName = [NSString stringWithFormat:@"%@/UserAccountInfo",filePath];
    return [NSKeyedArchiver archiveRootObject:accountInfo toFile:fileName];
}

#pragma mark -问题Pool文件
+ (NSArray*)getCacheQuestionPoolList
{
    return [self getCacheMsgList:@"QuestionPool"];
}

+ (BOOL)cacheQuestionPool:(NSArray*)pool
{
    return [self saveCacheMsgList:pool toFile:@"QuestionPool"];
}

#pragma mark -附近的列表
+ (NSArray*)getCacheNearbyList
{
    return [self getCacheMsgList:@"NearbyList"];
}

+ (BOOL)cacheNearbyList:(NSArray* )recentPosts
{
    return [self saveCacheMsgList:recentPosts toFile:@"NearbyList"];
}

+ (void)deleteNearbyList
{
    return [self deleteBiuBiuCacheFile:@"NearbyList"];
}

#pragma mark -我的提问
+ (NSArray* )getCacheMyPostList
{
    return [self getCacheMsgList:@"UserRecentPosts"];
}

+ (BOOL)cacheUserPostList:(NSArray* )recentPosts
{
    return [self saveCacheMsgList:recentPosts toFile:@"UserRecentPosts"];
}

+ (void)deleteUserPostList
{
    return [self deleteBiuBiuCacheFile:@"UserRecentPosts"];
}

#pragma mark -我回答的
+ (NSArray* )getCacheFollowList
{
    return [self getCacheMsgList:@"UserFollowPosts"];
}

+ (BOOL)saveCacheUserFollowPosts:(NSArray* )followList
{
    return [self saveCacheMsgList:followList toFile:@"UserFollowPosts"];
}

+ (void)deleteUserFollowList
{
    return [self deleteBiuBiuCacheFile:@"UserFollowPosts"];
}

#pragma mark -消息列表
+ (NSArray*)getCacheUnreadMessageList
{
    return [self getCacheMsgList:@"UnreadMessageList"];
}

+ (BOOL)saveCacheUnreadMessageList:(NSArray* )unreadList
{
    return [self saveCacheMsgList:unreadList toFile:@"UnreadMessageList"];
}

+ (void)deleteUnreadMessageList
{
    return [self deleteBiuBiuCacheFile:@"UnreadMessageList"];
}

#pragma mark -tag list
+ (NSDictionary *)tagOfUnreadList
{
    NSString* fileName = [NSString stringWithFormat:@"%@/tagsOfUnreadList",[self biuBiuListFilePath]];
    NSDictionary* dict = nil;
    @try {
        dict = [NSKeyedUnarchiver unarchiveObjectWithFileNoException:fileName];
    }
    @catch (NSException *exception) {}
    @finally {}
    
    return dict;
}

+ (BOOL)saveTagOfUnreadList:(NSDictionary *)tagDict
{
    if (tagDict == nil) {
        return NO;
    }
    NSString* filePath = [self biuBiuListFilePath];
    [self createPath:filePath];
    NSString* fileName = [NSString stringWithFormat:@"%@/tagsOfUnreadList",[self biuBiuListFilePath]];
    return [NSKeyedArchiver archiveRootObject:tagDict toFile:fileName];
}

#pragma mark -base functions
+ (NSString*)docDir
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    return [paths objectAtIndex:0];
}

+ (NSString *)tmpDir
{
    return NSTemporaryDirectory();
}

+ (BOOL)writeArrayInDocumentDir:(NSArray*)array toFile:(NSString*)filename
{
    if (array == nil) {
        return NO;
    }
    NSString *docDir = [DPFileHelper docDir];
    if (!docDir) {
        DPTrace("Documents 目录未找到");
        return NO;
    }
    NSString *filePath = [docDir stringByAppendingPathComponent:filename];
    return [array writeToFile:filePath atomically:YES];
}

+ (BOOL)isFileExist:(NSString *)path
{
    if (path.length > 0) {
        NSFileManager* fm = [NSFileManager defaultManager];
        return [fm fileExistsAtPath:path];
    }
    return NO;
}

+ (void)createPath:(NSString *)path
{
    if (![self isFileExist:path]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
    }
}

+ (void)removePath:(NSString*)path
{
    if ([self isFileExist:path]) {
        [[NSFileManager defaultManager] removeItemAtPath:path error:nil];
    }
}

+ (UIImage *) GetImageFromRender: (CGContextRef) context
{
    CGImageRef imageRef = CGBitmapContextCreateImage(context);
    UIImage * resultImage = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
    
    return resultImage;
}

@end
