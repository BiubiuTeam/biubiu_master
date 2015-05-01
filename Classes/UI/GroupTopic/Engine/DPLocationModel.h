//
//  DPLocationModel.h
//  biubiu
//
//  Created by haowenliang on 15/4/1.
//  Copyright (c) 2015年 dpsoft. All rights reserved.
//

#import "JSONModel.h"

@interface DPLocationModel : JSONModel

@property (nonatomic, strong) NSNumber* statusCode;
@property (nonatomic, strong) NSString<Optional>* statusInfo;

@property (nonatomic, strong) NSString<Optional>* locationDes;

@end
