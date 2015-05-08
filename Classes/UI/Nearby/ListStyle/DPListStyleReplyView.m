//
//  DPListStyleReplyView.m
//  BiuBiu
//
//  Created by haowenliang on 15/1/16.
//  Copyright (c) 2015年 dpsoft. All rights reserved.
//

#import "DPListStyleReplyView.h"
#import "BackSourceInfo_2005.h"
#import "AnimateLabel.h"
#import "ListConstants.h"

#define REPLY_LABEL_FONT ([DPFont systemFontOfSize:FONT_SIZE_LARGE])

static int DanKuLines = 5;

@interface DPListStyleReplyView ()
{
    NSInteger _colorType;
    
    NSInteger _loopTime;
    
    NSInteger _loopRow;
    
    float* dankuLineLength;
    
    BOOL _runningLoop;
}

@property (nonatomic, strong) UILabel* informationLabel;
@property (nonatomic, strong) NSMutableArray* positionArray;

@end

@implementation DPListStyleReplyView

+ (instancetype)shareInstance
{
    static DPListStyleReplyView* s_instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        s_instance = [[DPListStyleReplyView alloc] initWithFrame:CGRectMake(0, CELLDEGAULTHEIGHT, SCREEN_WIDTH,DP_CELL_DEFAULT_HEIGHT)];
    });
    return s_instance;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        DPTrace("回复弹幕页面创建");
        _dankuIndex = NSNotFound;
        _loopTime = 0;
        self.backgroundColor = [UIColor clearColor];
        _animating = NO;
        dankuLineLength = (float *)malloc(DanKuLines * sizeof(float));
        
        [self addSubview:self.informationLabel];
    }
    return self;
}

- (UILabel *)informationLabel
{
    if (nil == _informationLabel) {
        _informationLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _informationLabel.backgroundColor = [UIColor clearColor];
        _informationLabel.textColor = [UIColor colorWithColorType:ColorType_HighlightTxt];
        _informationLabel.font = [UIFont systemFontOfSize:FONT_SIZE_LARGE];
    }
    return _informationLabel;
}

- (void)setInformationType:(INFOTYPE)type
{
    switch ( type) {
        case INFOTYPE_EMPTY:
        {
            _informationLabel.text = @"还没有留言，留个言弹一发？";
        }break;
        case INFOTYPE_PROGRESS:
        {
            _informationLabel.text = @"一大波留言正在赶来 ^_^";
        }break;
        default:
            break;
    }
    _informationLabel.hidden = NO;
    [_informationLabel sizeToFit];
    _informationLabel.center = CGPointMake(self.width/2, self.height/2);
}

- (void)removeInformationLabelWithAnimate:(BOOL)animate
{
    [UIView animateWithDuration:3 animations:^{
        _informationLabel.right = 0;
    } completion:^(BOOL finished) {
        if (finished) {
            _informationLabel.hidden = YES;
        }
    }];
}

- (void)dealloc
{
    DPTrace("回复弹幕页面销毁");
}

- (UIColor*)randomColor:(NSInteger)type
{
    UIColor* color = [UIColor blackColor];
    type = type + _loopTime + _loopRow;
    switch (type%DanKuLines) {
        case 0:
            color = RGBACOLOR(0x79,0x93,0xdf,1);//[UIColor colorWithColorType:ColorType_Green];
            break;
        case 1:
            color = RGBACOLOR(0x57,0x87,0x42,1);//[UIColor colorWithColorType:ColorType_Pink];
            break;
        case 2:
            color = RGBACOLOR(0xb2,0x36,0x36,1);//[UIColor colorWithColorType:ColorType_Yellow];
            break;
        default:
            color = RGBACOLOR(0x33,0x33,0x33,1);
            break;
    }
    return color;
}

- (UIFont*)randomFont:(NSInteger)type
{
    type += (_loopRow + _loopTime)%7;
    return [UIFont systemFontOfSize:(13+type)];
}

