//
//  DPFileHelper+Union.m
//  biubiu
//
//  Created by haowenliang on 15/3/27.
//  Copyright (c) 2015年 dpsoft. All rights reserved.
//

#import "DPFileHelper+Union.h"

@implementation DPFileHelper (Union)

#pragma mark -工会的问题列表
+ (NSArray*)getCacheUnionPostList:(NSInteger)unionId
{
    return [self getCacheMsgList:[NSString stringWithFormat:@"union_post_%zd",unionId]];
}

+ (BOOL)cacheUnionPostList:(NSArray* )recentPosts toUnion:(NSInteger)unionId
{
    return [self saveCacheMsgList:recentPosts toFile:[NSString stringWithFormat:@"union_post_%zd",unionId]];
}

+ (void)deleteUnionPostCache:(NSInteger)unionId
{
    return [self deleteBiuBiuCacheFile:[NSString stringWithFormat:@"union_post_%zd",unionId]];
}


@end
