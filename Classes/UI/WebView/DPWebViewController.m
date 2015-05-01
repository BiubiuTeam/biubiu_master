//
//  DPWebViewController.m
//  TableViewDemo
//
//  Created by haowenliang on 14/12/23.
//  Copyright (c) 2014年 dpsoft. All rights reserved.
//

#import "DPWebViewController.h"

@interface DPWebViewController()<UIWebViewDelegate>

@property (nonatomic, strong) NSString* htmlName;
@property (nonatomic, strong) UIWebView* webView;
@end

@implementation DPWebViewController

- (instancetype)initWithHtml:(NSString*)html
{
    self = [super init];
    if (self) {
        _canResetTitle = YES;
        self.htmlName = html;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self resetBackBarButtonWithImage];
    
    CGRect frame = self.view.bounds;
    frame.size.height -= [self getNavStatusBarHeight];
    _webView = [[UIWebView alloc] initWithFrame:frame];
    _webView.delegate = self;
    _webView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:_webView];
    
    UIScrollView* scroll = (UIScrollView*) [_webView findSubview:@"UIScrollView" resursion:YES];
    [scroll setShowsHorizontalScrollIndicator:NO];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if ([_htmlName length]) {
        NSURL *url = [[NSBundle mainBundle] URLForResource:_htmlName withExtension:@"html"];
        NSString *html = [NSString stringWithContentsOfURL:url encoding:NSUTF8StringEncoding error:nil];
        NSString *path = [[NSBundle mainBundle] bundlePath];
        NSURL *baseURL = [NSURL fileURLWithPath:path];
        [_webView loadHTMLString:html baseURL:baseURL];
    }else{
        
    }
}

- (void)webViewDidFinishLoad:(UIWebView *)webView{
    if (_canResetTitle && [_htmlName length]) {
        NSString *theTitle= [webView stringByEvaluatingJavaScriptFromString:@"document.title"];
        [self setTitle:theTitle];
    }
}
@end
