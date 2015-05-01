//
//  DPListStyleViewCell.h
//  BiuBiu
//
//  Created by haowenliang on 15/1/15.
//  Copyright (c) 2015年 dpsoft. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DPListStyleLeftView.h"

@class DPListStyleViewCell;

@protocol DPListStyleViewCellProtocol <NSObject>
@optional
- (void)replyStateChangedAtPosition:(NSInteger)position toState:(ListStyleViewState)state;

@end

@interface DPListStyleViewCell : UITableViewCell

@property (nonatomic, assign) NSInteger modelInPosition;
@property (nonatomic, assign) id<DPListStyleViewCellProtocol> delegate;

@property (nonatomic, copy) DPCallbackBlock openOptBlock;
@property (nonatomic, copy) DPCallbackBlock closeOptBlock;

@property (nonatomic, copy) DPCallbackBlock clickBlock;

- (void)didClickLeftView;
- (void)setPostContentModel:(id)model;
- (void)closeLeftReplyViewSilence:(BOOL)silence;
- (void)openLeftViewOpt;

@property (nonatomic, assign) ListStyleViewState contentState;

@end
