//
//  DPEmptyView.h
//  BiuBiu
//
//  Created by haowenliang on 15/1/26.
//  Copyright (c) 2015年 dpsoft. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, DPEmptyViewType) {
    DPEmptyViewType_DefaultError = 0, //默认错误提示
    DPEmptyViewType_LocationError = 1, //lbs 错误提示
    DPEmptyViewType_NetworkError = 2, //网络错误提示
    DPEmptyViewType_NearbyNone = 3, //附近界面无数据提示
    DPEmptyViewType_MessageNone = 4, //消息界面无数据提示
    DPEmptyViewType_PostNone = 5, //提问界面无数据提示
    DPEmptyViewType_ReplyNone = 6, //回答的界面无数据提示
    DPEmptyViewType_UnionPostNone = 7, //版块内部问题为空
    DPEmptyViewType_BiuHelper = 8, //biubiu助手
    
};

@interface DPEmptyView : UIView
@property (nonatomic, assign) DPEmptyViewType viewType;
@property (nonatomic, strong) NSString* emptyLogoName;
@property (nonatomic, strong) NSString* emptyInformation;
@end


@interface DPEmptyView (ViewType)

+ (DPEmptyView*)getEmptyViewWithFrame:(CGRect)frame viewType:(DPEmptyViewType)type;

@end