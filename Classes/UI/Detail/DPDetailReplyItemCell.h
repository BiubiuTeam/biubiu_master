//
//  DPDetailReplyItemCell.h
//  BiuBiu
//
//  Created by haowenliang on 15/1/27.
//  Copyright (c) 2015年 dpsoft. All rights reserved.
//

#import <UIKit/UIKit.h>
@class DPAnswerModel;

@interface DPDetailReplyItemCell : UITableViewCell

@property (nonatomic, assign) BOOL highLightContent;
@property (nonatomic, assign) NSInteger dataPosition;

@property (nonatomic, assign) NSInteger questionId;
@property (nonatomic, assign) NSInteger ansId;

@property (nonatomic, copy) DPCallbackBlock upvoteClickOpt;
@property (nonatomic, copy) DPCallbackBlock downvoteClickOpt;

+ (CGFloat)cellHeightForContentText:(NSString*)content;

- (void)setUpvoteAreaSelected:(BOOL)selected;
- (void)setDownvoteAreaSelected:(BOOL)selected;
- (void)updateViewWithReplyModel;
@end
