//
// Created by Marek M on 17.03.2014.
// Copyright (c) 2014 Tomato. All rights reserved.
//

#import <Foundation/Foundation.h>

@class STMTask;
@class ServerSide;
@class UserSide;
@class SyncSide;

@interface SyncGuardService : NSObject

+ (instancetype) sharedInstance;
+ (ServerSide*) singleServer;
+ (UserSide *) singleUser;

@property(nonatomic, strong) NSOperationQueue *operationsQueue;
@property(nonatomic, strong) ServerSide *server;
@property(nonatomic, strong) UserSide *user;

-(void) connectToServer;

-(void) operationIsWaitingForExecutionOnSide:(SyncSide *) side;

@end