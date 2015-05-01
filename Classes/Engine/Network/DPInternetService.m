//
//  DPInternetService.m
//  BiuBiu
//
//  Created by haowenliang on 15/1/5.
//  Copyright (c) 2015年 dpsoft. All rights reserved.
//

#import "DPInternetService.h"
#import "Reachability.h"

@interface DPInternetService()

@property (nonatomic, strong) Reachability *hostReachability;
@property (nonatomic, strong) Reachability *internetReachability;
@property (nonatomic, strong) Reachability *wifiReachability;

@end

@implementation DPInternetService

+ (instancetype)shareInstance
{
    static DPInternetService* _sInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sInstance = [[DPInternetService alloc] init];
    });
    return _sInstance;
}

- (BOOL)networkEnable
{
    return _hostReachable || _wifiReachable || _internetReachable;
}

#pragma mark -
- (void)dealloc
{
    self.hostReachability = nil;
    self.wifiReachability = nil;
    self.internetReachability = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kReachabilityChangedNotification object:nil];
}

- (instancetype)init
{
    if (self = [super init]) {
        
        _hostReachable = NO;
        _wifiReachable = NO;
        _internetReachable = NO;
        
        /*
         Observe the kNetworkReachabilityChangedNotification. When that notification is posted, the method reachabilityChanged will be called.
         */
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityChanged:) name:kReachabilityChangedNotification object:nil];
        
        //Change the host name here to change the server you want to monitor.
        NSString *remoteHostName = @"www.parse.com";
        self.hostReachability = [Reachability reachabilityWithHostName:remoteHostName];
        [_hostReachability startNotifier];
        [self updateInterfaceWithReachability:_hostReachability];
        
        self.internetReachability = [Reachability reachabilityForInternetConnection];
        [_internetReachability startNotifier];
        [self updateInterfaceWithReachability:_internetReachability];
        
        self.wifiReachability = [Reachability reachabilityForLocalWiFi];
        [_wifiReachability startNotifier];
        [self updateInterfaceWithReachability:_wifiReachability];
    }
    return self;
}

/*!
 * Called by Reachability whenever status changes.
 */
- (void) reachabilityChanged:(NSNotification *)note
{
    Reachability* curReach = [note object];
    NSParameterAssert([curReach isKindOfClass:[Reachability class]]);
    [self updateInterfaceWithReachability:curReach];
}

- (void)updateInterfaceWithReachability:(Reachability *)reachability
{
    if (reachability == _hostReachability)
    {
        _hostReachable = [reachability currentReachabilityStatus] != NotReachable;
    }else if (reachability == _internetReachability)
    {
        _internetReachable = [reachability currentReachabilityStatus] != NotReachable;
    }else if (reachability == _wifiReachability)
    {
        _wifiReachable = [reachability currentReachabilityStatus] == ReachableViaWiFi;
    }
}

@end
