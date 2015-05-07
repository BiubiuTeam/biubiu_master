//
//  DPListStyleViewCell.h
//  BiuBiu
//
//  Created by haowenliang on 15/1/15.
//  Copyright (c) 2015年 dpsoft. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ListConstants.h"

typedef NS_ENUM(NSUInteger, ListStyleViewState) {
    ListStyleViewState_Close = 0,
    ListStyleViewState_Open = 1,
};

@class DPListStyleViewCell;

@protocol DPListStyleViewCellProtocol <NSObject>

@optional
- (void)cellDidClickMessageButton:(NSInteger)modelInPosition;

@end

@interface DPListStyleViewCell : UITableViewCell

@property (nonatomic, assign) NSInteger modelInPosition;
@property (nonatomic, assign) id<DPListStyleViewCellProtocol> delegate;

- (void)setPostContentModel:(id)model;

- (void)closeReplyViewOpt;

@property (nonatomic, assign) ListStyleViewState contentState;

@end
