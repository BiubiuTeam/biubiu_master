//
//  DPLineStreamView.h
//  BiuBiu
//
//  Created by haowenliang on 15/1/22.
//  Copyright (c) 2015年 dpsoft. All rights reserved.
//

#import "DPStreamView.h"

@class DPLineStreamView;
@protocol DPLineStreamViewProtocol <DPStreamViewDelegate>

@optional
- (void) willUpdateContentOffsetForLine:(DPLineStreamView*)line;

- (void) didUpdateContentOffsetForLine:(DPLineStreamView*)line;

@end

@interface DPLineStreamView : DPStreamView

@property (nonatomic, assign) id<DPLineStreamViewProtocol> layoutDelegate;

@property (nonatomic) CGFloat offsetDelta;
@property (nonatomic) CGFloat scrollRate;
@property (nonatomic) CGFloat offsetAccumulator;

- (void)resetContentOffsetIfNeeded;
@end
