//
//  DPDetailReplyItemCell.h
//  BiuBiu
//
//  Created by haowenliang on 15/1/27.
//  Copyright (c) 2015年 dpsoft. All rights reserved.
//

#import <UIKit/UIKit.h>
@class DPAnswerModel;


#define REPLYITEM_FOLLOW_HEIGHT _size_S(45) //引用回复内容

@protocol DPDetailReplyItemCellProtocol <NSObject>
@optional
- (void)voteAnswerUpOrDown:(NSInteger)voteType voteModel:(id)model;

@end

@interface DPDetailReplyItemCell : UITableViewCell

@property (nonatomic, assign) BOOL highLightContent;
@property (nonatomic, assign) NSInteger dataPosition;

@property (nonatomic, assign) NSInteger questionId;
@property (nonatomic, assign) NSInteger ansId;

@property (nonatomic, assign) id<DPDetailReplyItemCellProtocol> delegate;

+ (CGFloat)cellHeightForContentText:(NSString*)content withFollowMsg:(BOOL)withfm;

- (void)setUpvoteAreaSelected:(BOOL)selected;
- (void)setDownvoteAreaSelected:(BOOL)selected;
- (void)updateViewWithReplyModel;
@end
