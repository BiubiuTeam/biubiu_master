//
//  DPMutableScrollView.h
//  BiuBiu
//
//  Created by haowenliang on 15/1/22.
//  Copyright (c) 2015年 dpsoft. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DPLineStreamView.h"

@class DPMutableScrollView;

@protocol DPMutableScrollViewDelegate <NSObject>

@optional
- (void)mutableScrollView:(DPMutableScrollView *)mScrollView didSelectCellAtIndexPath:(NSIndexPath *)indexPath;

@end

@protocol DPMutableScrollViewDatasource <NSObject>

@required
- (NSInteger)mutableScrollView:(DPMutableScrollView *)mScrollView numberOfRowsInStreamLineAtIndex:(NSInteger)index;

- (UIView*)mutableScrollView:(DPMutableScrollView*)mScrollView cellForRowAtIndexPath:(NSIndexPath *)indexPath;

- (CGFloat)mutableScrollView:(DPMutableScrollView*)mScrollView widthForRowAtIndexPath:(NSIndexPath *)indexPath;

@optional

- (CGFloat)scrollRateForStreamLineAtIndex: (NSInteger) index;

//Default is 1, if not implemented
- (NSInteger)mutableScrollView:(DPMutableScrollView *)mScrollView numberOfSectionsInStreamLineAtIndex:(NSInteger)index;
// Default is 1 if not implemented
- (NSInteger)numberOfStreamLinesInMutableScrollView;

@end

@interface DPMutableScrollView : UIView<DPLineStreamViewProtocol>

@property (nonatomic, strong) NSArray* streamLines;

@property (nonatomic, assign) id<DPMutableScrollViewDelegate> delegate;
@property (nonatomic, assign) id<DPMutableScrollViewDatasource> datasource;


-(void) startScrollingDriver;
-(void) stopScrollingDriver;
-(void) resetMutableScrollView;
//Actions
- (CGFloat) scrollRateForStreamLineAtIndex: (NSInteger) index;
- (DPLineStreamView*) streamLineAtIndex:(NSInteger) index;

- (void)reloadData;

- (void)enableUserInteraction:(BOOL)userInteraction;

@end
