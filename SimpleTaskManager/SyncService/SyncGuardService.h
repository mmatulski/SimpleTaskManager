//
// Created by Marek M on 17.03.2014.
// Copyright (c) 2014 Tomato. All rights reserved.
//

#import <Foundation/Foundation.h>

@class STMTask;
@class RemoteLeg;
@class LocalUserLeg;
@class SyncingLeg;

@interface SyncGuardService : NSObject

+ (instancetype) sharedInstance;
+ (RemoteLeg *) singleServer;
+ (LocalUserLeg *) singleUser;

@property(nonatomic, strong) NSOperationQueue *operationsQueue;
@property(nonatomic, strong) RemoteLeg *remoteSide;
@property(nonatomic, strong) LocalUserLeg *user;

@property(nonatomic) BOOL remoteSideOperationRequested;

@property(nonatomic) BOOL localUserSideOperationRequested;

-(void) connectToServer;

- (void)disconnectFromServer;

- (BOOL)isConnected;

-(void) operationIsWaitingForExecutionOnSide:(SyncingLeg *) side;

- (void)operationFinished;
@end