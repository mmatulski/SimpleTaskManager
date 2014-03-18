//
// Created by Marek M on 17.03.2014.
// Copyright (c) 2014 Tomato. All rights reserved.
//

#import "SyncGuardService.h"
#import "STMTask.h"
#import "RemoteLeg.h"
#import "LocalUserLeg.h"
#import "SyncingLeg.h"
#import "SingleOperation.h"


@implementation SyncGuardService {

}

+ (instancetype) sharedInstance
{
    static dispatch_once_t dbAccessOnceToken;
    static id sharedInstance;
    dispatch_once(&dbAccessOnceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

+ (RemoteLeg *)singleServer {
    return [[SyncGuardService sharedInstance] server];
}

+ (LocalUserLeg *)singleUser {
    return [[SyncGuardService sharedInstance] user];
}

- (id)init {
    self = [super init];
    if (self) {
        self.operationsQueue = [[NSOperationQueue alloc] init];
        self.operationsQueue.maxConcurrentOperationCount = 1;
        self.user = [[LocalUserLeg alloc] init];
        self.user.syncGuardService = self;
        self.server = [[RemoteLeg alloc] init];
        self.server.syncGuardService = self;
    }

    return self;
}

- (void)connectToServer {
    [self.server connect];
}

- (void)operationIsWaitingForExecutionOnSide:(SyncingLeg *)side {
    if([side isKindOfClass:[LocalUserLeg class]]){
        [self userOperationIsWaitingForExecution];
    } else if([side isKindOfClass:[RemoteLeg class]]){
        [self serverOperationIsWaitingForExecution];
    }
}

- (void)userOperationIsWaitingForExecution {
    SingleOperation *operation = [self.user nextOperation];
    [self.operationsQueue addOperation:operation];
}

- (void)serverOperationIsWaitingForExecution {

}




@end