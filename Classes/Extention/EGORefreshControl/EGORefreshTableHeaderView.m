//
//  EGORefreshTableHeaderView.m
//  Demo
//
//  Created by Devin Doty on 10/14/09October14.
//  Copyright 2009 enormego. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

#import "EGORefreshTableHeaderView.h"
#import "NSDateAdditions.h"

#define FLIP_ANIMATION_DURATION 0.18f


@interface EGORefreshTableHeaderView (Private)
- (void)setState:(EGOPullRefreshState)aState;
@end

@implementation EGORefreshTableHeaderView

@synthesize delegate=_delegate;


- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
		
		self.autoresizingMask = UIViewAutoresizingFlexibleWidth;
		self.backgroundColor = [UIColor clearColor];
        
		UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, frame.size.height - 30.0f, self.frame.size.width, 20.0f)];
		label.autoresizingMask = UIViewAutoresizingFlexibleWidth;
		label.font = [UIFont systemFontOfSize:12.0f];
		label.textColor = [UIColor colorWithColorType:ColorType_DeepTxt];
		label.backgroundColor = [UIColor clearColor];
		label.textAlignment = NSTextAlignmentCenter;
		[self addSubview:label];
		_lastUpdatedLabel=label;
		[label release];
		
		label = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, frame.size.height - 48.0f, self.frame.size.width, 20.0f)];
		label.autoresizingMask = UIViewAutoresizingFlexibleWidth;
		label.font = [UIFont boldSystemFontOfSize:13.0f];
		label.textColor = [UIColor colorWithColorType:ColorType_DeepTxt];
		label.backgroundColor = [UIColor clearColor];
		label.textAlignment = NSTextAlignmentCenter;
		[self addSubview:label];
		_statusLabel=label;
		[label release];
		
        _arrowImage = nil;
//		CALayer *layer = [CALayer layer];
//		layer.frame = CGRectMake(25.0f, frame.size.height - 65.0f, 30.0f, 55.0f);
//		layer.contentsGravity = kCAGravityResizeAspect;
//		layer.contents = (id)[UIImage imageNamed:@"grayArrow"].CGImage;
//		
//#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 40000
//		if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)]) {
//			layer.contentsScale = [[UIScreen mainScreen] scale];
//		}
//#endif
//		
//		[[self layer] addSublayer:layer];
//		_arrowImage=layer;
		
//		UIActivityIndicatorView *view = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
//		view.frame = CGRectMake(25.0f, frame.size.height - 38.0f, 20.0f, 20.0f);
//		[self addSubview:view];
//		_activityView = view;
//		[view release];
		
		
		[self setState:EGOOPullRefreshNormal];
    }
	
    return self;
}

- (void)adjustPosition {
    CGSize size = _scrollView.frame.size;
    CGPoint center = CGPointZero;
    
    switch (_orientation) {
        case EGOPullOrientationDown:
            center = CGPointMake(size.width/2, 0.0f-size.height/2);
            break;
        case EGOPullOrientationUp:
            center = CGPointMake(size.width/2, _scrollView.contentSize.height+size.height/2);
            break;
        case EGOPullOrientationRight:
            center = CGPointMake(0.0f-size.width/2, size.height/2);
            break;
        case EGOPullOrientationLeft:
            center = CGPointMake(_scrollView.contentSize.width+size.width/2, size.height/2);
            break;
        default:
            break;
    }
    
    self.center = center;
}

