//
//  DPSetEventHandler.h
//  BiuBiu
//
//  Created by haowenliang on 14/12/21.
//  Copyright (c) 2014年 dpsoft. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SettingCellModel.h"

@class DPSetEventHandler;
@protocol DPSetEventHandlerProtocol <NSObject>

@optional
/**版本号更新通知*/
- (void)versionUpdateOpt:(DPSetEventHandler*)handler;

/**用户反馈回复通知*/
- (void)feedBackReplyOpt:(DPSetEventHandler*)handler;


@end

@interface DPSetEventHandler : NSObject

@property (nonatomic, weak) id<DPSetEventHandlerProtocol> delegate;
@property (nonatomic, weak) UIViewController* eventCtr;

/**
 *  设置界面点击事件处理
 */
- (void)operationForActionValue:(SettingCellModel*)cellModel;

/**
 *  设置界面开关
 */
- (void)newReplyNotifySwitchState:(BOOL)isOn;

@end
