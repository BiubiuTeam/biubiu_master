//
//  DPHttpService+Sociaty.h
//  biubiu
//
//  Created by haowenliang on 15/3/25.
//  Copyright (c) 2015年 dpsoft. All rights reserved.
//

#import "DPHttpService.h"

extern NSString*const kUnionCreationResult;
extern NSString*const kPullUnionListResult;
extern NSString*const kPullUnionPostsResult;

extern NSString*const kPullCheckingUnionListResult;
extern NSString*const kCheckingUnionResult;

extern NSString*const kLocationUserPlace;

extern NSString*const kPullUnionPostListResult;

@interface DPHttpService (Sociaty)

/* 测试Url
 http://img15.3lian.com/2015/f3/17/d/161.jpg
 http://img15.3lian.com/2015/f3/17/d/162.jpg
 http://img15.3lian.com/2015/f3/17/d/163.jpg
 http://img15.3lian.com/2015/f3/17/d/164.jpg
 http://img15.3lian.com/2015/f3/17/d/165.jpg
 http://img15.3lian.com/2015/f3/17/d/166.jpg
 http://img15.3lian.com/2015/f3/17/d/167.jpg
 http://img15.3lian.com/2015/f3/17/d/168.jpg
 http://img15.3lian.com/2015/f3/17/d/169.jpg
 */
- (void)excuteCmdToCreateSociaty:(NSString*)sociatyName
                         picPath:(NSString*)path
                        location:(NSString*)curLocation
                        latitude:(int)lat
                        logitude:(int)lon;


- (void)excuteCmdToPullSociaties:(NSInteger)IdType
                          lastId:(NSInteger)lastId
                            type:(NSInteger)type
                        latitude:(int)lat
                        logitude:(int)lon;

//拉取工会的问题列表
- (void)excuteCmdToPullUnionPosts:(NSInteger)unionId
                           idType:(NSInteger)IdType
                           lastId:(NSInteger)lastId;
- (void)excuteCmdToPullUnionPosts:(NSInteger)unionId
                           idType:(NSInteger)IdType
                           lastId:(NSInteger)lastId
                       completion:(JSONObjectBlock)completion;
//工会审核模块的Api

- (void)excuteCmdToLoadCheckingUnions:(NSInteger)IdType
                               lastId:(NSInteger)lastId;

- (void)excuteCmdToCheckingTheUnions:(NSUInteger)unionId passed:(BOOL)pass;



//新增  1005   根据用户上报经纬度返回用户所在学校

- (void)excuteCmdToLocationUserPlaceAtLatitude:(int)lat
                                      logitude:(int)lon;

@end
