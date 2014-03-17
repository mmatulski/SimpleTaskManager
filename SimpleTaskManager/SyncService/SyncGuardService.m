//
// Created by Marek M on 17.03.2014.
// Copyright (c) 2014 Tomato. All rights reserved.
//

#import "SyncGuardService.h"
#import "STMTask.h"
#import "ServerSide.h"
#import "UserSide.h"
#import "SyncSide.h"
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

+ (ServerSide *)singleServer {
    return [[SyncGuardService sharedInstance] server];
}

+ (UserSide *)singleUser {
    return [[SyncGuardService sharedInstance] user];
}

- (id)init {
    self = [super init];
    if (self) {
        self.operationsQueue = [[NSOperationQueue alloc] init];
        self.operationsQueue.maxConcurrentOperationCount = 1;
        self.user = [[UserSide alloc] init];
        self.user.syncGuardService = self;
        self.server = [[ServerSide alloc] init];
        self.server.syncGuardService = self;
    }

    return self;
}

- (void)connectToServer {
    [self.server connect];
}

- (void)operationIsWaitingForExecutionOnSide:(SyncSide *)side {
    if([side isKindOfClass:[UserSide class]]){
        [self userOperationIsWaitingForExecution];
    } else if([side isKindOfClass:[ServerSide class]]){
        [self serverOperationIsWaitingForExecution];
    }
}


- (void)operationIsWaitingForExecution {

}


- (void)userOperationIsWaitingForExecution {
    SingleOperation *operation = [self.user nextOperation];
    [self.operationsQueue addOperation:operation];
}

- (void)serverOperationIsWaitingForExecution {

}




@end