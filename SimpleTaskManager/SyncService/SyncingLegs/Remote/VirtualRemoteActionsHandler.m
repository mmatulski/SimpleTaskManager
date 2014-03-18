//
// Created by Marek M on 18.03.2014.
// Copyright (c) 2014 Tomato. All rights reserved.
//

#import "VirtualRemoteActionsHandler.h"
#import "DBAccess.h"
#import "DBController.h"
#import "STMTask.h"
#import "RemoteLeg.h"
#import "STMTaskModel.h"

@implementation VirtualRemoteActionsHandler {

}

- (id)init {
    self = [super init];
    if (self) {
        _timerInterval = 10.0;
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

    static int counter = 0;

    int numberOfTasks = [tasks count];

    int numberOfItemsToChange = (int) ceil((float) numberOfTasks * 0.25);
    if(numberOfItemsToChange > numberOfTasks){
        numberOfItemsToChange = numberOfTasks;
    }
    int numberOfTasksToRename = (int) ceil(0.33 * (float) numberOfItemsToChange);
    int numberOfTasksToReorder = (int) ceil(0.33 * (float) numberOfItemsToChange);
    int numberOfTasksToRemove = (int) ceil(0.33 * (float) numberOfItemsToChange);
    int increase = (int) ceil(0.05 * (float) numberOfItemsToChange);
    if(increase == 0){
        increase = 1;
    }
    int numberOfTasksToAdd = numberOfTasksToRemove + increase;


    NSMutableArray *array = [[NSMutableArray alloc] init];

    for(int i = 0; i < numberOfTasksToAdd; i++){
        STMTaskModel *add1 = [[STMTaskModel alloc] initWithName:[NSString stringWithFormat:@"task %d_%d", counter++, i]
                                                            uid:nil index:nil];
        [array addObject:add1];
    }



    [self.remoteLeg syncAddedTasks:[NSArray arrayWithArray:array]
                      removedTasks:nil
                      renamedTasks:nil
                    reorderedTasks:nil
                  successFullBlock:^(id o) {
                      DDLogInfo(@"generateActionsForTasks SUCCESS");
                  } failureBlock:^(NSError *error) {
        DDLogInfo(@"generateActionsForTasks FAILURE %@", [error localizedDescription]);
    }];

//    for(STMTask *task in tasks){
//
//    }

    //self.remoteLeg


}

-(void) stopTrafficGenerator{
    [self.timer invalidate];
}

- (void)dealloc {
    [self stopTrafficGenerator];
}


@end