//
//  DPImageViewController.h
//  biubiu
//
//  Created by haowenliang on 15/2/28.
//  Copyright (c) 2015年 dpsoft. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DPImageViewController : UIViewController

- (instancetype)initWithImage:(UIImage*)image;
@property (nonatomic, strong) UIImage* contentImage;

@end
