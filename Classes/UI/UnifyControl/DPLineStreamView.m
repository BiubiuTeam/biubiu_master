//
//  DPLineStreamView.m
//  BiuBiu
//
//  Created by haowenliang on 15/1/22.
//  Copyright (c) 2015年 dpsoft. All rights reserved.
//

#import "DPLineStreamView.h"

@implementation DPLineStreamView

- (void)dealloc
{
    DPTrace("stream line dealloc");
}

- (BOOL) didReachTopBounds
{
    if(self.contentOffset.x < 0.0)
        return YES;
    return NO;
}

- (BOOL) didReachBottomBounds
{
    if (self.contentSize.width < self.width) {
        return NO;
    }
    return self.contentOffset.x >= (CGFloat)self.contentSize.width/3.0;
}

- (void)resetContentOffsetIfNeeded
{
    CGPoint contentOffset  = self.contentOffset;
    //check the top condition
    //check if the scroll view reached its top.. if so.. move it to center.. remember center is the start of the data repeating for 2nd time.
    BOOL needToReset = NO;
    if([self didReachTopBounds])
    {
        contentOffset.x = 0.0;
        needToReset = YES;
        
    }else if([self didReachBottomBounds])
    {
        contentOffset.x = 0.0;
        needToReset = YES;
    }
    if (needToReset) {
        [self setContentOffset: contentOffset];
    }
}

//The heart of this app.
//this function iterates through all visible cells and lay them in a circular shape
#pragma mark Layout

- (void)layoutSubviews
{
    [super layoutSubviews];
    [self resetContentOffsetIfNeeded];
}

- (void)willMoveToWindow:(UIWindow *)newWindow {
    [super willMoveToWindow:newWindow];
    [self setShowsHorizontalScrollIndicator:NO];
    [self setShowsVerticalScrollIndicator:NO];
}

#pragma mark - Touch methods
-(void) setContentOffset:(CGPoint)contentOffset
{
    self.offsetDelta = contentOffset.x - self.contentOffset.x;
    [super setContentOffset: contentOffset];
    
    if (_layoutDelegate && [_layoutDelegate respondsToSelector:@selector(didUpdateContentOffsetForLine:)]) {
        [_layoutDelegate didUpdateContentOffsetForLine:self];
    }
}

@end
