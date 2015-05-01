//
//  DPImageViewController.m
//  biubiu
//
//  Created by haowenliang on 15/2/28.
//  Copyright (c) 2015年 dpsoft. All rights reserved.
//

#import "DPImageViewController.h"

@interface DPImageViewController ()
{
    UIScrollView* _scrollView;
    UIImageView* _contentView;
}

@end

@implementation DPImageViewController

- (instancetype)initWithImage:(UIImage*)image
{
    if (self = [super init]) {
        self.contentImage = image;
    }
    return self;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self resetBackBarButtonWithImage];
    
    self.view.backgroundColor = [UIColor colorWithColorType:ColorType_DeepGray];
    
    // Do any additional setup after loading the view.
    CGRect bframe = self.view.bounds;
    bframe.size.height = bframe.size.height - [self getNavStatusBarHeight];
    
    _scrollView = [[UIScrollView alloc] initWithFrame:bframe];
    _scrollView.backgroundColor = [UIColor clearColor];
    _scrollView.showsHorizontalScrollIndicator = NO;
    _scrollView.showsVerticalScrollIndicator = NO;
    [self.view addSubview:_scrollView];
    
    _contentView = [[UIImageView alloc] initWithFrame:CGRectZero];
    _contentView.width = SCREEN_WIDTH;
    _contentView.backgroundColor = [UIColor clearColor];
    _contentView.contentMode = UIViewContentModeScaleAspectFill;
    _contentView.clipsToBounds = YES;
    [_scrollView addSubview:_contentView];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (_contentImage) {
        float imgWidth = _contentImage.size.width;
        float imgHeight = _contentImage.size.height;
        float scale = _contentView.width/ imgWidth;
        
        _contentView.height = imgHeight*scale;
        _contentView.image = _contentImage;
        _scrollView.contentSize = CGSizeMake(SCREEN_WIDTH, _contentView.height);
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
