//
//  DPHomeTopView.m
//  BiuBiu
//
//  Created by haowenliang on 14/12/28.
//  Copyright (c) 2014年 dpsoft. All rights reserved.
//

#import "DPHomeTopView.h"
#import "ASProgressPopUpView.h"
#define HOME_TOPVIEW_COUNT_X _size_S(36)
#define HOME_TOPVIEW_BTM _size_S(13)

#define HOME_TOPVIEW_BOTTOM_INSET _size_S(11)
#define HOME_TOPVIEW_BOTTOM_HEIGHT _size_S(36)
#define HOME_TOPVIEW_PROGRESS_WIDTH _size_S(243)
#define HOME_TOPVIEW_PROGRESS_HEIGHT _size_S(1)

@interface DPHomeTopView ()
{
    NSTimer* _countingTimer;
    BOOL _runningAchivements;
    
    UILabel* _infoLabel1;
    UILabel* _countLabel;
    UILabel* _infoLabel2;
    UILabel* _infoLabel3;

    ASProgressPopUpView* _progressView;
    CGFloat _levelProgress;
    
    NSInteger _countAchived;
    NSInteger _tmpCount;
}

@end

@implementation DPHomeTopView

- (void)dealloc
{
    if (_countingTimer) {
        //关闭定时器
        [_countingTimer setFireDate:[NSDate distantFuture]];
        [_countingTimer invalidate];
        _countingTimer = nil;
    }
    
}
- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        _tmpCount = 0;
        _runningAchivements = NO;
        self.backgroundColor = RGBACOLOR(0x68, 0xe7, 0xc2, 1);
        [self createProgressView];
        [self createLabels];
        [self setUserAchiveCount:0 level:0];
    }
    return self;
}

- (void)createLabels
{
    UIFont* txtFont = [DPFont systemFontOfSize:FONT_SIZE_MIDDLE];
    UIColor* txtColor = [UIColor colorWithColorType:ColorType_WhiteTxt];
    
    _infoLabel1 = [[UILabel alloc] initWithFrame:CGRectMake(_size_S(17), _size_S(17), 0, 0)];
    _infoLabel1.backgroundColor = [UIColor clearColor];
    _infoLabel1.font = txtFont;
    _infoLabel1.textColor = txtColor;
    _infoLabel1.text = NSLocalizedString(@"BB_TXTID_我的积分", @"");
    [_infoLabel1 sizeToFit];
    _infoLabel1.textAlignment = NSTextAlignmentLeft;
    
    _infoLabel2 = [[UILabel alloc] initWithFrame:CGRectZero];
    _infoLabel2.backgroundColor = [UIColor clearColor];
    _infoLabel2.font = txtFont;
    _infoLabel2.textColor = txtColor;
    _infoLabel2.text = NSLocalizedString(@"BB_TXTID_分", @"");
    [_infoLabel2 sizeToFit];
    _infoLabel2.textAlignment = NSTextAlignmentLeft;
    
    _infoLabel3 = [[UILabel alloc] initWithFrame:CGRectMake(_size_S(17), _size_S(17), self.width - 2*_size_S(17), HOME_TOPVIEW_BOTTOM_HEIGHT)];
    _infoLabel3.backgroundColor = [UIColor clearColor];
    _infoLabel3.font = txtFont;
    _infoLabel3.textColor = txtColor;
    _infoLabel3.text = NSLocalizedString(@"BB_TXTID_超过当前0%的biubiu客", @"");
    _infoLabel3.textAlignment = NSTextAlignmentCenter;
    
    _countLabel = [[UILabel alloc] initWithFrame:CGRectMake(_size_S(17), HOME_TOPVIEW_COUNT_X, 0, 0)];
    _countLabel.backgroundColor = [UIColor clearColor];
    _countLabel.font = [DPFont systemFontOfSize:72];
    _countLabel.textColor = txtColor;
    _countLabel.text = @"0";
    [_countLabel sizeToFit];
    _countLabel.textAlignment = NSTextAlignmentLeft;
    
    [self addSubview:_countLabel];
    [self addSubview:_infoLabel1];
    [self addSubview:_infoLabel2];
    [self addSubview:_infoLabel3];
}

