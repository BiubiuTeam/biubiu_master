//
//  DPCommentTextField.h
//  Longan
//
//  Created by haowenliang on 14-6-20.
//  Copyright (c) 2014年 dpsoft. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, CommentType) {
    CommentType_Default = 0,
    CommentType_Floor = 1, //回复楼层
};

@class DPCommentTextField;

@protocol DPCommentTextFieldProtocol <NSObject>

@optional
- (void)textFieldFrameChanged:(DPCommentTextField*)textField;
- (void)textFieldDidSendText:(DPCommentTextField*)textField inputText:(NSString*)text;

@end

@interface DPCommentTextField : UIView
@property (nonatomic) CommentType commentType;
@property (nonatomic) NSInteger floorNumber;
@property (nonatomic) CGFloat maxCommentTextFieldHeight;
@property (nonatomic) CGFloat maxTextFieldHeight;

@property (nonatomic, assign) id<DPCommentTextFieldProtocol> delegate;

- (void)resetPlaceHolder:(NSString*)normalHolder editingPlaceHolder:(NSString*)editHolder;

- (void)resignFirstResponderEx;
- (void)clearTextContent;

- (NSString*)replyContent;
@end