- (NSMutableArray *)positionArray
{
    if (nil == _positionArray) {
        _positionArray = [NSMutableArray new];
    }
    return _positionArray;
}

- (CGFloat)getRandomOffsetY:(NSInteger)index
{
    CGFloat yoffset = 0;
    yoffset = (index%DanKuLines) * (self.height/DanKuLines);
    return yoffset;
}

- (CGFloat)getRandomOffsetX:(NSInteger)index withWidth:(CGFloat)twidth
{
    float with = dankuLineLength[index%DanKuLines];
    dankuLineLength[index%DanKuLines] = with + twidth;
    
    return with + random()%20;
}

- (void)setup
{
    @synchronized(self){
        if (_runningLoop) {
            return;
        }
        _runningLoop = YES;
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(setup) object:nil];
        
        NSMutableArray* biubiu = [_datasource mutableCopy];
        while ([biubiu count] < DanKuLines) {
            [biubiu addObjectsFromArray:[_datasource copy]];
        }
        _loopRow = 0;
        for (int i = 0; i < DanKuLines; i++) {
            dankuLineLength[i] = SCREEN_WIDTH;
        }
        for (NSInteger index = 0; index < biubiu.count; index++) {
            if(_runningLoop == NO){
                //强制停止循环
                return;
            }
            
            if (index%DanKuLines == 0) {
                _loopRow++;
            }
            
            DPAnswerModel* contentData = biubiu[index];
            NSString* string = [NSString stringWithFormat:@"%@", contentData.ans];
            NSString *trimmedString = [string stringByTrimmingCharactersInSet:
                                       [NSCharacterSet whitespaceAndNewlineCharacterSet]];
            trimmedString = [trimmedString stringByReplacingOccurrencesOfString:@"\n" withString:@" "];
            
            AnimateLabel* label = [[AnimateLabel alloc] initWithFrame:CGRectZero];
            label.backgroundColor = [UIColor clearColor];
            label.text = trimmedString;
            
            
            NSInteger randomInt = rand()%8;
            label.font = [self randomFont:randomInt];
            label.textColor = [self randomColor:randomInt];
            
            [label sizeToFit];
            [self addSubview:label];
            
            //在开始动画前，需要设置起始位置
            CGFloat width = [self widthOfString:trimmedString withFont:label.font];
            label.left = [self getRandomOffsetX:(index+2*_loopTime) withWidth:width];
            label.top = [self getRandomOffsetY:(index+2*_loopTime)];
            
            [label startAnimation];
        }
        _loopTime++;
        
        //计算下次启动的时间
        CGFloat maxWith = 0;
        for (int i = 0; i < DanKuLines; i++) {
//            maxWith = MAX(maxWith, dankuLineLength[i]);
            maxWith += dankuLineLength[i];
        }
        int time = MAX(1.5,abs((maxWith/DanKuLines-SCREEN_WIDTH)/(1.2*60)));
        
         _runningLoop = NO;
        [self performSelector:@selector(setup) withObject:nil afterDelay:time];
    }
}

- (void)resetReplyView
{
    DPTrace("重置回复弹幕页面");
    _runningLoop = NO;
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(setup) object:nil];
    _loopTime = 0;
    _datasource = nil;
    NSArray* subviews = self.subviews;
    for (UIView* view in subviews) {
        if ([view isKindOfClass:[AnimateLabel class]]) {
            [(AnimateLabel*)view disappearFromSuperview];
        }
    }
    _animating = NO;
}

- (void)setDatasource:(NSMutableArray *)datasource
{
    _datasource = [datasource mutableCopy];
    
    [self setup];
}

- (void)appendDatasource:(NSArray *)array
{
    if(_datasource == nil) _datasource = [[NSMutableArray alloc] init];
    
    [_datasource addObjectsFromArray:[array copy]];
    
    [self setup];
}

- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
}

- (CGFloat)widthOfString:(NSString *)string withFont:(UIFont *)font {
    NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:font, NSFontAttributeName, nil];
    return [[[NSAttributedString alloc] initWithString:string attributes:attributes] size].width;
}
@end