- (id)initWithScrollView:(UIScrollView* )scrollView orientation:(EGOPullOrientation)orientation {
    CGSize size = scrollView.frame.size;
    CGPoint center = CGPointZero;
    CGFloat degrees = 0.0f;
    
    _orientation = orientation;
    _scrollView = scrollView;
    
    switch (orientation) {
        case EGOPullOrientationDown:
            center = CGPointMake(size.width/2, 0.0f-size.height/2);
            degrees = 0.0f;
            break;
        case EGOPullOrientationUp:
            center = CGPointMake(size.width/2, scrollView.contentSize.height+size.height/2);
            degrees = 180.0f;
            break;
        case EGOPullOrientationRight:
            center = CGPointMake(0.0f-size.width/2, size.height/2);
            size = CGSizeMake(size.height, size.width);
            degrees = -90.0f;
            break;
        case EGOPullOrientationLeft:
            center = CGPointMake(scrollView.contentSize.width+size.width/2, size.height/2);
            size = CGSizeMake(size.height, size.width);
            degrees = 90.0f;
            break;
        default:
            break;
    }
    self = [self initWithFrame:CGRectMake(0, 0, size.width, size.height)];
    if (self) {
        self.transform = CGAffineTransformMakeRotation((degrees * M_PI) / 180.0f);
        self.center = center;
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        if (EGOPullOrientationUp == _orientation) {
            _lastUpdatedLabel.transform = CGAffineTransformMakeRotation((degrees * M_PI) / 180.0f);
            _statusLabel.transform = CGAffineTransformMakeRotation((degrees * M_PI) / 180.0f);
        }
        [scrollView addSubview:self];
    }
    return self;
}


#pragma mark -
#pragma mark Setters

- (void)setDelegate:(id<EGORefreshTableHeaderDelegate>)delegate
{
    _delegate = delegate;
    [self refreshLastUpdatedDate];
}

- (void)refreshLastUpdatedDate {
    
	if ([_delegate respondsToSelector:@selector(egoRefreshTableHeaderDataSourceLastUpdated:)]) {
		NSDate *date = [_delegate egoRefreshTableHeaderDataSourceLastUpdated:self];
		_lastUpdatedLabel.text = [NSString stringWithFormat:NSLocalizedString(@"BB_TXTID_上次更新: %@",@"%@"), [NSDate formatterDateForHM:date]];
	} else {
		_lastUpdatedLabel.text = nil;
	}
    
}

- (void)setState:(EGOPullRefreshState)aState{
    BOOL refresh = (_orientation == EGOPullOrientationDown||_orientation == EGOPullOrientationRight);
	switch (aState) {
		case EGOOPullRefreshPulling:
            if (refresh) {
                _statusLabel.text = NSLocalizedString(@"BB_TXTID_释放立即刷新...",nil);
            } else {
                _statusLabel.text = NSLocalizedString(@"BB_TXTID_释放加载更多...",nil);
            }
			
			[CATransaction begin];
			[CATransaction setAnimationDuration:FLIP_ANIMATION_DURATION];
			_arrowImage.transform = CATransform3DMakeRotation((M_PI / 180.0) * 180.0f, 0.0f, 0.0f, 1.0f);
			[CATransaction commit];
			break;
		case EGOOPullRefreshNormal:
			if (_state == EGOOPullRefreshPulling) {
				[CATransaction begin];
				[CATransaction setAnimationDuration:FLIP_ANIMATION_DURATION];
				_arrowImage.transform = CATransform3DIdentity;
				[CATransaction commit];
			}
			
            if (refresh) {
                _statusLabel.text = NSLocalizedString(@"BB_TXTID_下拉刷新...",nil);
            } else {
                _statusLabel.text = NSLocalizedString(@"BB_TXTID_加载更多...",nil);
            }
			
			[_activityView stopAnimating];
			[CATransaction begin];
			[CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions];
			_arrowImage.hidden = NO;
			_arrowImage.transform = CATransform3DIdentity;
			[CATransaction commit];
            
            [self refreshLastUpdatedDate];
			break;
		case EGOOPullRefreshLoading:
			_statusLabel.text = NSLocalizedString(@"BB_TXTID_正在加载...",nil);
			[_activityView startAnimating];
			[CATransaction begin];
			[CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions];
			_arrowImage.hidden = YES;
			[CATransaction commit];
			
			break;
		default:
			break;
	}
	_state = aState;
}


