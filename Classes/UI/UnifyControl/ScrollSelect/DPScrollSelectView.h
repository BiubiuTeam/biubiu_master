//
//  DPScrollSelectView.h
//  BiuBiu
//
//  Created by haowenliang on 15/1/3.
//  Copyright (c) 2015年 dpsoft. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SSIndexPath.h"
#import "DPScrollSelectStrip.h"

@class DPScrollSelectView;

@protocol DPScrollSelectViewDelegate <NSObject>

@optional
- (void)scrollSelect:(DPScrollSelectView *)tableView didSelectCellAtIndexPath:(NSIndexPath *)indexPath;

@end

@protocol DPScrollSelectViewDatasource <NSObject>

@required
- (NSInteger)scrollSelect:(DPScrollSelectView *)scrollSelect numberOfRowsInStripAtIndex:(NSInteger)index;

- (UIView*)scrollSelect:(DPScrollSelectView*) scrollSelect cellForRowAtIndexPath:(NSIndexPath *)indexPath;

- (CGFloat)scrollSelect:(DPScrollSelectView*) scrollSelect widthForRowAtIndexPath:(NSIndexPath *)indexPath;

@optional
- (CGFloat)scrollRateForStripAtIndex: (NSInteger) index;

//Default is 1, if not implemented
- (NSInteger)scrollSelect:(DPScrollSelectView *)scrollSelect numberOfSectionsInStripAtIndex:(NSInteger)index;
// Default is 1 if not implemented
- (NSInteger)numberOfStripsInScrollSelect;

@end


@interface DPScrollSelectView : UIView<ScrollSelectStripProtocol>

@property (nonatomic, strong) NSArray* strips;

@property (nonatomic, assign) id<DPScrollSelectViewDelegate> delegate;

@property (nonatomic, assign) id<DPScrollSelectViewDatasource> datasource;

-(void) startScrollingDriver;
-(void) stopScrollingDriver;
//Actions
- (CGFloat) scrollRateForStripAtIndex: (NSInteger) index;
- (DPScrollSelectStrip*) StripAtIndex:(NSInteger) index;

- (void)reloadData;

@end
