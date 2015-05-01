//
//  DPScrollSelectView.m
//  BiuBiu
//
//  Created by haowenliang on 15/1/3.
//  Copyright (c) 2015年 dpsoft. All rights reserved.
//

#import "DPScrollSelectView.h"
#import <QuartzCore/QuartzCore.h>
#import <objc/runtime.h>
#import "DPStreamViewCell.h"

#define STREAM_VIEW_CELL_PADDING (100)
#define STREAM_VIEW_ROW_PADDING (20)
#define STREAM_VIEW_DELAY_TIME (2)

#define STREAM_VIEW_POINT_CHANGE (0.5)

@interface DPScrollSelectView ()

-(void) populateStrips;

-(NSInteger) indexOfStrip:(DPScrollSelectStrip*) strip;

-(void) synchronizeContentOffsetsWithDriver:(DPScrollSelectStrip*) drivingStrip;

-(void) updateDriverOffset;

-(NSArray*) stripsWithoutStrip:(DPScrollSelectStrip*) strip;

@property (nonatomic) BOOL shouldResumeAnimating;
@property (nonatomic,strong) NSArray* passengers;

@property (nonatomic,strong) DPScrollSelectStrip* driver;

@property (nonatomic, strong) NSTimer* animationTimer;

-(BOOL) animating;

@end

@implementation DPScrollSelectView

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {

    }
    return self;
}

- (void)setDatasource:(id<DPScrollSelectViewDatasource>)datasource
{
    _datasource = datasource;
    [self populateStrips];
}

- (void)reloadData
{
    for (DPScrollSelectStrip* strip in _strips) {
        [strip reloadData];
    }
}

- (void)dealloc
{
    [self stopScrollingDriver];
    
    
}

-(BOOL) animating
{
    return  (BOOL)self.animationTimer;
}

-(NSArray*) passengers
{
    return [self stripsWithoutStrip:self.driver];
}

-(NSArray*) stripsWithoutStrip:(DPScrollSelectStrip*) strip
{
    return [_strips filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings) {
        return evaluatedObject != strip;
    }]];
}

-(void) layoutSubviews {
    [super layoutSubviews];
    
    [self populateStrips];
    [self startScrollingDriver];

}

-(void) synchronizeStripsForMainDriver
{
    BOOL allReachToBounds = YES;
    for (DPScrollSelectStrip* strip in _strips) {
        if (NO == [strip didReachBottomBounds]) {
            allReachToBounds = NO;
            break;
        }
    }
    if (allReachToBounds) {
        [self stopScrollingDriver];
        for (DPScrollSelectStrip* strip in _strips) {
            [strip setContentOffset:CGPointMake(-self.width, 0)];
        }
        [self startScrollingDriver];
        return;
    }
    [self synchronizeContentOffsetsWithDriver: self.driver];
}

-(void) populateStrips
{
    NSInteger numberOfStrips = [self numberOfStripsInScrollSelect];
    if (_strips && [_strips count] == numberOfStrips) {
        return;
    }
    
    NSMutableArray* strips = [[NSMutableArray alloc] initWithCapacity:numberOfStrips];
    CGFloat stripWidth = self.width;
    CGFloat stripHeight = self.height/numberOfStrips ;
    
    for (NSInteger count = 0; count < numberOfStrips;  count++) {
        //Make the frame the entire height and the width the width of the superview divided by number of strips
        CGRect stripFrame = CGRectMake(0, stripHeight* count, stripWidth, stripHeight);
        DPScrollSelectStrip* strip = [[DPScrollSelectStrip alloc] initWithFrame:stripFrame];
        [strip setBackgroundColor:[UIColor clearColor]];
        strip.decelerationRate = 0;
        [strip setDelegate:self];
        [strip setStripDelegate:self];
        [strip setDpDelegate:self];
        strip.cellPadding = STREAM_VIEW_CELL_PADDING;
        strip.rowPadding = STREAM_VIEW_ROW_PADDING;
        
        [strip setContentOffset:CGPointMake(-self.width, 0)];
        [strip setScrollRate:[self scrollRateForStripAtIndex:count]];

        [strips addObject: strip];
        
        if (![[self subviews] containsObject: strip]) {
            [self addSubview:strip];
        }
    }
    
    self.strips = strips;
}

#pragma mark - Driver & Passenger animation implementation
-(void) synchronizeContentOffsetsWithDriver:(DPScrollSelectStrip*) drivingStrip
{
    if (drivingStrip.offsetDelta == 0)
        return;

    for (DPScrollSelectStrip* currentStrip in self.passengers)
    {
        CGPoint currentOffset = currentStrip.contentOffset;
        CGFloat relativeScrollRate = currentStrip.scrollRate / drivingStrip.scrollRate;
        currentOffset.x += drivingStrip.offsetDelta* relativeScrollRate;
        
        //Only move passenger when offset has accumulated to the min pixel movement threshold (0.5)
        currentStrip.offsetAccumulator += fabs(drivingStrip.offsetDelta * relativeScrollRate);
        if (currentStrip.offsetAccumulator >= STREAM_VIEW_POINT_CHANGE)
        {
            [currentStrip setContentOffset: currentOffset];
            currentStrip.offsetAccumulator = 0;
        }
    }
}

