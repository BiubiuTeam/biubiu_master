//
//  DPTextView.m
//  BiuBiu
//
//  Created by haowenliang on 14/12/3.
//  Copyright (c) 2014年 dpsoft. All rights reserved.
//


#import "DPTextView.h"

@implementation DPTextView
{
    NSUInteger _textLength;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self awakeFromNib];
    }
    return self;
}

- (void)awakeFromNib {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dpBeginEditing:) name:UITextViewTextDidBeginEditingNotification object:self];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dpEndEditing:) name:UITextViewTextDidEndEditingNotification object:self];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dpTextDidChanged:) name:UITextViewTextDidChangeNotification object:self];
    
    _textLength = 0;
    _maxCount = 200;
    _minCount = 0;
    _inputCount = 0;
}

- (void)dpTextDidChanged:(NSNotification*)notification
{
    [self setNeedsDisplay];
    
    if (self.markedTextRange) {
        return;
    }
    _textLength = [self.text length];
    
    //统计字数
    NSString* textContent = [self text];
    _inputCount = [textContent length];
    
    if (_countLabel) {
        _countLabel.text = [NSString stringWithFormat:@"%zd/%zd",_inputCount,_maxCount];
    }
}

- (void)dpBeginEditing:(NSNotification*)notification
{
    [self updateEditingPlaceholderState];
}

- (void)dpEndEditing:(NSNotification*)notification
{
    [self updateEditingPlaceholderState];
}

- (void)drawRect:(CGRect)rect
{
    if ([self.text length] == 0) {
        NSString *text = nil;
        if (_isEditing) {
            if (_editingPlaceholder) {
                text = _editingPlaceholder;
            }
        }else{
            if (_defaultPlaceholder) {
                text = _defaultPlaceholder;
            }
        }
        
        if (text) {
            _isPlaceholderDisplayed = YES;
            [[UIColor colorWithColorType:ColorType_LightTxt] set];
            
            UIEdgeInsets textInset = UIEdgeInsetsZero;
            CGFloat leftV = 10;
            if (SYSTEM_VERSION < 7.0) {
                
            }else{
                textInset = [self textContainerInset];
                leftV = textInset.left + 3.0;
            }
            
            CGRect rectDefault = {leftV, textInset.top, rect.size.width-leftV*2, rect.size.height - textInset.top*2};
            [text drawInRect:rectDefault withFont:self.font lineBreakMode:NSLineBreakByTruncatingTail];
            
        }else{
            _isPlaceholderDisplayed = NO;
        }
    }else{
        _isPlaceholderDisplayed = NO;
    }
}

-(void)setText:(NSString *)text
{
    // http://stackoverflow.com/questions/19948394/textviewdidchange-crashes-in-ios-7
    // 加 markedTextRange 判断，防止crash，见上面的帖子
    if (self.markedTextRange) {
        return;
    }
    
    BOOL originalValue = self.scrollEnabled;
    //If one of GrowingTextView's superviews is a scrollView, and self.scrollEnabled == NO,
    //setting the text programatically will cause UIKit to search upwards until it finds a scrollView with scrollEnabled==yes
    //then scroll it erratically. Setting scrollEnabled temporarily to YES prevents this.
    [self setScrollEnabled:YES];
    [super setText:text];
    [self setScrollEnabled:originalValue];
}

-(void)setText:(NSString *)text withRange:(NSRange)range
{
    [self setText:text];
    self.selectedRange = range;
}

- (BOOL)becomeFirstResponder
{
	self.isEditing = YES;
    BOOL ret = [super becomeFirstResponder];
    return ret;
}

- (BOOL)resignFirstResponder
{
	self.isEditing = NO;
    BOOL ret = [super resignFirstResponder];
	return ret;
}

- (void)setDefaultPlaceholder:(NSString *)defaultPlaceholder
{
    if (_defaultPlaceholder != defaultPlaceholder) {
        _defaultPlaceholder = defaultPlaceholder;
        [self setNeedsDisplay];
    }
}

- (void)setEditingPlaceholder:(NSString *)editingPlaceholder
{
    if (_editingPlaceholder != editingPlaceholder) {
        _editingPlaceholder = editingPlaceholder;
        [self setNeedsDisplay];
    }
}

- (void)setIsEditing:(BOOL)isEditing
{
    if (isEditing != _isEditing) {
        _isEditing  = isEditing;
        
        [self setNeedsDisplay];
    }
}

- (void)updateEditingPlaceholderState
{
    BOOL needPlaceholderDisplayed = NO;
    if ([self.text length] == 0) {
        if (_isEditing) {
            if (_editingPlaceholder) {
                needPlaceholderDisplayed = YES;
            }
        }else{
            if (_defaultPlaceholder) {
                needPlaceholderDisplayed = YES;
            }
        }
    }
    
    if (needPlaceholderDisplayed != _isPlaceholderDisplayed) {
        [self setNeedsDisplay];
    }
}

@end
