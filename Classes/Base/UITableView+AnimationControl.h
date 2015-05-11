//
//  UITableView+AnimationControl.h
//  biubiu
//
//  Created by haowenliang on 15/5/11.
//  Copyright (c) 2015年 dpsoft. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UITableView (AnimationControl)

- (void)beginSmartUpdatesForDuration:(NSTimeInterval)duration;
- (void)endSmartUpdates;

- (void)insertRowsAtIndexPaths:(NSArray *)indexPaths withRowAnimation:(UITableViewRowAnimation)animation completion:(void (^)(void))completion;
- (void)insertSections:(NSIndexSet *)sections withRowAnimation:(UITableViewRowAnimation)animation completion:(void (^)(void))completion;

- (void)deleteRowsAtIndexPaths:(NSArray *)indexPaths withRowAnimation:(UITableViewRowAnimation)animation completion:(void (^)(void))completion;
- (void)deleteSections:(NSIndexSet *)sections withRowAnimation:(UITableViewRowAnimation)animation completion:(void (^)(void))completion;

- (void)reloadRowsAtIndexPaths:(NSArray *)indexPaths withRowAnimation:(UITableViewRowAnimation)animation completion:(void (^)(void))completion;
- (void)reloadSections:(NSIndexSet *)sections withRowAnimation:(UITableViewRowAnimation)animation completion:(void (^)(void))completion;

- (void)moveRowAtIndexPath:(NSIndexPath *)indexPath toIndexPath:(NSIndexPath *)newIndexPath completion:(void (^)(void))completion;
- (void)moveSection:(NSInteger)section toSection:(NSInteger)newSection completion:(void (^)(void))completion;

@end
