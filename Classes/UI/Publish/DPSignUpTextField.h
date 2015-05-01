//
//  DPSignUpTextField.h
//  BiuBiu
//
//  Created by haowenliang on 14/12/9.
//  Copyright (c) 2014年 dpsoft. All rights reserved.
//
//  署名区域UI
#import <UIKit/UIKit.h>

@class SignTextField;
@class DPSignUpTextField;
@protocol DPSignUpTextFieldProtocol <NSObject>

@optional
- (void)resignAllResponder:(DPSignUpTextField*)field;

- (void)textDidChanged:(DPSignUpTextField*)field text:(NSString*)string;
@end

@interface DPSignUpTextField : UIView
@property (nonatomic, assign) id<DPSignUpTextFieldProtocol> delegate;
@property (nonatomic, strong) SignTextField* textField;
@property (nonatomic, copy) UIColor* superBgColor;

- (void)setTextFieldInputAccessoryView:(UIView*)accessoryView;

- (NSString*)currentWrittenName;
- (void)rememberUserInput;

@end