- (void)createProgressView
{
    _progressView = [[ASProgressPopUpView alloc] initWithFrame:CGRectMake((SCREEN_WIDTH - HOME_TOPVIEW_PROGRESS_WIDTH)/2, 0, HOME_TOPVIEW_PROGRESS_WIDTH, HOME_TOPVIEW_PROGRESS_HEIGHT)];
    _progressView.font = [DPFont systemFontOfSize:FONT_SIZE_SMALL];
    _progressView.popUpViewAnimatedColors = @[RGBACOLOR(0x61, 0xda, 0xb7, 1)];
    _progressView.textColor = [UIColor colorWithColorType:ColorType_WhiteTxt];
    [_progressView showPopUpViewAnimated:YES];
    _progressView.trackTintColor = RGBACOLOR(0xe6, 0xe9, 0xee, 1);
    [self addSubview:_progressView];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    _progressView.bottom = self.height - HOME_TOPVIEW_BOTTOM_HEIGHT;
    _infoLabel3.center = CGPointMake(self.width/2, self.height - HOME_TOPVIEW_BOTTOM_HEIGHT/2);
    
    _countLabel.left = (self.width - (_countLabel.width + _infoLabel2.width + HOME_TOPVIEW_BOTTOM_INSET))/2;
    _infoLabel2.left = _countLabel.right + HOME_TOPVIEW_BOTTOM_INSET;
    _infoLabel2.bottom = _countLabel.bottom - HOME_TOPVIEW_BTM;
}

#pragma mark - Timer
static CGFloat eachLevel = 0.005;
static NSInteger eachCount = 2;
static CGFloat timeInterval = 0.05;

- (void)progress
{
    if (_progressView.progress >= _levelProgress && _tmpCount >= _countAchived) {
        [self stopRunloopProgress];
        _runningAchivements = NO;
        return;
    }
    BOOL nextRunloop = NO;
    float progress = _progressView.progress;
    if (progress < _levelProgress) {
        progress += eachLevel;
        [_progressView setProgress:MIN(_levelProgress, progress) animated:YES];
        NSString* pstr = [NSString stringWithFormat:@"%zd%%",MIN((int)(progress*100),(int)(_levelProgress*100))];
        _infoLabel3.text = [NSString stringWithFormat:NSLocalizedString(@"BB_TXTID_超过当前%@的biubiu客", @""),pstr];
        nextRunloop = YES;
    }
    
    if (_tmpCount < _countAchived) {
        _tmpCount += eachCount;
        [_countLabel setText:[NSString stringWithFormat:@"%zd", MIN(_countAchived, _tmpCount)]];
        [_countLabel sizeToFit];
        [self setNeedsLayout];
        nextRunloop = YES;
    }
    
    if (nextRunloop) {
        _runningAchivements = YES;
        _countingTimer = [NSTimer scheduledTimerWithTimeInterval:timeInterval
                                                          target:self
                                                        selector:@selector(progress)
                                                        userInfo:nil
                                                         repeats:NO];
    }else{
        _runningAchivements = NO;
        if (_countingTimer) {
            [_countingTimer setFireDate:[NSDate distantFuture]];
            [_countingTimer invalidate];
            _countingTimer = nil;
        }
    }
}

- (void)setUserAchiveCount:(NSInteger)counts level:(CGFloat)level
{
    _levelProgress = (CGFloat)ceil(level*100)/100.0;
    _countAchived = counts;
    if(_runningAchivements)
    {

    }else if(_progressView.progress == 0){
        _tmpCount = 0;
        eachCount = 2;
        counts = (counts - _countAchived)/10;
        while ((counts = counts/10) > 0) {
            eachCount = eachCount + 1;
        }
        NSInteger times = (_countAchived - 1)/eachCount + 1;
        while (times > 150) {
            eachCount = eachCount+3;
            times = (_countAchived - 1)/eachCount + 1;
        }
        eachLevel = (_levelProgress - _progressView.progress)/(times+1);
        [self progress];
    }else{
        [_progressView setProgress:_levelProgress animated:YES];
        NSString* pstr = [NSString stringWithFormat:@"%zd%%",(int)(_levelProgress*100)];
        _infoLabel3.text = [NSString stringWithFormat:NSLocalizedString(@"BB_TXTID_超过当前%@的biubiu客", @""),pstr];
        [_countLabel setText:[NSString stringWithFormat:@"%zd", _countAchived]];
    }
}

- (void)stopRunloopProgress
{
    if (_countingTimer) {
        [_countingTimer setFireDate:[NSDate distantFuture]];
        [_countingTimer invalidate];
        _countingTimer = nil;
    }
    
    [_progressView setProgress:_levelProgress animated:YES];
    NSString* pstr = [NSString stringWithFormat:@"%zd%%",(int)(_levelProgress*100)];
    _infoLabel3.text = [NSString stringWithFormat:NSLocalizedString(@"BB_TXTID_超过当前%@的biubiu客", @""),pstr];
    [_countLabel setText:[NSString stringWithFormat:@"%zd", _countAchived]];
    [_countLabel sizeToFit];
    [self setNeedsLayout];
}

@end
