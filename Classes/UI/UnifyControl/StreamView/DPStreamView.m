//
//  DPStreamView.m
//  StreamView
//
//  Created by haowenliang on 14/12/17.
//  Copyright (c) 2014年 dp-soft. All rights reserved.
//

#import "DPStreamView.h"

#define DEFUATL_STREAM_VIEW_MARGIN_X (30)

@interface DPStreamView ()

- (void)setup;
- (NSSet *)getVisibleCellInfo;
- (void)layoutCellWithCellInfo:(DPStreamCellInfo *)info;

@property (nonatomic) NSSet *visibleCellInfo;
@property (nonatomic) NSMutableDictionary *cellCache;

@end

@implementation DPStreamView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        [self setup];
    }
    return self;
}

- (CGFloat)maxOffsetX
{
    //保证最后一个视图居中
    CGFloat maxWidth = _contentView.width;
    DPStreamCellInfo* cellInfo = [_infoForCells lastObject];
    CGFloat lastWidth = CGRectGetWidth(cellInfo.frame);
    maxWidth -= DEFUATL_STREAM_VIEW_MARGIN_X;
    maxWidth -= lastWidth/2;
    maxWidth -= SCREEN_WIDTH/2;
    return maxWidth;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    if (_infoForCells.count)
    {
        NSInteger numberOfRows = 1;
        if (_dpDelegate && [_dpDelegate respondsToSelector:@selector(numberOfRowsInStreamView:)]) {
            numberOfRows = [_dpDelegate numberOfRowsInStreamView:self];
        }
        CGFloat destHeight = (CGRectGetHeight(self.bounds) - (numberOfRows + 1) * self.rowPadding) / numberOfRows;
        if (ABS(destHeight - _rowHeight) < 0.01f)
        {
            return;
        }
    }
    [self reloadData];
}

