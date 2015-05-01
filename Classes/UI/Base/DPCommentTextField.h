//
//  DPCommentTextField.h
//  Longan
//
//  Created by haowenliang on 14-6-20.
//  Copyright (c) 2014年 dpsoft. All rights reserved.
//

#import <UIKit/UIKit.h>
@class DPCommentTextField;

@protocol DPCommentTextFieldProtocol <NSObject>

@optional
- (void)textFieldFrameChanged:(DPCommentTextField*)textField;
- (void)textFieldDidSendText:(DPCommentTextField*)textField inputText:(NSString*)text;

@end

@interface DPCommentTextField : UIView

@property (nonatomic) CGFloat maxCommentTextFieldHeight;
@property (nonatomic) CGFloat maxTextFieldHeight;

@property (nonatomic, assign) id<DPCommentTextFieldProtocol> delegate;

- (void)resetPlaceHolder:(NSString*)normalHolder editingPlaceHolder:(NSString*)editHolder;

- (void)resignFirstResponderEx;
- (void)clearTextContent;

- (NSString*)replyContent;
@end
