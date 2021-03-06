//
//  DPLbsServerEngine.m
//  biubiu
//
//  Created by haowenliang on 15/3/28.
//  Copyright (c) 2015年 dpsoft. All rights reserved.
//

#import "DPLbsServerEngine.h"
#import "DPFileHelper.h"
#import "NSKeyedUnarchiverAdditions.h"
#import "DPHttpService.h"

#import "NSObject+Encoder.h"

NSString* const DPLocationDidEndUpdate = @"_DPLocationDidEndUpdate_";
NSString* const DPLocationWillStartUpdate = @"_DPLocationWillStartUpdate_";
NSString* const DPLocationDidStopUpdate = @"_DPLocationDidStopUpdate_";
NSString* const DPLocationDidFailedUpdate = @"_DPLocationDidFailedUpdate_";
NSString* const DPLocationGetReverseGeoCodeResult = @"_DPLocationGetReverseGeoCodeResult_";


@implementation BBLocationManager

- (instancetype)init
{
    self = [super init];
    if (self) {
        _currentStatus = NSNotFound;
        [self setDelegate:self];
    }
    return self;
}

- (void) requestAuthorization
{
    //ios8.0以上需要如下判断才能授权
    if([self respondsToSelector:@selector(requestWhenInUseAuthorization)]){
        [self requestWhenInUseAuthorization];
    }
}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    DPTrace("Change authorization status: %zd to status: %zd",_currentStatus, status);
    
    switch (status) {
        case kCLAuthorizationStatusNotDetermined:{
            //首次请求地理位置
            DPTrace("kCLAuthorizationStatusNotDetermined");
//            [self requestAuthorization];
        }break;
        case kCLAuthorizationStatusAuthorized:
            //case kCLAuthorizationStatusAuthorizedAlways:
        {
            DPTrace("kCLAuthorizationStatusAuthorized");
        }break;
        case kCLAuthorizationStatusAuthorizedWhenInUse:
        {
            DPTrace("kCLAuthorizationStatusAuthorizedWhenInUse");
        }break;
        case kCLAuthorizationStatusDenied:{
            DPTrace("kCLAuthorizationStatusDenied");
        }break;
        case kCLAuthorizationStatusRestricted:{
            DPTrace("kCLAuthorizationStatusRestricted");
        }break;
        default:
            break;
    }
    [self postAuthorizationStatusChanged:status];
    _currentStatus = status;
}

- (void)postAuthorizationStatusChanged:(CLAuthorizationStatus)status
{
    NSMutableDictionary* dict = [NSMutableDictionary dictionary];
    [dict setObject:[NSNumber numberWithInteger:status] forKey:@"toStatus"];
    [dict setObject:[NSNumber numberWithInteger:_currentStatus] forKey:@"fromStatus"];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotification_ChangeLocationAuthorizationStatus object:nil userInfo:dict];
}

@end


@interface DPLbsServerEngine ()<BMKLocationServiceDelegate,BMKGeoCodeSearchDelegate>
{
    BMKLocationService* _locService;
    BMKGeoCodeSearch* _searcher;
    NSMutableArray* _locationManagerList;
    
    BOOL _isUpdatingLocation;
}

/*暂时仅作权限状态转换通知使用*/
@property (nonatomic, strong) BBLocationManager* bblocationMgr;

@property (nonatomic, strong) BMKGeoCodeSearch* searcher;
@end

@implementation DPLbsServerEngine

+ (instancetype)shareInstance
{
    static DPLbsServerEngine* s_instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        s_instance = [[DPLbsServerEngine alloc] init];
    });
    return s_instance;
}

- (instancetype)init
{
    if (self = [super init]) {
//        _bblocationMgr = [[BBLocationManager alloc] init];
        
        _isUpdatingLocation = NO;
        self.userLocation = [DPLbsServerEngine getCacheUserLocation];
        self.geoCodeResult = [DPLbsServerEngine getCacheGeoPoiResult];
        
        //设置定位精确度，默认：kCLLocationAccuracyBest
        [BMKLocationService setLocationDesiredAccuracy:kCLLocationAccuracyNearestTenMeters];
        //指定最小距离更新(米)，默认：kCLDistanceFilterNone
        [BMKLocationService setLocationDistanceFilter:1000.f];
        
        //初始化BMKLocationService
        _locService = [[BMKLocationService alloc]init];
        _locService.delegate = self;
        
//        //启动LocationService
//        [self forceToUpdateLocation];
    }
    return self;
}