- (void)reloadData
{
    [_cellWidthByIndex removeAllObjects];
    [_cellWidthByRow removeAllObjects];
    [_rectForCells removeAllObjects];
    [_infoForCells removeAllObjects];
    
    [_cellCache removeAllObjects];
    
    for (DPStreamCellInfo *cellInfo in _visibleCellInfo) {
        [cellInfo.cell removeFromSuperview];
    }
    
    //We could not simply remove headerView/footerView from their parentView:we need to persist their state.
    //For example, if an UITextView is a subview of headerView/footerView, remove them from parentView will make the keyboard hide.
    //headerView
    if ([_dpDelegate respondsToSelector:@selector(headerForStreamView:)])
    {
        UIView *tempHeaderView = [_dpDelegate headerForStreamView:self];
        if (tempHeaderView) {
            CGRect f = tempHeaderView.frame;
            f.origin = CGPointMake(_cellPadding,0);
            f.size.height = self.bounds.size.height - _rowPadding * 2;
            tempHeaderView.frame = f;
            
            if (_headerView != tempHeaderView) {
                [_headerView removeFromSuperview];
                _headerView = tempHeaderView;
                [_contentView addSubview:_headerView];
            }
        }
        else {
            [_headerView removeFromSuperview];
            _headerView = nil;
        }
    } else {
        [_headerView removeFromSuperview];
        _headerView = nil;
    }
    //footer view
    if ([_dpDelegate respondsToSelector:@selector(footerForStreamView:)]) {
        UIView *tempFooterView = [_dpDelegate footerForStreamView:self];
        if (tempFooterView) {
            if (_footerView != tempFooterView) {
                _footerView = tempFooterView;
                [_contentView addSubview:_footerView];
            }
        }
        else {
            [_footerView removeFromSuperview];
            _footerView = nil;
        }
        
    } else {
        [_footerView removeFromSuperview];
        _footerView = nil;
    }
    
    
    // calculate height for all cells
    NSInteger numberOfRows = 1;
    if (_dpDelegate && [_dpDelegate respondsToSelector:@selector(numberOfRowsInStreamView:)]) {
        numberOfRows = [_dpDelegate numberOfRowsInStreamView:self];
    }
    _rowHeight = (self.bounds.size.height - (numberOfRows + 1) * self.rowPadding) / numberOfRows;
    
    if (numberOfRows < 1)
        [NSException raise:NSInvalidArgumentException format:@"The number of columns must be equal or greater than 1!"];

    NSInteger numberOfCells = [_dpDelegate numberOfCellsInStreamView:self];
    
    CGFloat *rowWidths = calloc(numberOfRows, sizeof(CGFloat));
    CGFloat *cellYPoint = calloc(numberOfRows, sizeof(CGFloat));
    
    if (rowWidths == NULL || cellYPoint == NULL) {
        [NSException raise:NSMallocException format:@"Allocating memory failed."];
    }
    
    CGFloat cellWidth = _headerView ? _headerView.bounds.size.width + DEFUATL_STREAM_VIEW_MARGIN_X : DEFUATL_STREAM_VIEW_MARGIN_X;
    
    for (int i = 0; i < numberOfRows; i++)
    {
        [_cellWidthByRow addObject:[NSMutableArray arrayWithCapacity:1]];
        [_rectForCells addObject:[NSMutableArray arrayWithCapacity:1]];
        
        cellYPoint[i] = (i == 0 ? _rowPadding : cellYPoint[i - 1] + _rowHeight + _rowPadding);
        rowWidths[i] = (i+1)*cellWidth;
    }
    
    //
    for (int i = 0; i < numberOfCells; i++) {
        CGFloat width = [_dpDelegate streamView:self widthForCellAtIndex:i];
        [_cellWidthByIndex addObject:@(width)];
        
        NSUInteger shortestRow = 0;
        for (int j = 1; j < numberOfRows; j++) {
            if (rowWidths[j] < rowWidths[shortestRow] - 0.5f)
                shortestRow = j;
        }
        
        NSMutableArray *cellWidthInRow = _cellWidthByRow[shortestRow];
        [cellWidthInRow addObject:@(width)];
        
        DPStreamCellInfo *info = [DPStreamCellInfo new];
        CGFloat infoX = MAX(DEFUATL_STREAM_VIEW_MARGIN_X, rowWidths[shortestRow]) ;//+ _cellPadding;

        CGFloat infoY = cellYPoint[shortestRow];
        info.frame = CGRectMake(infoX, infoY, width, _rowHeight);
        info.index = i;
        
        NSMutableArray *rectsForCellInRow = _rectForCells[shortestRow];
        [rectsForCellInRow addObject:info];
        
        [_infoForCells addObject:info];
    
        rowWidths[shortestRow] += width + _cellPadding;
    }
    
    // determine the visible cells' range
    _visibleCellInfo = [self getVisibleCellInfo];
    
    // draw the visible cells
    for (DPStreamCellInfo *info in _visibleCellInfo) {
        [self layoutCellWithCellInfo:info];
    }
    
    //计算最大的宽度，设置footerView的frame，以及scroll view的contentsize
    CGFloat maxWidth = 0;
    for (int i = 0; i < numberOfRows; i++) {
        if (rowWidths[i] > maxWidth)
            maxWidth = rowWidths[i];
    }

    if (_footerView) {
        CGRect f = _footerView.frame;
        f.origin = CGPointMake(maxWidth,_rowPadding);
        f.size.height = self.bounds.size.height - _rowPadding * 2;
        _footerView.frame = f;
        
        maxWidth += _footerView.bounds.size.width + DEFUATL_STREAM_VIEW_MARGIN_X;
    }else{
        maxWidth -= _cellPadding;
        maxWidth += DEFUATL_STREAM_VIEW_MARGIN_X;
    }
    CGPoint lastOffset = self.contentOffset;
    self.contentSize = CGSizeMake(maxWidth,0.0);
    [self setContentOffset:lastOffset];
    
    CGRect f = _contentView.frame;
    f.origin = CGPointZero;
    f.size.width = maxWidth;
    f.size.height = self.bounds.size.height;
    _contentView.frame = f;
    
    free(rowWidths);
    free(cellYPoint);
}


- (id<DPResusableCell>)dequeueReusableCellWithIdentifier:(NSString *)identifier
{
    NSMutableArray *cellArray = _cellCache[identifier];
    id<DPResusableCell> cell = nil;
    if ([cellArray count] > 0) {
        cell = [cellArray lastObject];
        [cellArray removeLastObject];
    }
    
    return cell;
}

- (CGFloat)rowHeight
{
    NSInteger numberOfRows = 1;
    if (_dpDelegate && [_dpDelegate respondsToSelector:@selector(numberOfRowsInStreamView:)]) {
        numberOfRows = [_dpDelegate numberOfRowsInStreamView:self];
    }
    return (CGRectGetHeight(self.bounds) - (numberOfRows + 1) * self.rowPadding) / numberOfRows;
}

