//
//  DPLoadingMessageView.m
//  BiuBiu
//
//  Created by haowenliang on 15/1/25.
//  Copyright (c) 2015年 dpsoft. All rights reserved.
//

#import "DPLoadingMessageView.h"

#define INDICATOR_TEXTLABEL_INSET _size_S(10)

@interface DPLoadingMessageView ()

@property (nonatomic, strong) UILabel* textLabel;
@property (nonatomic, strong) UIActivityIndicatorView* activityIndicator;

@end

@implementation DPLoadingMessageView

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor clearColor];
        //界面加载
        _textLabel = [[UILabel alloc] initWithFrame:self.bounds];
        _textLabel.textAlignment = NSTextAlignmentCenter;
        _textLabel.backgroundColor = [UIColor clearColor];
        _textLabel.textColor = RGBACOLOR(0x80, 0x80, 0x80, 1);
        _textLabel.font = [UIFont systemFontOfSize:_size_S(14)];
        [self addSubview:_textLabel];
        
        _activityIndicator = [[UIActivityIndicatorView alloc]initWithFrame:CGRectMake(0,48,24,24)];
        [_activityIndicator setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleGray];
        _activityIndicator.hidden = YES;
        [self addSubview: _activityIndicator];
    }
    return self;
}

- (void)setLoadingMessage:(NSString*)text hideLoadingView:(BOOL)hide
{
    [_textLabel setText:text];
    [_textLabel sizeToFit];
    if(hide){
        [_activityIndicator stopAnimating];
        [_activityIndicator setHidden:YES];
    }else{
        [_activityIndicator setHidden:NO];
        [_activityIndicator startAnimating];
    }
    [self setNeedsLayout];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGFloat width = _textLabel.width + _activityIndicator.width + INDICATOR_TEXTLABEL_INSET;
    _activityIndicator.left = (self.width - width)/2;
    
    if (_activityIndicator.hidden) {
        _textLabel.center = CGPointMake(self.width/2, self.height/2);
    }else{
        _textLabel.right = (self.width + width)/2;
    }
    _activityIndicator.centerY = _textLabel.centerY = self.height/2;;
}

@end
