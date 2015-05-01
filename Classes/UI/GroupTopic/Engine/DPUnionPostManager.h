//
//  DPUnionPostManager.h
//  biubiu
//
//  Created by haowenliang on 15/3/27.
//  Copyright (c) 2015年 dpsoft. All rights reserved.
//

#import <Foundation/Foundation.h>


typedef void (^DPUnionPostCallbackBlock)(NSInteger pullOrLoad, BOOL Succeed);

@interface DPUnionPostManager : NSObject

@property (nonatomic, assign, readonly) NSInteger currentUnionId;

@property (nonatomic, strong, readonly) NSMutableArray* unionPostList;

@property (nonatomic, copy) DPUnionPostCallbackBlock completion;

+ (instancetype)shareInstance;

- (void)resetRegistedUnion:(NSInteger)unionId completion:(DPUnionPostCallbackBlock)completion;
- (void)clearRegistedUnionInfo;


- (void)updateUnionPostList;
- (void)loadMoreUnionPostList;

@end