#pragma mark - Private Methods

- (NSSet *)getVisibleCellInfo
{
    CGFloat offsetTop = self.contentOffset.y;
    CGFloat offsetBottom = offsetTop + self.bounds.size.height;
    NSMutableSet *ret = [NSMutableSet setWithCapacity:10];
    
    for (NSMutableArray *rectsForCellsInCol in _rectForCells) {
        for (NSInteger i = 0, c = [rectsForCellsInCol count]; i < c; i++) {
            DPStreamCellInfo *info = rectsForCellsInCol[i];
            CGFloat top = info.frame.origin.y;
            CGFloat bottom = CGRectGetMaxY(info.frame);
            
            if (bottom < offsetTop) { // The cell is above the current view rect
                continue;
            } else if (top > offsetBottom) { // the cell is below the current view rect. stop searching this column
                break;
            } else {
                [ret addObject:info];
            }
            
        }
    }
    
    return ret;
}

- (void)layoutCellWithCellInfo:(DPStreamCellInfo *)info
{
    UIView<DPResusableCell> *cell = [_dpDelegate streamView:self cellAtIndex:info.index];
    cell.frame = info.frame;
    info.cell = cell;
    
    if ([_dpDelegate respondsToSelector:@selector(streamView:willDisplayCell:forIndex:)]) {
        [_dpDelegate streamView:self willDisplayCell:cell forIndex:info.index];
    }
    [_contentView addSubview:cell];
}

- (void)setup
{
    self.showsHorizontalScrollIndicator = NO;
    self.showsVerticalScrollIndicator = NO;
    _delegateObj = [DPStreamViewUIScrollViewDelegate new];
    _delegateObj.streamView = self;
    [super setDelegate:_delegateObj];
    
    //cellHeightsByIndex = [[NSMutableArray alloc] initWithCapacity:30];
    _cellWidthByIndex = [[NSMutableArray alloc] initWithCapacity:30];
    //cellHeightsByColumn = [[NSMutableArray alloc] initWithCapacity:5];
    _cellWidthByRow = [[NSMutableArray alloc] initWithCapacity:5];
    //rectsForCells = [[NSMutableArray alloc] initWithCapacity:5];
    _rectForCells = [[NSMutableArray alloc] initWithCapacity:1];
    //infoForCells = [[NSMutableArray alloc] initWithCapacity:30];
    _infoForCells = [[NSMutableArray alloc] initWithCapacity:30];
    
    _cellCache = [[NSMutableDictionary alloc] initWithCapacity:20];
    _contentView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.contentSize.width, self.contentSize.height)];
    _contentView.autoresizesSubviews = NO;
    [self addSubview:_contentView];
}

- (void)scrollToCellAtIndex:(NSUInteger)index atScrollPosition:(DPStreamViewScrollPosition)scrollPosition animated:(BOOL)animated
{
    if (scrollPosition == DPStreamViewScrollPositionNone) {
        return;
    }
    
    DPStreamCellInfo *cellInfo = _infoForCells[index];
    CGFloat cellPositionX = cellInfo.frame.origin.x;
    CGFloat cellWidth = cellInfo.frame.size.width;
    CGFloat viewWidth = self.frame.size.width;
    CGFloat targetOffsetX = self.contentOffset.x;
    CGFloat minOffsetX = 0.0f;
    CGFloat maxOffsetX = self.contentSize.width - self.frame.size.width;
    
    switch (scrollPosition) {
        case DPStreamViewScrollPositionNone:
            break;
        case DPStreamViewScrollPositionTop:
            targetOffsetX = MIN(maxOffsetX, MAX(minOffsetX, cellPositionX));
            break;
        case DPStreamViewScrollPositionMiddle:
            targetOffsetX = MIN(maxOffsetX, MAX(minOffsetX, cellPositionX - (viewWidth - cellWidth) * 0.5));
            break;
        case DPStreamViewScrollPositionBottom:
            targetOffsetX = MIN(maxOffsetX, MAX(minOffsetX, cellPositionX - (viewWidth - cellWidth)));
            break;
    }
    [self setContentOffset:CGPointMake(targetOffsetX, 0.0f) animated:animated];
}

@end


