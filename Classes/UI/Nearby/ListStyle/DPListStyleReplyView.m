//
//  DPListStyleReplyView.m
//  BiuBiu
//
//  Created by haowenliang on 15/1/16.
//  Copyright (c) 2015年 dpsoft. All rights reserved.
//

#import "DPListStyleReplyView.h"
#import "OBaconView.h"
#import "OBaconViewItem.h"

#import "BackSourceInfo_2005.h"

#import "ListConstants.h"


#define REPLY_LABEL_FONT ([DPFont systemFontOfSize:FONT_SIZE_LARGE])
@interface DPReplyLabelCell : OBaconViewItem

@property (nonatomic, strong) UILabel* msgLabel;

- (void)setMessage:(NSString*)text;

@end

@implementation DPReplyLabelCell

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        _msgLabel = [[UILabel alloc] initWithFrame:self.bounds];
        _msgLabel.textColor = [UIColor whiteColor];
        _msgLabel.font = REPLY_LABEL_FONT;
        _msgLabel.textAlignment = NSTextAlignmentCenter;
        _msgLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        _msgLabel.backgroundColor = [UIColor clearColor];
        
        [self addSubview:_msgLabel];
    }
    return self;
}

- (void)setSubColorType:(NSInteger)type
{
    switch (type%3) {
        case 0:
            _msgLabel.backgroundColor = [UIColor colorWithColorType:ColorType_LightGreen];
            break;
        case 1:
            _msgLabel.backgroundColor = [UIColor colorWithColorType:ColorType_LightPink];
            break;
        case 2:
            _msgLabel.backgroundColor = [UIColor colorWithColorType:ColorType_LightYellow];
            break;
        default:
            break;
    }
}

- (void)setMessage:(NSString *)text
{
    _msgLabel.text = text;
    [_msgLabel sizeToFit];
    _msgLabel.width += _size_S(20);
    _msgLabel.height += _size_S(20);
    
    _msgLabel.layer.cornerRadius = _msgLabel.height/2;
    _msgLabel.layer.masksToBounds = YES;
    
    self.size = CGSizeMake(_msgLabel.width,_msgLabel.height);
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    _msgLabel.center = CGPointMake(self.width/2, self.height/2);
}

@end

@interface DPListStyleReplyView ()<OBaconViewDataSource, OBaconViewDelegate>
{
    NSInteger _colorType;
}
@property (nonatomic, strong) OBaconView* scrollView;
@end


@implementation DPListStyleReplyView

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
//        [self setup];
    }
    return self;
}

- (void)setColorType:(NSInteger)type
{
    _colorType = type;
    switch (_colorType%3) {
        case 0:
            self.backgroundColor = [UIColor colorWithColorType:ColorType_Green];
            break;
        case 1:
            self.backgroundColor = [UIColor colorWithColorType:ColorType_Pink];
            break;
        case 2:
            self.backgroundColor = [UIColor colorWithColorType:ColorType_Yellow];
            break;
        default:
            break;
    }
}

- (void)setup
{
    if(_scrollView)return;
    
    CGRect sframe = self.bounds;
    sframe.origin.x = 0;
    sframe.origin.y = _size_S(8);
    sframe.size.width = SCREEN_WIDTH - DP_LEFTVIEW_WIDTH;
    sframe.size.height = DP_CELL_DEFAULT_HEIGHT - 2* _size_S(8);
    
    _scrollView = [[OBaconView alloc] initWithFrame:sframe];
    _scrollView.animationDirection = OBaconViewAnimationDirectionLeft;
    _scrollView.dataSource = self;
    _scrollView.delegate = self;
    _scrollView.animationTime = 4;
    _scrollView.disableSwipGesture = YES;
    [self addSubview:_scrollView];
}

- (void)resetReplyView
{
    _datasource = nil;
    
    _scrollView.delegate = nil;
    _scrollView.dataSource = nil;
    
    [_scrollView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    [_scrollView removeFromSuperview];
    self.scrollView = nil;
}

- (void)setDatasource:(NSMutableArray *)datasource
{
    _datasource = [datasource mutableCopy];
    
    [self setup];
    [_scrollView reloadData];
}

- (void)appendDatasource:(NSArray *)array
{
    if(_datasource == nil) _datasource = [[NSMutableArray alloc] init];
    
    [_datasource addObjectsFromArray:[array copy]];
    
    [self setup];
    [_scrollView reloadData];
}

- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
}

//=============================================================================
#pragma mark - baconView stuff

- (int) numberOfItemsInbaconView:(OBaconView *)baconView{
    DPTrace("滚动数据为：%zd条",[_datasource count]);
    return (int)[_datasource count];
}

- (OBaconViewItem *) baconView:(OBaconView *)baconView viewForItemAtIndex:(int)index{
    static NSString *baconItemIdentifier = @"DPReplyLabelCell";
    
    // deque baconcell
    DPReplyLabelCell *baconItem = (DPReplyLabelCell *)[baconView dequeueReusableItemWithIdentifier:baconItemIdentifier];
    
    // create new one if it's nil
    if (baconItem == nil) {
        baconItem = [[DPReplyLabelCell alloc] initWithFrame:CGRectZero];
    }
    
    // fill data
    if (index < [_datasource count]) {
        DPAnswerModel* contentData = _datasource[index];
        NSString* string = [NSString stringWithFormat:@"%@", contentData.ans];
        NSString *trimmedString = [string stringByTrimmingCharactersInSet:
                                   [NSCharacterSet whitespaceAndNewlineCharacterSet]];
        trimmedString = [trimmedString stringByReplacingOccurrencesOfString:@"\n" withString:@" "];
        [baconItem setMessage:trimmedString];
    }
    
    [baconItem setSubColorType:_colorType];
    baconItem.userInteractionEnabled = NO;
    return baconItem;
}

- (void) baconView:(OBaconView *)baconView didSelectItemAtIndex:(NSInteger)index{
    // show alert
    return;
}

- (CGFloat)widthOfString:(NSString *)string withFont:(UIFont *)font {
    NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:font, NSFontAttributeName, nil];
    return [[[NSAttributedString alloc] initWithString:string attributes:attributes] size].width;
}

@end
