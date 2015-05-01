//
//  DPStreamView.h
//  StreamView
//
//  Created by haowenliang on 14/12/17.
//  Copyright (c) 2014年 dp-soft. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DPStreamCellInfo.h"

typedef enum {
    DPStreamViewScrollPositionNone = 0,
    DPStreamViewScrollPositionTop = 1,
    DPStreamViewScrollPositionMiddle = 2,
    DPStreamViewScrollPositionBottom = 3
}DPStreamViewScrollPosition;

@class DPStreamView;
@protocol DPStreamViewDelegate <UIScrollViewDelegate>

@required
- (NSInteger)numberOfCellsInStreamView:(DPStreamView *)streamView;
- (UIView<DPResusableCell> *)streamView:(DPStreamView *)streamView cellAtIndex:(NSInteger)index;
- (CGFloat)streamView:(DPStreamView *)streamView widthForCellAtIndex:(NSInteger)index;

@optional

- (NSInteger)numberOfRowsInStreamView:(DPStreamView *)streamView;
- (UIView *)headerForStreamView:(DPStreamView *)streamView;
- (UIView *)footerForStreamView:(DPStreamView *)streamView;

- (void)streamView:(DPStreamView *)streamView willDisplayCell:(UIView<DPResusableCell> *)cell forIndex:(NSInteger)index;

- (void)streamView:(DPStreamView *)streamView didSelectedCellAtIndex:(NSInteger)index;
@optional

@end

@interface DPStreamViewUIScrollViewDelegate : NSObject<UIScrollViewDelegate>
@property (nonatomic, weak) DPStreamView *streamView;
@end

@interface DPStreamView : UIScrollView
{
    NSMutableArray* _cellWidthByIndex; //1d, 单元宽度
    NSMutableArray* _cellWidthByRow;   //2d, 单元宽度
    NSMutableArray* _rectForCells;     //2d, 单元frame
    NSMutableArray* _infoForCells;     //1d, 单元信息
    
    NSMutableDictionary* _cellCache; // reuseIdentifier => NSMutableArray
    NSSet* _visibleCellInfo;
    
    CGFloat _rowHeight;
    DPStreamViewUIScrollViewDelegate* _delegateObj;
}

@property (nonatomic, weak) id<DPStreamViewDelegate> dpDelegate;
@property (nonatomic, readonly) UIView *headerView;
@property (nonatomic, readonly) UIView *footerView;
@property (nonatomic, readonly) UIView *contentView;
@property (nonatomic, readonly) CGFloat rowHeight;

@property (nonatomic, assign) CGFloat cellPadding; //单元间距
@property (nonatomic, assign) CGFloat rowPadding; //列间距

- (id<DPResusableCell>)dequeueReusableCellWithIdentifier:(NSString *)identifier;
- (void)reloadData;
- (void)scrollToCellAtIndex:(NSUInteger)index atScrollPosition:(DPStreamViewScrollPosition)scrollPosition animated:(BOOL)animated;

- (CGFloat)maxOffsetX;
@end
