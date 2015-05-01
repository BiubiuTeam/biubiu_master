//
//  DPScrollSelectStrip.m
//  BiuBiu
//
//  Created by haowenliang on 15/1/3.
//  Copyright (c) 2015年 dpsoft. All rights reserved.
//

#import "DPScrollSelectStrip.h"

@interface DPScrollSelectStrip ()
{
    BOOL isResettingContent;
}

- (void) resetContentOffsetIfNeeded;


@end

@implementation DPScrollSelectStrip

- (BOOL) didReachTopBounds
{
    return self.contentOffset.x <= 0.0;
}

- (BOOL) didReachBottomBounds
{
    if (self.contentSize.width < self.width) {
        return NO;
    }
    return self.contentOffset.x >= self.contentSize.width;
}

- (void)resetContentOffsetIfNeeded
{
//    CGPoint contentOffset  = self.contentOffset;
    
    //check the top condition
    //check if the scroll view reached its top.. if so.. move it to center.. remember center is the start of the data repeating for 2nd time.

    if([self didReachTopBounds])
    {
        isResettingContent = YES;

//        [self setContentOffset: contentOffset];
    }else if([self didReachBottomBounds])
    {
        isResettingContent = YES;
        
//        [self setContentOffset: contentOffset];
    }
    isResettingContent = NO;
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
    if (_stripDelegate && [_stripDelegate respondsToSelector:@selector(willUpdateContentOffsetForStrip:)] && !isResettingContent) {
        [_stripDelegate willUpdateContentOffsetForStrip:self];
    }
    if (!isResettingContent) {
        self.offsetDelta = contentOffset.x - self.contentOffset.x;
    }
    
    [super setContentOffset: contentOffset];
    
    if (_stripDelegate && [_stripDelegate respondsToSelector:@selector(didUpdateContentOffsetForStrip:)] && !isResettingContent) {
        [_stripDelegate didUpdateContentOffsetForStrip:self];
    }
}

@end
