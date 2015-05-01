//
//  DPMutableScrollView.m
//  BiuBiu
//
//  Created by haowenliang on 15/1/22.
//  Copyright (c) 2015年 dpsoft. All rights reserved.
//

#import "DPMutableScrollView.h"
#import "DPLineStreamView.h"
#import <QuartzCore/QuartzCore.h>
#import <objc/runtime.h>
#import "DPStreamViewCell.h"

#define STREAM_VIEW_CELL_PADDING (20)
#define STREAM_VIEW_ROW_PADDING (5)

#define STREAM_VIEW_DELAY_TIME (2)
#define STREAM_VIEW_POINT_CHANGE (0.5)

@interface DPMutableScrollView ()

-(void) populateStreamLines;

-(NSInteger) indexOfStreamLine:(DPLineStreamView*)line;

-(void) synchronizeContentOffsetsWithDriver:(DPLineStreamView*)drivingLine;

-(void) updateDriverOffset;

-(NSArray*) streamLinesWithoutLine:(DPLineStreamView*)line;

@property (nonatomic) BOOL shouldResumeAnimating;
@property (nonatomic,strong) NSArray* passengers;

@property (nonatomic,strong) DPLineStreamView* driver;

@property (nonatomic, strong) NSTimer* animationTimer;

-(BOOL) animating;

@end

@implementation DPMutableScrollView

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        
    }
    return self;
}

- (void)resetMutableScrollView
{
    _datasource = nil;
    [_streamLines makeObjectsPerformSelector:@selector(removeFromSuperview)];
    _streamLines = nil;
}

- (void)setDatasource:(id<DPMutableScrollViewDatasource>)datasource
{
    _datasource = datasource;
    [self populateStreamLines];
}

- (void)reloadData
{
    [self populateStreamLines];
    for (DPLineStreamView* line in _streamLines) {
        [line reloadData];
    }
}

- (void)dealloc
{
    _streamLines = nil;
    _delegate = nil;
    _datasource = nil;
    [self stopScrollingDriver];
}

- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
}

- (void)enableUserInteraction:(BOOL)userInteraction
{
    for (DPLineStreamView* line in _streamLines) {
        line.userInteractionEnabled = userInteraction;
    }
}

-(BOOL) animating
{
    return (BOOL)self.animationTimer;
}

-(NSArray*) passengers
{
    return [self streamLinesWithoutLine:self.driver];
}

-(NSArray*)streamLinesWithoutLine:(DPLineStreamView *)line
{
    return [_streamLines filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings) {
        return evaluatedObject != line;
    }]];
}

-(void) layoutSubviews {
    [super layoutSubviews];
    [self populateStreamLines];
}

-(void) synchronizeStripsForMainDriver
{
    [self synchronizeContentOffsetsWithDriver:self.driver];
}

- (void)populateStreamLines
{
    NSInteger numberOfStrips = [self numberOfStreamLinesInMutableScrollView];
    if (_streamLines && [_streamLines count] == numberOfStrips) {
//        CGFloat stripWidth = self.width;
//        CGFloat stripHeight = self.height/numberOfStrips;
//        for (DPLineStreamView* strip in _streamLines) {
//            [strip setSize:CGSizeMake(stripWidth, stripHeight)];
//        }
        return;
    }
    
    NSMutableArray* streamArray = [[NSMutableArray alloc] initWithCapacity:numberOfStrips];
    
    CGFloat stripWidth = self.width;
    CGFloat stripHeight = self.height/numberOfStrips ;
    
    for (NSInteger count = 0; count < numberOfStrips;  count++) {
        //Make the frame the entire height and the width the width of the superview divided by number of strips
        CGRect stripFrame = CGRectMake(0, stripHeight* count, stripWidth, stripHeight);
        
        DPLineStreamView* strip = [[DPLineStreamView alloc] initWithFrame:stripFrame];
        [strip setBackgroundColor:[UIColor clearColor]];
        strip.decelerationRate = 0;
        strip.cellPadding = STREAM_VIEW_CELL_PADDING;
        strip.rowPadding = STREAM_VIEW_ROW_PADDING;
        [strip setContentOffset:CGPointMake(-self.width, 0)];
        [strip setScrollRate:[self scrollRateForStreamLineAtIndex:count]];
        
        [strip setDelegate:self];
        [strip setLayoutDelegate:self];
        [strip setDpDelegate:self];
        
        [streamArray addObject: strip];
        
        if (![[self subviews] containsObject: strip]) {
            [self addSubview:strip];
        }
    }
    
    self.streamLines = streamArray;
}

