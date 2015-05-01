//
//  DPContactUsViewController.m
//  BiuBiu
//
//  Created by haowenliang on 14/12/22.
//  Copyright (c) 2014年 dpsoft. All rights reserved.
//

#import "DPContactUsViewController.h"

@interface DPContactUsViewController ()

@property (nonatomic, strong) UIImageView* bgImageView;

@property (nonatomic, strong) UILabel* coprightLabel;
@property (nonatomic, strong) UILabel* contactsLabel;
@end

@implementation DPContactUsViewController
- (void)dealloc
{
    DPTrace("联系我们页面释放");
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithColorType:ColorType_ContactBg];
    
    [self resetBackBarButtonWithImage];
    NSString* imageName = NSLocalizedString(@"BB_SRCID_ContactUs", nil);
    UIImage* bgImage = LOAD_ICON_USE_POOL_CACHE(imageName);
    _bgImageView = [[UIImageView alloc] initWithImage:bgImage];
    _bgImageView.width = self.view.width;
    _bgImageView.height = bgImage.size.height * bgImage.size.width/self.view.width;
    _bgImageView.clipsToBounds = YES;
    _bgImageView.contentMode = UIViewContentModeScaleAspectFill;
    [self.view addSubview:_bgImageView];
    
    [self addContactMethods];
    [self addCopyrightLabel];
}

- (void)addCopyrightLabel
{
    _coprightLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    _coprightLabel.font = [DPFont systemFontOfSize:FONT_SIZE_SMALL];
    _coprightLabel.textColor = [UIColor colorWithColorType:ColorType_MediumTxt];
    _coprightLabel.backgroundColor = [UIColor clearColor];
    _coprightLabel.numberOfLines = 0;
    _coprightLabel.textAlignment = NSTextAlignmentCenter;
    
    [self.view addSubview:_coprightLabel];
    //设置文案
    id copyTxt = NSLocalizedString(@"BB_TXTID_公司Copyright", nil);
    if ([copyTxt isKindOfClass:[NSString class]]) {
        _coprightLabel.text = (NSString*)copyTxt;
    }else{
        _coprightLabel.text = nil;
    }
    _coprightLabel.width = SCREEN_WIDTH - _size_S(64);
    [_coprightLabel sizeToFit];
    
    _coprightLabel.bottom = self.view.height - _size_S(21);
    _coprightLabel.centerX = self.view.width/2.0;
}

- (void)addContactMethods
{
    _contactsLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.view.width - _size_S(64), 0)];
    _contactsLabel.numberOfLines = 0;
    _contactsLabel.backgroundColor = [UIColor clearColor];
    _contactsLabel.textColor = [UIColor colorWithColorType:ColorType_MediumTxt];
    _contactsLabel.font = [DPFont systemFontOfSize:FONT_SIZE_LARGE];
    [self.view addSubview:_contactsLabel];
    
    //加载文案
    NSMutableString* contactStr = [[NSMutableString alloc] initWithString:@""];
    id dict = @{ NSLocalizedString(@"BB_TXTID_新浪微博",nil):@"二三三三个问题",
                 NSLocalizedString(@"BB_TXTID_官网",nil): @"biubiu.co"
//                 ,
//                 @"微信公众号": @"biubiu",
//                 @"商业合作": @"biubiu@biubiu.xyz",
//                 @"举报投诉": @"tousu@biubiu.xyz"
                 };
    if ([dict isKindOfClass:[NSDictionary class]]) {
        NSDictionary* contacts = (NSDictionary*)dict;
        NSArray* allKeys = [contacts allKeys];
        for (NSString* key in allKeys) {
            [contactStr appendFormat:@"%@ : %@\n",key,[contacts objectForKey:key]];
        }
    }
    _contactsLabel.text = contactStr;
    [_contactsLabel sizeToFit];
    
    float height = _size_S(8);
    if (SCREEN_HEIGHT > 480) {
        height = _size_S(40);
    }
    
    _contactsLabel.top = _bgImageView.bottom + height;
    _contactsLabel.centerX = self.view.width/2.;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self setTranslucentNavBackground];
}

- (BOOL)isSupportLeftDragBack
{
    return NO;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self setDefaultNavBackground];
}

- (void)loadView
{
    [super loadView];
    
}
@end
