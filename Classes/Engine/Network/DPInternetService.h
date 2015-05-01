//
//  DPInternetService.h
//  BiuBiu
//
//  Created by haowenliang on 15/1/5.
//  Copyright (c) 2015年 dpsoft. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DPInternetService : NSObject

@property (nonatomic, readonly) BOOL hostReachable;
@property (nonatomic, readonly) BOOL internetReachable;
@property (nonatomic, readonly) BOOL wifiReachable;

+ (instancetype)shareInstance;
- (BOOL)networkEnable;

@end