#pragma mark - Driver & Passenger animation implementation
-(void) synchronizeContentOffsetsWithDriver:(DPLineStreamView*)drivingLine
{
    if (drivingLine.offsetDelta == 0)
        return;
    NSArray* passengers = self.passengers;
    for (DPLineStreamView* currentLine in passengers)
    {
        CGPoint currentOffset = currentLine.contentOffset;
        CGFloat relativeScrollRate = currentLine.scrollRate / drivingLine.scrollRate;
        currentOffset.x += drivingLine.offsetDelta* relativeScrollRate;
        
        //Only move passenger when offset has accumulated to the min pixel movement threshold (0.5)
        currentLine.offsetAccumulator += fabs(drivingLine.offsetDelta * relativeScrollRate);
        if (currentLine.offsetAccumulator >= STREAM_VIEW_POINT_CHANGE)
        {
            [currentLine setContentOffset: currentOffset];
            currentLine.offsetAccumulator = 0;
        }
    }
}

-(void) startScrollingDriver
{
    self.driver = self.streamLines[0];
    
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
    [self setDriver: (DPLineStreamView*) scrollView];
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
-(NSInteger)numberOfStreamLinesInMutableScrollView
{
    if (_datasource && [_datasource respondsToSelector:@selector(numberOfStreamLinesInMutableScrollView)])
    {
        return [_datasource numberOfStreamLinesInMutableScrollView];
    }
    
    return 1;
}

- (DPLineStreamView*)streamLineAtIndex:(NSInteger)index
{
    if (index < [_streamLines count]) {
        return [_streamLines objectAtIndex:index];
    }
    return nil;
}

- (CGFloat)scrollRateForStreamLineAtIndex:(NSInteger)index
{
    if ([_datasource respondsToSelector:@selector(scrollRateForStreamLineAtIndex:)]) {
        return [_datasource scrollRateForStreamLineAtIndex:index];
    }
    return 10.0;
}

-(NSInteger)indexOfStreamLine:(DPLineStreamView *)line
{
    return [_streamLines indexOfObject:line];
}

#pragma mark -Scroll Select Delegate
- (void) willUpdateContentOffsetForLine:(DPLineStreamView *)line
{
    if (line == _driver)
    {
        
    }
}

- (void) didUpdateContentOffsetForLine:(DPLineStreamView *)line
{
    if (line == _driver)
    {
        [self synchronizeStripsForMainDriver];
    }
}

#pragma mark -Stream View Delegate

- (NSInteger)numberOfCellsInStreamView:(DPStreamView *)streamView
{
    NSInteger lineIndex = [self indexOfStreamLine:(DPLineStreamView*)streamView];
    return [_datasource mutableScrollView:self numberOfRowsInStreamLineAtIndex:lineIndex];
}

- (UIView *)streamView:(DPStreamView *)streamView cellAtIndex:(NSInteger)index
{
    NSInteger stripIndex = [self indexOfStreamLine:(DPLineStreamView*)streamView];
    NSIndexPath* indexPath = [NSIndexPath indexPathForRow:index inSection:stripIndex];
    UIView* cellView = [_datasource mutableScrollView:self cellForRowAtIndexPath:indexPath];
    
    if(nil == cellView){
        cellView = [[DPStreamViewCell alloc] initWithFrame:CGRectZero];
    }
    return cellView;
}

- (CGFloat)streamView:(DPStreamView *)streamView widthForCellAtIndex:(NSInteger)index
{
    NSInteger stripIndex = [self indexOfStreamLine:(DPLineStreamView*)streamView];
    NSIndexPath* indexPath = [NSIndexPath indexPathForRow:index inSection:stripIndex];
    
    return [_datasource mutableScrollView:self widthForRowAtIndexPath:indexPath];
}

- (void)streamView:(DPStreamView *)streamView didSelectedCellAtIndex:(NSInteger)index
{
    DPTrace("did select cell at index %zd",index);
    
    NSInteger stripIndex = [self indexOfStreamLine:(DPLineStreamView*)streamView];
    NSIndexPath* indexPath = [NSIndexPath indexPathForRow:index inSection:stripIndex];
    if (_delegate && [_delegate respondsToSelector:@selector(mutableScrollView:didSelectCellAtIndexPath:)]) {
        [_delegate mutableScrollView:self didSelectCellAtIndexPath:indexPath];
    }
}

@end
