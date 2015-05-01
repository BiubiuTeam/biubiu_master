//
//  DPPostCardStyleView.h
//  BiuBiu
//
//  Created by haowenliang on 15/1/26.
//  Copyright (c) 2015年 dpsoft. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DPPostCardStyleView : UIView
@property (nonatomic, strong) id datasource;
@property (nonatomic, copy) DPCallbackBlock btnClickBlock;

- (void)setTimeText:(NSString*)time locationInfo:(NSString*)lbsinfo content:(NSString*)content;
- (void)setReplyNumber:(NSInteger)reply upvoteNumber:(NSInteger)upvote downVoteNumber:(NSInteger)downvote;

+ (CGFloat)otherControlHeight;
+ (CGFloat)adjustHeightWhenFillWithContent:(NSString*)content;

@end
