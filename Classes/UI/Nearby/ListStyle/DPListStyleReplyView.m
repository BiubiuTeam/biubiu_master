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
    }
    return self;
}

- (void)dealloc
{
    DPTrace("回复弹幕页面销毁");
}

- (UIColor*)randomColor:(NSInteger)type
{
    UIColor* color = [UIColor blackColor];
    type = type + _loopTime + _loopRow;
    switch (type%8) {
        case 7:
            color = [UIColor colorWithColorType:ColorType_Green];
            break;
        case 6:
            color = [UIColor colorWithColorType:ColorType_Pink];
            break;
        case 5:
            color = [UIColor colorWithColorType:ColorType_Yellow];
            break;
        default:
            break;
    }
    return color;
}

- (UIFont*)randomFont:(NSInteger)type
{
    type += (_loopRow + _loopTime)%5;
    return [UIFont systemFontOfSize:(16+type)];
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
        CGFloat maxWith = dankuLineLength[0];
        for (int i = 1; i < DanKuLines; i++) {
            maxWith = MAX(maxWith, dankuLineLength[i]);
        }
        int time = abs((maxWith-SCREEN_WIDTH)/(1.2*60));
        
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
