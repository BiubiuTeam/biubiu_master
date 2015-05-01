//
//  BackSourceInfo_4301.h
//  biubiu
//
//  Created by haowenliang on 15/2/12.
//  Copyright (c) 2015年 dpsoft. All rights reserved.
//

#import "BackSourceInfo.h"


@interface DPPushModel : JSONModel

@property (nonatomic, strong) NSNumber<Optional>* unreadNum;//总的新消息数
@property (nonatomic, strong) NSNumber<Optional>* unreadLikeNum;//新点赞数
@property (nonatomic, strong) NSNumber<Optional>* unreadAnsNum;//新回答数
@property (nonatomic, strong) NSNumber<Optional>* unreadQuestNum;//新问题数

@end

@interface BackSourceInfo_4301 : BackSourceInfo
@property (nonatomic, strong) DPPushModel<Optional, ConvertOnDemand>* returnData;
@end
