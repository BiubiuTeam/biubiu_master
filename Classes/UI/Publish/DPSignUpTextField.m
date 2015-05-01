//
//  DPSignUpTextField.m
//  BiuBiu
//
//  Created by haowenliang on 14/12/9.
//  Copyright (c) 2014年 dpsoft. All rights reserved.
//

#import "DPSignUpTextField.h"

#define LINE_WIDTH _size_S(24)
#define LINE_HEIGHT _size_S(2)
#define LINE_TEXT_INSET _size_S(3)

#define VIEW_INSET _size_S(0)

#define LINE_COLOR (RGBACOLOR(0x99, 0x99, 0x99, 1))

#define SIGN_TEXT_COLOR (RGBACOLOR(0x99, 0x99, 0x99, 1))
#define SIGN_UP_MARGIN_LEFT _size_S(15)

#define BOOKMARK_WORD_LIMIT 16

@interface SignTextField : UITextField
@property (nonatomic, strong) UIColor* placeColor;
@end

@implementation SignTextField

- (void)setPlaceColor:(UIColor *)placeColor
{
    _placeColor = placeColor;
    
    //placeholder内容的变动才会触发drawPlaceholderInRect:
    NSString* place = [self placeholder];
    self.placeholder = nil;
    self.placeholder = place;
}

- (void) drawPlaceholderInRect:(CGRect)rect {
    if (_placeColor) {
        [_placeColor setFill];
        [[self placeholder] drawInRect:rect withFont:self.font];
    }else{
        [super drawPlaceholderInRect:rect];
    }
}

@end


@interface DPSignUpTextField()<UITextFieldDelegate>
@property (nonatomic, strong) UIView* line;
@end

@implementation DPSignUpTextField

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    self.superBgColor = nil;
    self.line = nil;
    self.textField = nil;
    self.delegate = nil;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        _line = [[UIView alloc] initWithFrame:CGRectMake(VIEW_INSET/2, 0, LINE_WIDTH, LINE_HEIGHT)];
        _line.backgroundColor = [UIColor colorWithColorType:ColorType_LightTxt];
        [self addSubview:_line];
        
        _textField = [[SignTextField alloc] initWithFrame:CGRectZero];
        _textField.backgroundColor = [UIColor clearColor];
        
        _textField.placeColor = [UIColor colorWithColorType:ColorType_LightTxt];
        _textField.font = [DPFont boldSystemFontOfSize:FONT_SIZE_LARGE];
        _textField.textColor = [UIColor colorWithColorType:ColorType_LightTxt];
        _textField.delegate = self;
//        _textField.keyboardType = UIKeyboardTypeASCIICapable;
        _textField.placeholder = NSLocalizedString(@"BB_TXTID_署名", nil);

        _textField.text = [self lastUserInput];
        [_textField sizeToFit];
        [self addSubview:_textField];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textDidChanged:) name:UITextFieldTextDidChangeNotification object:nil];
        
        frame.size.height = _textField.height;
        frame.size.width = _textField.width + LINE_WIDTH + LINE_TEXT_INSET + VIEW_INSET;
        [self setFrame:frame];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    _textField.right = self.bounds.size.width;
    _textField.centerY = CGRectGetHeight(self.bounds)/2.0;
    
    CGRect tframe = _textField.frame;
    _line.right = tframe.origin.x - LINE_TEXT_INSET;
    _line.centerY = CGRectGetHeight(self.bounds)/2.0;
}

- (void)setTextFieldInputAccessoryView:(UIView*)accessoryView
{
    _textField.inputAccessoryView = nil;
    _textField.inputAccessoryView = accessoryView;
}

- (NSString*)currentWrittenName
{
    return _textField.text;
}

- (void)textDidChanged:(NSNotification*)notification
{
    //该判断用于联想<strong>输入</strong>
    NSString* text = _textField.text;
    if ([NSString stringLengthOfType:TEXT_CONSTRAIN_STRING_LENGTH str:text] > BOOKMARK_WORD_LIMIT)
    {
        _textField.text = [text substringToIndex:BOOKMARK_WORD_LIMIT];
    }
    
    [_textField sizeToFit];
    CGRect frame = self.frame;
    frame.size.height = _textField.height;
    frame.size.width = _textField.width + LINE_WIDTH + LINE_TEXT_INSET + VIEW_INSET;
    [self setFrame:frame];//change frame will call up layoutsubviews
    
    if (_delegate && [_delegate respondsToSelector:@selector(textDidChanged:text:)]) {
        [_delegate textDidChanged:self text:_textField.text];
    }
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if ([string isEqualToString:@"\n"])
    {
        if (_delegate && [_delegate respondsToSelector:@selector(resignAllResponder:)]) {
            [_delegate resignAllResponder:self];
        }
        return NO;
    }
    NSString* txt = textField.text;
    
    if (range.location == [txt length] - 1 && range.length == 1 && [string length] == 0)
    {
        return YES;
    }
    
    // 对范围进行约束
    if (range.location == NSNotFound)
    {
        range.location = 0;
    }
    if (range.location > [txt length])
    {
        range.location = [txt length];
    }
    if (range.location + range.length > [txt length])
    {
        range.length = [txt length] - range.location;
    }
    
    txt = [txt stringByReplacingCharactersInRange:range withString:string];
    NSUInteger inputLen = [NSString stringLengthOfType:TEXT_CONSTRAIN_STRING_LENGTH str:txt];
    return  inputLen <= BOOKMARK_WORD_LIMIT;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    _line.backgroundColor = [UIColor colorWithColorType:ColorType_WhiteTxt];
    textField.textColor = [UIColor colorWithColorType:ColorType_WhiteTxt];
    self.backgroundColor = [UIColor colorWithColorType:ColorType_LightTxt];
    
    _textField.placeColor = [UIColor colorWithColorType:ColorType_WhiteTxt];
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    _line.backgroundColor = [UIColor colorWithColorType:ColorType_LightTxt];
    textField.textColor = [UIColor colorWithColorType:ColorType_LightTxt];
    self.backgroundColor = [UIColor clearColor];
    _textField.placeColor = [UIColor colorWithColorType:ColorType_LightTxt];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (_delegate && [_delegate respondsToSelector:@selector(resignAllResponder:)]) {
        [_delegate resignAllResponder:self];
    }
}

- (void)rememberUserInput
{
    NSString* text = _textField.text;
    if (nil == text) {
        text = @"";
    }
    //将上述数据全部存储到NSUserDefaults中
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    //存储时，除NSNumber类型使用对应的类型意外，其他的都是使用setObject:forKey:
    [userDefaults setObject:text forKey:@"userwrittenname"];
    [userDefaults synchronize];
}

- (NSString*)lastUserInput
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    return [userDefaults objectForKey:@"userwrittenname"];
}

@end
