//
//  DPStreamViewCell.m
//  BiuBiu
//
//  Created by haowenliang on 14/12/17.
//  Copyright (c) 2014年 dpsoft. All rights reserved.
//

#import "DPStreamViewCell.h"
@interface DPStreamViewCell()

@end

@implementation DPStreamViewCell

- (void)setReuseIdentifier:(NSString *)reuseIdentifier
{
    _reuseIdentifier = reuseIdentifier;
}

- (NSString *)reuseIdentifier
{
    return _reuseIdentifier;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
#if 1
        self.backgroundColor = [UIColor clearColor];
#else
        self.backgroundColor = [UIColor lightGrayColor];
        // Initialization code
        CGRect bgFrame = CGRectInset(self.bounds, 0.0f, 0.0f);
        UIView *bgView = [[UIView alloc] initWithFrame:bgFrame];
        bgView.layer.borderColor = [UIColor blackColor].CGColor;
        bgView.layer.borderWidth = 2.0f;
        [self addSubview:bgView];
        bgView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
#endif
    }
    
    return self;
}

@end