- (BMKGeoCodeSearch *)searcher
{
    if (nil == _searcher) {
        _searcher = [[BMKGeoCodeSearch alloc]init];
        _searcher.delegate = self;
    }
    return _searcher;
}

- (void)forceToUpdateLocation
{
    if (_isUpdatingLocation) {
        DPTrace("地理位置正在更新");
        return;
    }
    if (_userLocation == nil || fabs([[NSDate date] timeIntervalSinceDate:_userLocation.location.timestamp]) > 2*60){
        DPTrace("地理位置需要更新");
        //启动LocationService
        [_locService startUserLocationService];
        _isUpdatingLocation = YES;
    }else{
        DPTrace("地理位置不需要更新");
        [[NSNotificationCenter defaultCenter] postNotificationName:DPLocationDidEndUpdate object:nil];
        [[NSNotificationCenter defaultCenter] postNotificationName:DPLocationGetReverseGeoCodeResult object:nil];
    }
}

- (int)latitude
{
    int lat = 0;
    if (_userLocation) {
        lat = _userLocation.location.coordinate.latitude * 1000000;
    }
    return lat;
}

- (int)longitude
{
    int lon = 0;
    if (_userLocation) {
        lon = _userLocation.location.coordinate.longitude * 1000000;
    }
    return lon;
}

- (BMKPoiInfo*)getPoiInfoAtIndex:(NSInteger)index
{
    NSArray* poiList = _geoCodeResult.poiList;
    NSInteger count = [poiList count];
//    if (index >= count) {
//        [self reverseGeoCode];
//    }
    if (count) {
        index = index%count;
        return [poiList objectAtIndex:index];
    }
    return nil;
}

- (NSString*)getUserLocationName:(NSInteger)index
{
    NSArray* poiList = _geoCodeResult.poiList;
    NSInteger count = [poiList count];
    if (count) {
        index = index%count;
        BMKPoiInfo* info = [poiList objectAtIndex:index];
        if (info && [info.name length]) {
            return info.name;
        }
    }
    return _geoCodeResult.address;
}

- (CLLocationCoordinate2D)getLoactionCoordinate2DAtIndex:(NSInteger)index
{
    NSArray* poiList = _geoCodeResult.poiList;
    NSInteger count = [poiList count];
    if (count) {
        index = index%count;
        BMKPoiInfo* info = [poiList objectAtIndex:index];
        if (info && [info.name length]) {
            return info.pt;
        }
    }
    return _geoCodeResult.location;
}

#pragma mark- switch授权和打开的开关
//系统定位服务是否打开
-(BOOL) isLocationServerviceEnabled
{
    BOOL locationsvEnabled = [CLLocationManager locationServicesEnabled];
    return locationsvEnabled;
}

//手Q是否授权
-(BOOL) isAuthorized
{
    CLAuthorizationStatus status = [CLLocationManager authorizationStatus];
    if (SYSTEM_VERSION >= 8.0)
    {
        if (status == kCLAuthorizationStatusAuthorizedAlways || status == kCLAuthorizationStatusAuthorizedWhenInUse) {
            return YES;
        }
    }
    else
    {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        if(status == kCLAuthorizationStatusAuthorized)
#pragma clang diagnostic pop
        {
            return YES;
        }
    }
    
    return NO;
}

//是否打开且授权
static BOOL everShowUpAlert = NO;
-(BOOL) isEnabledAndAuthorize
{
    if ([self isLocationServerviceEnabled] && [self isAuthorized])
    {
        return YES;
    }
    else
    {
        if (NO == everShowUpAlert) {
            everShowUpAlert = YES;
            UIAlertView* alert = [[UIAlertView alloc] initWithTitle:nil message:NSLocalizedString(@"BB_TXTID_需要开启定位服务，允许biubiu的请求",nil) delegate:nil cancelButtonTitle:nil otherButtonTitles:NSLocalizedString(@"BB_TXTID_确定",nil), nil];
            [alert show];
        }
        return NO;
    }
}

