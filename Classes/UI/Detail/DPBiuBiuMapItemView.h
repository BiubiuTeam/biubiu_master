//
//  DPBiuBiuMapItemView.h
//  BiuBiu
//
//  Created by haowenliang on 14/12/21.
//  Copyright (c) 2014年 dpsoft. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DPBiuBiuMapItemView : UIView

@property (nonatomic, copy) DPCallbackBlock upvoteBlock;
@property (nonatomic, copy) DPCallbackBlock downvoteBlock;

@property (nonatomic, strong) id datasource;

- (void)forceToUpdateModel;
@end
