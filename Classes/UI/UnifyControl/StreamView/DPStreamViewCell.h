//
//  DPStreamViewCell.h
//  BiuBiu
//
//  Created by haowenliang on 14/12/17.
//  Copyright (c) 2014年 dpsoft. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DPStreamView.h"

@class DPStreamViewCell;
@protocol DPStreamViewCellProtocol <NSObject>

- (void)didSelectedCell:(DPStreamViewCell*)cell;

@end

@interface DPStreamViewCell : UIView<DPResusableCell>
{
    NSString *_reuseIdentifier;
    id<DPStreamViewCellProtocol> _delegate;
}

@property (nonatomic) id<DPStreamViewCellProtocol> delegate;

@end