-(void) startScrollingDriver
{
    self.driver = self.strips[0];
    
    if (self.animating) {
        return;
    }
    
    CGFloat animationDuration = STREAM_VIEW_POINT_CHANGE / self.driver.scrollRate;
    
    self.animationTimer = [NSTimer scheduledTimerWithTimeInterval: animationDuration
                                                           target:self
                                                         selector:@selector(updateDriverAnimation)
                                                         userInfo:nil
                                                          repeats:YES];
    [self.animationTimer fire];
}

-(void) updateDriverAnimation
{
    [self updateDriverOffset];
}

-(void) updateDriverOffset
{
    CGFloat pointChange = STREAM_VIEW_POINT_CHANGE;
    CGPoint newOffset = self.driver.contentOffset;
    newOffset.x = newOffset.x + pointChange;
    [self.driver setContentOffset: newOffset];
}

- (void)stopScrollingDriver
{
    if (!self.animating) {
        return;
    }
    [self.driver.layer removeAllAnimations];
    [self.animationTimer invalidate];
    self.animationTimer = nil;
}

#pragma mark - UIScrollViewDelegate implementation
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    //Stop animating driver
    [self setDriver: (DPScrollSelectStrip*) scrollView];
    [self stopScrollingDriver];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    //Start animating driver
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(STREAM_VIEW_DELAY_TIME * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self startScrollingDriver];
    });
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (!decelerate) {
        //Start animating driver
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(STREAM_VIEW_DELAY_TIME * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self startScrollingDriver];
        });
    }
}

#pragma mark - Datasource Implementation
-(NSInteger) numberOfStripsInScrollSelect
{
    if (_datasource && [_datasource respondsToSelector:@selector(numberOfStripsInScrollSelect)])
    {
        return [_datasource numberOfStripsInScrollSelect];
    }
    
    return 1;
}

- (DPScrollSelectStrip*)StripAtIndex:(NSInteger)index
{
    return [_strips objectAtIndex:index];
}

- (CGFloat)scrollRateForStripAtIndex:(NSInteger)index
{
    if ([_datasource respondsToSelector:@selector(scrollRateForStripAtIndex:)]) {
        return [_datasource scrollRateForStripAtIndex:index];
    }
    return 10.0;
}

-(NSInteger)indexOfStrip:(DPScrollSelectStrip *)strip
{
    return [_strips indexOfObject: strip];
}

#pragma mark -Scroll Select Delegate
- (void) willUpdateContentOffsetForStrip:(DPScrollSelectStrip *)strip
{
    if (strip == _driver)
    {
        
    }
}

- (void) didUpdateContentOffsetForStrip:(DPScrollSelectStrip *)strip
{
    if (strip == _driver)
    {
        [self synchronizeStripsForMainDriver];
    }
}

#pragma mark -Stream View Delegate

- (NSInteger)numberOfCellsInStreamView:(DPStreamView *)streamView
{
    NSInteger stripIndex = [self indexOfStrip: (DPScrollSelectStrip*)streamView];
    
    return [_datasource scrollSelect: self
          numberOfRowsInStripAtIndex:stripIndex];
}
//
//- (NSInteger)numberOfRowsInStreamView:(DPStreamView *)streamView
//{
//    NSInteger stripIndex = [self indexOfStrip: (DPScrollSelectStrip*)streamView];
//    
//    if ([_datasource respondsToSelector:@selector(scrollSelect:numberOfSectionsInStripAtIndex:)]) {
//        return [_datasource scrollSelect:self numberOfSectionsInStripAtIndex:stripIndex];
//    }
//    return 1;
//}

- (UIView *)streamView:(DPStreamView *)streamView cellAtIndex:(NSInteger)index
{
    NSInteger stripIndex = [self indexOfStrip: (DPScrollSelectStrip*)streamView];
    NSIndexPath* indexPath = [NSIndexPath indexPathForRow:index inSection:stripIndex];
    UIView* cellView = [_datasource scrollSelect:self cellForRowAtIndexPath:indexPath];
    
    if(nil == cellView){
        cellView = [[DPStreamViewCell alloc] initWithFrame:CGRectZero];
    }
    return cellView;
}

- (CGFloat)streamView:(DPStreamView *)streamView widthForCellAtIndex:(NSInteger)index
{
    NSInteger stripIndex = [self indexOfStrip: (DPScrollSelectStrip*)streamView];
    NSIndexPath* indexPath = [NSIndexPath indexPathForRow:index inSection:stripIndex];
    
    return [_datasource scrollSelect:self widthForRowAtIndexPath:indexPath];
}

- (void)streamView:(DPStreamView *)streamView didSelectedCellAtIndex:(NSInteger)index
{
    DPTrace("did select cell at index %zd",index);
    
    NSInteger stripIndex = [self indexOfStrip: (DPScrollSelectStrip*)streamView];
    NSIndexPath* indexPath = [NSIndexPath indexPathForRow:index inSection:stripIndex];
    if (_delegate && [_delegate respondsToSelector:@selector(scrollSelect:didSelectCellAtIndexPath:)]) {
        [_delegate scrollSelect:self didSelectCellAtIndexPath:indexPath];
    }
}


@end
