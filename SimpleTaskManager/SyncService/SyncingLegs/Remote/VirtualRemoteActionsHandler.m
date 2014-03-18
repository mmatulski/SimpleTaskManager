//
// Created by Marek M on 18.03.2014.
// Copyright (c) 2014 Tomato. All rights reserved.
//

#import "VirtualRemoteActionsHandler.h"
#import "DBAccess.h"
#import "DBController.h"
#import "STMTask.h"

@implementation VirtualRemoteActionsHandler {

}

- (id)init {
    self = [super init];
    if (self) {
        _timerInterval = 2.0;
    }

    return self;
}


- (void)connect {
    [super connect];

    [self startTrafficGenerator];
}

- (void)startTrafficGenerator {
    self.timer = [NSTimer scheduledTimerWithTimeInterval:self.timerInterval target:self selector:@selector(generateTraffic) userInfo:nil repeats:YES];
}

- (void)generateTraffic {
    DDLogInfo(@"TRAFFIC");
    BlockWeakSelf selfWeak = self;
    DBController* controller = [DBAccess createBackgroundController];
    [controller fetchAllTasks:^(NSArray *tasks) {
        [selfWeak generateActionsForTasks:tasks];
    } failureBlock:^(NSError *error) {
        DDLogError(@"generateTraffic Problem with fetching all tasks %@", [error localizedDescription]);
    }];
}

- (void)generateActionsForTasks:(NSArray *)tasks {

    long value = random();
    for(STMTask *task in tasks){

    }




}

-(void) stopTrafficGenerator{
    [self.timer invalidate];
}

- (void)dealloc {
    [self stopTrafficGenerator];
}


@end