#pragma mark -scroll view delegate
@implementation DPStreamViewUIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    NSSet *newVisibleCellInfo = [_streamView getVisibleCellInfo];
    NSSet *visibleCellInfo = _streamView.visibleCellInfo;
    NSMutableDictionary *cellCache = _streamView.cellCache;
    
    for (DPStreamCellInfo *info in visibleCellInfo) {
        if (![newVisibleCellInfo containsObject:info]) {
            // info.cell.retainCount: 1
            NSString *cellID = info.cell.reuseIdentifier;
            NSMutableArray *cellArray = cellCache[cellID];
            if (cellArray == nil) {
                cellArray = [NSMutableArray arrayWithCapacity:10];
                cellCache[cellID] = cellArray;
            }
            
            [cellArray addObject:info.cell];
            // info.cell.retainCount: 2
            [info.cell removeFromSuperview];
            // info.cell.retainCount: 1
        }
    }
    
    for (DPStreamCellInfo *info in newVisibleCellInfo) {
        if (![visibleCellInfo containsObject:info]) {
            [_streamView layoutCellWithCellInfo:info];
        }
    }
    
    _streamView.visibleCellInfo = newVisibleCellInfo;
    
    if ([_streamView.dpDelegate respondsToSelector:@selector(scrollViewDidScroll:)])
    {
        [_streamView.dpDelegate scrollViewDidScroll:_streamView];
    }
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView
{
    if ([_streamView.dpDelegate respondsToSelector:@selector(scrollViewDidZoom:)])
    {
        [_streamView.dpDelegate scrollViewDidZoom:_streamView];
    }
    
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    if ([_streamView.dpDelegate respondsToSelector:@selector(scrollViewWillBeginDragging:)]){
        [_streamView.dpDelegate scrollViewWillBeginDragging:_streamView];
    }
    
}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset
{
    if ([_streamView.dpDelegate respondsToSelector:@selector(scrollViewWillEndDragging:withVelocity:targetContentOffset:)])
    {
        [_streamView.dpDelegate scrollViewWillEndDragging:_streamView withVelocity:velocity targetContentOffset:targetContentOffset];
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if ([_streamView.dpDelegate respondsToSelector:@selector(scrollViewDidEndDragging:willDecelerate:)])
    {
        [_streamView.dpDelegate scrollViewDidEndDragging:_streamView willDecelerate:decelerate];
    }
}

- (void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView
{
    if ([_streamView.dpDelegate respondsToSelector:@selector(scrollViewWillBeginDecelerating:)])
    {
        [_streamView.dpDelegate scrollViewWillBeginDecelerating:_streamView];
    }
    
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if ([_streamView.dpDelegate respondsToSelector:@selector(scrollViewDidEndDecelerating:)]){
        [_streamView.dpDelegate scrollViewDidEndDecelerating:_streamView];
    }
    
}


- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{
    if ([_streamView.dpDelegate respondsToSelector:@selector(scrollViewDidEndScrollingAnimation:)]){
        [_streamView.dpDelegate scrollViewDidEndScrollingAnimation:_streamView];
    }
    
}



- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    if ([_streamView.dpDelegate respondsToSelector:@selector(viewForZoomingInScrollView:)]){
        return [_streamView.dpDelegate viewForZoomingInScrollView:_streamView];
    }else{
        return nil;
    }
}

- (void)scrollViewWillBeginZooming:(UIScrollView *)scrollView withView:(UIView *)view
{
    if ([_streamView.dpDelegate respondsToSelector:@selector(scrollViewWillBeginZooming:withView:)])
    {
        [_streamView.dpDelegate scrollViewWillBeginZooming:scrollView withView:view];
    }
    
}


- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(CGFloat)scale
{
    if ([_streamView.dpDelegate respondsToSelector:@selector(scrollViewDidEndZooming:withView:atScale:)])
    {
        [_streamView.dpDelegate scrollViewDidEndZooming:_streamView withView:view atScale:scale];
    }
    
}


- (BOOL)scrollViewShouldScrollToTop:(UIScrollView *)scrollView
{
    if ([_streamView.dpDelegate respondsToSelector:@selector(scrollViewShouldScrollToTop:)])
        return [_streamView.dpDelegate scrollViewShouldScrollToTop:_streamView];
    else
        return YES;
}

- (void)scrollViewDidScrollToTop:(UIScrollView *)scrollView
{
    if ([_streamView.dpDelegate respondsToSelector:@selector(scrollViewDidScrollToTop:)])
        [_streamView.dpDelegate scrollViewDidScrollToTop:_streamView];
    
}

@end