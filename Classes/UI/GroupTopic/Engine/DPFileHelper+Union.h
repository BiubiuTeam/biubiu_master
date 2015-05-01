//
//  DPFileHelper+Union.h
//  biubiu
//
//  Created by haowenliang on 15/3/27.
//  Copyright (c) 2015年 dpsoft. All rights reserved.
//

#import "DPFileHelper.h"

@interface DPFileHelper (Union)

+ (NSArray*)getCacheUnionPostList:(NSInteger)unionId;
+ (BOOL)cacheUnionPostList:(NSArray* )recentPosts toUnion:(NSInteger)unionId;
+ (void)deleteUnionPostCache:(NSInteger)unionId;

@end