#pragma mark - ScrollView Methods
- (void)egoRefreshScrollViewDidScroll:(UIScrollView *)scrollView {
	if (_state == EGOOPullRefreshLoading) {
        switch (_orientation) {
            case EGOPullOrientationDown: {
                CGFloat offset = MAX(scrollView.contentOffset.y * -1, 0);
                offset = MIN(offset, 60);
                scrollView.contentInset = UIEdgeInsetsMake(offset, 0.0f, 0.0f, 0.0f);
                break;
            }
            case EGOPullOrientationUp: {
                CGFloat offset = MAX(scrollView.frame.size.height+scrollView.contentOffset.y-scrollView.contentSize.height, 0);
                offset = MIN(offset, 60);
                scrollView.contentInset = UIEdgeInsetsMake(0.0f, 0.0f, offset, 0.0f);
                break;
            }
            case EGOPullOrientationRight: {
                CGFloat offset = MAX(scrollView.contentOffset.x * -1, 0);
                offset = MIN(offset, 60);
                scrollView.contentInset = UIEdgeInsetsMake(0.0f, offset, 0.0f, 0.0f);
                break;
            }
            case EGOPullOrientationLeft: {
                CGFloat offset = MAX(scrollView.frame.size.width+scrollView.contentOffset.x-scrollView.contentSize.width, 0);
                offset = MIN(offset, 60);
                scrollView.contentInset = UIEdgeInsetsMake(0.0f, 0.0f, 0.0f, offset);
                break;
            }
            default:
                break;
        }
		
	} else if (scrollView.isDragging) {
		
		BOOL _loading = NO;
		if ([_delegate respondsToSelector:@selector(egoRefreshTableHeaderDataSourceIsLoading:)]) {
			_loading = [_delegate egoRefreshTableHeaderDataSourceIsLoading:self];
		}
        
        BOOL pullingCondition = [self reachToPullCondition:scrollView];
        BOOL normalCondition = NO;
        switch (_orientation) {
            case EGOPullOrientationDown:
                normalCondition = (scrollView.contentOffset.y < -65.0f);
                break;
            case EGOPullOrientationUp: {
                CGFloat y = scrollView.contentOffset.y+scrollView.frame.size.height;
                normalCondition = (y > (scrollView.contentSize.height+65.0f));
                break;
            }
            case EGOPullOrientationRight:
                normalCondition = (scrollView.contentOffset.x < -65.0f);
                break;
            case EGOPullOrientationLeft: {
                CGFloat x = scrollView.contentOffset.x+scrollView.frame.size.width;
                normalCondition = (x > (scrollView.contentSize.width+65.0f));
                break;
            }
            default:
                break;
        }
        
		if (_state == EGOOPullRefreshPulling && pullingCondition && !_loading) {
			[self setState:EGOOPullRefreshNormal];
		} else if (_state == EGOOPullRefreshNormal && normalCondition && !_loading) {
			[self setState:EGOOPullRefreshPulling];
		}
		
		if (scrollView.contentInset.top != 0) {
			scrollView.contentInset = UIEdgeInsetsZero;
		}
		
	}
	
}

- (void)egoRefreshScrollViewDidEndDragging:(UIScrollView *)scrollView {
	
	BOOL _loading = NO;
	if ([_delegate respondsToSelector:@selector(egoRefreshTableHeaderDataSourceIsLoading:)]) {
		_loading = [_delegate egoRefreshTableHeaderDataSourceIsLoading:self];
	}
    
    BOOL condition = [self reachToEdgeShouldChanged:scrollView];
    UIEdgeInsets insets = [self insetOfRefreshControlInOrientation];

	if (condition && !_loading) {
        /* Set NO paging Disable */
        _pagingEnabled = scrollView.pagingEnabled;
        scrollView.pagingEnabled = NO;
        
		[self setState:EGOOPullRefreshLoading];
		[UIView beginAnimations:nil context:NULL];
		[UIView setAnimationDuration:0.2];
		scrollView.contentInset = insets;
		[UIView commitAnimations];
        
        if ([_delegate respondsToSelector:@selector(egoRefreshTableHeaderDidTriggerRefresh:)]) {
            [_delegate egoRefreshTableHeaderDidTriggerRefresh:self];
        }
	}
	
}

