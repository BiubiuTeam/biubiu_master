//
//  BackSourceInfo.h
//  BiuBiu
//
//  Created by haowenliang on 15/1/19.
//  Copyright (c) 2015年 dpsoft. All rights reserved.
//

//base response informations
#import "JSONModel.h"
#import "JSONModel+Encoder.h"

@interface BackSourceInfo : JSONModel

@property (assign, nonatomic) int statusCode;
@property (strong, nonatomic) NSString* statusInfo;

@end