#pragma mark -
/**
 *在将要启动定位时，会调用此函数
 */
- (void)willStartLocatingUser
{
    [[NSNotificationCenter defaultCenter] postNotificationName:DPLocationWillStartUpdate object:nil];
}

/**
 *在停止定位后，会调用此函数
 */
- (void)didStopLocatingUser
{
    [[NSNotificationCenter defaultCenter] postNotificationName:DPLocationDidStopUpdate object:nil];
}

/**
 *用户位置更新后，会调用此函数
 *@param userLocation 新的用户位置
 */
- (void)didUpdateBMKUserLocation:(BMKUserLocation *)userLocation
{
    [_locService stopUserLocationService];
    _isUpdatingLocation = NO;
    NSLog(@"didUpdateUserLocation lat %f,long %f",userLocation.location.coordinate.latitude,userLocation.location.coordinate.longitude);
    if (userLocation) {
        self.userLocation = userLocation;
        [DPLbsServerEngine saveUserLocation:_userLocation];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:DPLocationDidEndUpdate object:nil];
    
    [self reverseGeoCode];
}

- (void)reverseGeoCode
{
    //检索用户POI
    CLLocationCoordinate2D pt = _userLocation.location.coordinate;
    BMKReverseGeoCodeOption *reverseGeoCodeSearchOption = [[BMKReverseGeoCodeOption alloc]init];
    reverseGeoCodeSearchOption.reverseGeoPoint = pt;
    BOOL flag = [self.searcher reverseGeoCode:reverseGeoCodeSearchOption];
    if(flag){
        NSLog(@"*****eo检索发送成功");
    }else{
        NSLog(@"*****eo检索发送失败");
    }
}

/**
 *定位失败后，会调用此函数
 *@param error 错误号
 */
- (void)didFailToLocateUserWithError:(NSError *)error
{
    [[NSNotificationCenter defaultCenter] postNotificationName:DPLocationDidFailedUpdate object:nil];
}

#pragma mark - 
//接收反向地理编码结果
-(void) onGetReverseGeoCodeResult:(BMKGeoCodeSearch *)searcher result:(BMKReverseGeoCodeResult *)result errorCode:(BMKSearchErrorCode)error{
    if(result){
        self.geoCodeResult = result;
        [DPLbsServerEngine saveGeoPoiResult:_geoCodeResult];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:DPLocationGetReverseGeoCodeResult object:nil];
}

#pragma mark - cache Lbs

+ (BOOL)saveUserLocation:(id)object
{
    if (!object) {
        return NO;
    }
    NSString* filePath = [DPFileHelper biuBiuListFilePath];
    [DPFileHelper createPath:filePath];
    NSString* fileName = [NSString stringWithFormat:@"%@/userLocation",filePath];
    return [NSKeyedArchiver archiveRootObject:object toFile:fileName];
}

+ (BOOL)saveGeoPoiResult:(id)object
{
    if (!object) {
        return NO;
    }
    NSString* filePath = [DPFileHelper biuBiuListFilePath];
    [DPFileHelper createPath:filePath];
    NSString* fileName = [NSString stringWithFormat:@"%@/geoPoiResult",filePath];
    return [NSKeyedArchiver archiveRootObject:object toFile:fileName];
}

+ (id)getCacheUserLocation
{
    NSString* fileName = [NSString stringWithFormat:@"%@/userLocation",[DPFileHelper biuBiuListFilePath]];
    id object = nil;
    @try {
        object = [NSKeyedUnarchiver unarchiveObjectWithFileNoException:fileName];
    }
    @catch (NSException *exception) {}
    @finally {}
    
    return object;
}

+ (id)getCacheGeoPoiResult
{
    NSString* fileName = [NSString stringWithFormat:@"%@/geoPoiResult",[DPFileHelper biuBiuListFilePath]];
    id object = nil;
    @try {
        object = [NSKeyedUnarchiver unarchiveObjectWithFileNoException:fileName];
    }
    @catch (NSException *exception) {}
    @finally {}
    
    return object;
}


@end
