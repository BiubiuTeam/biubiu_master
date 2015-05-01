//
//  DPCommentTextField.m
//  Longan
//
//  Created by haowenliang on 14-6-20.
//  Copyright (c) 2014年 dpsoft. All rights reserved.
//

#import "DPCommentTextField.h"
#import "DPTextView.h"

#define SEND_BTN_HEIGHT _size_S(34)
#define SEND_BTN_WIDTH _size_S(61)

#define MAX_TEXTFIELD_HEIGHT _size_S(54.f)

#define CONTENT_INSET _size_S(9.f)

#define CONTENT_MAGRIN _size_S(13.f)
#define CONTENT_MAGRIN_TOP _size_S(11.f)
#define CONTENT_MAGRIN_BOTTOM _size_S(9.f)

@interface DPCommentTextField()<UITextViewDelegate>
{
    CGFloat _minHeight;
}
@property (nonatomic, retain) DPTextView* textField;
@property (nonatomic, retain) UIButton* sendBtn;

@end

@implementation DPCommentTextField
@synthesize textField = _textField, sendBtn = _sendBtn;
@synthesize delegate = _delegate;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _minHeight = SEND_BTN_HEIGHT;
        // Initialization code
        self.backgroundColor = RGBACOLOR(0xda, 0xda, 0xdc, 1);

        _textField = [[DPTextView alloc] initWithFrame:CGRectMake(CONTENT_MAGRIN, CONTENT_MAGRIN_TOP, SCREEN_WIDTH - CONTENT_MAGRIN*2, SEND_BTN_HEIGHT)];
        _textField.backgroundColor = RGBACOLOR(0xf8, 0xf9, 0xfc, 1);
        _textField.textColor = RGBACOLOR(0x33, 0x33, 0x33, 1);
        _textField.defaultPlaceholder = NSLocalizedString(@"BB_TXTID_说些什么吧...", @"");
        _textField.editingPlaceholder = NSLocalizedString(@"BB_TXTID_说些什么吧...", @"");
        
        _textField.returnKeyType = UIReturnKeyDefault;
        _textField.textAlignment = NSTextAlignmentLeft;
        _textField.font = [DPFont systemFontOfSize:FONT_SIZE_MIDDLE];
        
        _textField.layer.cornerRadius = _size_S(5.0f);
        _textField.clipsToBounds = YES;
        _textField.delegate = self;
        [self addSubview:_textField];
        
        frame.size.width = SCREEN_WIDTH;
        frame.size.height = _textField.frame.size.height + CONTENT_MAGRIN_TOP + CONTENT_MAGRIN_BOTTOM;
        self.frame = frame;
        
        
        _sendBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _sendBtn.backgroundColor = RGBACOLOR(0x54, 0xcb, 0xff, 1);
        [_sendBtn setTitleColor:[UIColor colorWithColorType:ColorType_NavBtnNormal] forState:UIControlStateNormal];
        [_sendBtn setTitleColor:[UIColor colorWithColorType:ColorType_NavBtnPressed] forState:UIControlStateHighlighted];
        
        _sendBtn.layer.cornerRadius = _size_S(5.0f);
        _sendBtn.layer.masksToBounds = YES;
        _sendBtn.titleLabel.font = [DPFont systemFontOfSize:FONT_SIZE_MIDDLE];
        
        [_sendBtn setTitle: NSLocalizedString(@"BB_TXTID_发送", @"") forState:UIControlStateNormal];
        _sendBtn.size = CGSizeMake(SEND_BTN_WIDTH, SEND_BTN_HEIGHT);
        [_sendBtn addTarget:self action:@selector(sendButtonDidClick) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_sendBtn];
        
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    _sendBtn.right = self.width - CONTENT_MAGRIN;
    
    _sendBtn.centerY = _textField.centerY;

    _textField.width = _sendBtn.left - _textField.left - CONTENT_INSET;
}

- (void)sendButtonDidClick
{
    if (_delegate && [_delegate respondsToSelector:@selector(textFieldDidSendText:inputText:)]) {
        [_delegate textFieldDidSendText:self inputText:self.textField.text];
    }
}

- (void)willMoveToSuperview:(UIView *)newSuperview
{
    [super willMoveToSuperview:newSuperview];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textDidChange:) name:UITextViewTextDidChangeNotification object:nil];
}

- (void)removeFromSuperview
{
    [super removeFromSuperview];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextViewTextDidChangeNotification object:nil];
}

- (void)dealloc
{
    DPTrace("输入框销毁");
    
    _delegate = nil;
    _textField.delegate = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (CGFloat)textFieldHeightGrow
{
    return self.frame.size.height - (_minHeight + CONTENT_MAGRIN_TOP + CONTENT_MAGRIN_BOTTOM);
}

- (void)textDidChange:(NSNotification*)note
{
    CGFloat heght = MAX(_minHeight, _textField.contentSize.height);
    
    _maxTextFieldHeight = _maxCommentTextFieldHeight - (CONTENT_MAGRIN_TOP + CONTENT_MAGRIN_BOTTOM);
    
    heght = MIN(heght, _maxTextFieldHeight);
    
    CGRect tframe = _textField.frame;
    tframe.size.height = heght;
    _textField.frame = tframe;
    
    self.height = heght + CONTENT_MAGRIN_TOP + CONTENT_MAGRIN_BOTTOM;
    
    if (_delegate && [_delegate respondsToSelector:@selector(textFieldFrameChanged:)]) {
        [_delegate textFieldFrameChanged:self];
    }
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
//    if([text isEqualToString:@"\n"]) {
//        if (_delegate && [_delegate respondsToSelector:@selector(textFieldDidSendText:inputText:)]) {
//            [_delegate textFieldDidSendText:self inputText:self.textField.text];
//        }
//        return NO;
//    }
    return YES;
}

- (void)resetPlaceHolder:(NSString*)normalHolder editingPlaceHolder:(NSString*)editHolder
{
    _textField.defaultPlaceholder = normalHolder;
    _textField.editingPlaceholder = editHolder;
}

- (void)resignFirstResponderEx
{
    [_textField resignFirstResponder];
}

- (void)clearTextContent
{
    [_textField setText:@""];
    CGRect frame = _textField.frame;
    frame.size.height = _minHeight;
    _textField.frame = frame;
    self.height = _minHeight + CONTENT_MAGRIN_TOP + CONTENT_MAGRIN_BOTTOM;
    
    if (_delegate && [_delegate respondsToSelector:@selector(textFieldFrameChanged:)]) {
        [_delegate textFieldFrameChanged:self];
    }
}

- (NSString*)replyContent
{
    return _textField.text;
}
@end
