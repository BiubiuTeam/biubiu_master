//
//  DPScrollSelectStrip.h
//  BiuBiu
//
//  Created by haowenliang on 15/1/3.
//  Copyright (c) 2015年 dpsoft. All rights reserved.
//

#import "DPStreamView.h"

@class DPScrollSelectStrip;

@protocol ScrollSelectStripProtocol <DPStreamViewDelegate>

@optional
- (void) willUpdateContentOffsetForStrip: (DPScrollSelectStrip*) strip;

- (void) didUpdateContentOffsetForStrip: (DPScrollSelectStrip*) strip;

@end


@interface DPScrollSelectStrip : DPStreamView

@property (nonatomic, weak) id<ScrollSelectStripProtocol> stripDelegate;

//@property (nonatomic) BOOL reachToBounds;
@property (nonatomic) CGFloat offsetDelta;
@property (nonatomic) CGFloat scrollRate;
@property (nonatomic) CGFloat offsetAccumulator;


- (BOOL) didReachBottomBounds;
- (BOOL) didReachTopBounds;

- (void)resetContentOffsetIfNeeded;

@end