- (BOOL)reachToEdgeShouldChanged:(UIScrollView *)scrollView
{
    BOOL condition = NO;
    switch (_orientation) {
        case EGOPullOrientationDown:
            condition = (scrollView.contentOffset.y <= - 65.0f);
            break;
        case EGOPullOrientationUp: {
            CGFloat y = scrollView.contentOffset.y+scrollView.frame.size.height-scrollView.contentSize.height;
            condition = (y > 65.0f);
            break;
        }
        case EGOPullOrientationRight:
            condition = (scrollView.contentOffset.x <= - 65.0f);
            break;
        case EGOPullOrientationLeft: {
            CGFloat x = scrollView.contentOffset.x+scrollView.frame.size.width-scrollView.contentSize.width;
            condition = (x > 65.0f);
            break;
        }
        default:
            break;
    }
    return condition;
}

- (BOOL)reachToPullCondition:(UIScrollView *)scrollView
{
    BOOL pullingCondition = NO;
    switch (_orientation) {
        case EGOPullOrientationDown:
            pullingCondition = (scrollView.contentOffset.y > -65.0f && scrollView.contentOffset.y < 0.0f);
            break;
        case EGOPullOrientationUp: {
            CGFloat y = scrollView.contentOffset.y+scrollView.frame.size.height;
            pullingCondition = ((y < (scrollView.contentSize.height+65.0f)) && (y > scrollView.contentSize.height));
            break;
        }
        case EGOPullOrientationRight:
            pullingCondition = (scrollView.contentOffset.x > -65.0f && scrollView.contentOffset.x < 0.0f);
            break;
        case EGOPullOrientationLeft: {
            CGFloat x = scrollView.contentOffset.x+scrollView.frame.size.width;
            pullingCondition = ((x < (scrollView.contentSize.width+65.0f)) && (x > scrollView.contentSize.width));
            break;
        }
        default:
            break;
    }
    return pullingCondition;
}

- (UIEdgeInsets)insetOfRefreshControlInOrientation
{
    UIEdgeInsets insets = UIEdgeInsetsZero;
    switch (_orientation) {
        case EGOPullOrientationDown:
            insets = UIEdgeInsetsMake(60.0f, 0.0f, 0.0f, 0.0f);
            break;
        case EGOPullOrientationUp: {
            insets = UIEdgeInsetsMake(0.0f, 0.0f, 60.0f, 0.0f);
            break;
        }
        case EGOPullOrientationRight:
            insets = UIEdgeInsetsMake(0.0f, 60.0f, 0.0f, 0.0f);
            break;
        case EGOPullOrientationLeft: {
            insets = UIEdgeInsetsMake(0.0f, 0.0f, 0.0f, 60.0f);
            break;
        }
        default:
            break;
    }
    return insets;
}

- (void)egoRefreshScrollViewDataSourceDidFinishedLoading:(UIScrollView *)scrollView {
	
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:.3];
	[scrollView setContentInset:UIEdgeInsetsMake(0.0f, 0.0f, 0.0f, 0.0f)];
	[UIView commitAnimations];
	scrollView.pagingEnabled = _pagingEnabled;
	[self setState:EGOOPullRefreshNormal];
    
}


#pragma mark -
#pragma mark Dealloc

- (void)dealloc {
	
	_delegate=nil;
	_activityView = nil;
	_statusLabel = nil;
	_arrowImage = nil;
	_lastUpdatedLabel = nil;
    [super dealloc];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
}

@end
