//
//  DPSociatyModel.h
//  biubiu
//
//  Created by haowenliang on 15/3/24.
//  Copyright (c) 2015年 dpsoft. All rights reserved.
//

#import "JSONModel.h"
#import "JSONModel+Encoder.h"

typedef NS_ENUM(NSUInteger, SociatyType) {
    SociatyType_School,
    SociatyType_Public,
};

/*
\"sortId\":123,       //排序Id
\"unionId\":1231231,       //公会Id
\"unionName\":\"公会名称\",
\"picPath\":\"公会图标路径\",
\"questionNum\": 25,     //提出的问题数
\"creTime\":1231231231,        //创建时间
\"latitude\":32, //经度
\"longitude\":12,    //纬度
\"selfLocDesc\":\"用户自定义的地方\",
\"ownerNick\":\"创建人代号\"
 */
@protocol DPSociatyModel
@end

@interface DPSociatyModel : JSONModel

@property (nonatomic, strong) NSNumber* sortId;
@property (nonatomic, strong) NSNumber* unionId;
@property (nonatomic, strong) NSString* unionName;
@property (nonatomic, strong) NSString* picPath;
@property (nonatomic, strong) NSNumber<Optional>* questionNum;
@property (nonatomic, strong) NSNumber* creTime;
@property (nonatomic, strong) NSNumber* latitude;
@property (nonatomic, strong) NSNumber* longitude;
@property (nonatomic, strong) NSString* selfLocDesc;
@property (nonatomic, strong) NSString<Optional>* ownerNick;

@property (nonatomic, strong) NSString<Optional>* locDesc;//这里注意，如果为空""说明不在学校范围，此时客户端用distance字段显示距离
@property (nonatomic, strong) NSNumber<Optional>* distance;//与版块创建地相距的公里数

//下面数据仅对测试审核后台可见
@property (nonatomic, strong) NSString<Optional>* ownerDvcId;
@property (nonatomic, strong) NSNumber<Optional>* ownerId;

@end


@interface DPSociatyServerModel : JSONModel

@property (nonatomic, strong) NSNumber* statusCode;
@property (nonatomic, strong) NSString<Optional>* statusInfo;

@property (nonatomic, strong) NSArray<Optional,DPSociatyModel,ConvertOnDemand>* unionList;

@end

