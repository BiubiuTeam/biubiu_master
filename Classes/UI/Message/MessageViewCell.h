//
//  MessageViewCell.h
//  biubiu
//
//  Created by haowenliang on 15/2/13.
//  Copyright (c) 2015年 dpsoft. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, UNREAD_MESSAGETYPE) {
    UNREAD_MESSAGETYPE_ANSWER = 1,
    UNREAD_MESSAGETYPE_VOTE = 2,
    UNREAD_MESSAGETYPE_QUESTION = 3,
    UNREAD_MESSAGETYPE_NOTIFICATION = 4,//通知类型
};

@interface MessageViewCell : UITableViewCell

- (void)setMaskOnView:(BOOL)withMask;
- (void)setMessageType:(UNREAD_MESSAGETYPE)type;

- (void)setContentText:(NSString*)content info:(NSString*)info date:(NSDate*)date;

+ (CGFloat)changableHeight:(NSString*)content;
+ (CGFloat)limitedHeight;
@end
