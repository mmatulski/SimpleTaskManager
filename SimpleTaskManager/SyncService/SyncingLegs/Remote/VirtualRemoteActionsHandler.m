//
// Created by Marek M on 18.03.2014.
// Copyright (c) 2014 Tomato. All rights reserved.
//

#import "VirtualRemoteActionsHandler.h"
#import "DBAccess.h"
#import "DBController.h"
#import "RemoteLeg.h"
#import "STMTaskModel.h"
#import "DBController+BasicActions.h"

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
    DBController* controller = [DBAccess createBackgroundWorker];
    [controller fetchAllTasksAsModels:^(NSArray *tasks) {
        [selfWeak generateActionsForTasks:tasks];
    } failureBlock:^(NSError *error) {
        DDLogError(@"generateTraffic Problem with fetching all tasks %@", [error localizedDescription]);
    }];
}

- (void)generateActionsForTasks:(NSArray *)tasks {

    DDLogInfo(@"TRAFFIC generateActionsForTasks %d", [tasks count]);

    static NSUInteger counter = 0;
    static NSUInteger renameCounter = 0;

    NSUInteger numberOfTasks = [tasks count];

    NSUInteger numberOfItemsToChange = (NSUInteger) floor((float) numberOfTasks * 0.25);
    if(numberOfItemsToChange > numberOfTasks){
        numberOfItemsToChange = numberOfTasks;
    }
    NSUInteger numberOfTasksToRename = (NSUInteger) floor(0.33 * (float) numberOfItemsToChange);
    NSUInteger numberOfTasksToReorder = (NSUInteger) floor(0.33 * (float) numberOfItemsToChange);
    NSUInteger numberOfTasksToRemove = numberOfItemsToChange - (numberOfTasksToRename + numberOfTasksToReorder);

    if(numberOfTasksToRemove < 0){
        numberOfTasksToRemove = 0;
    }

    NSUInteger increase = (NSUInteger) floor(0.2 * (float) numberOfItemsToChange);
    if(increase == 0){
        increase = 1;
    }
    NSUInteger numberOfTasksToAdd = numberOfTasksToRemove + increase;

    NSMutableArray * tasksToChange = [self drawFromArray:tasks numberOfItems:numberOfItemsToChange];

    NSMutableArray *tasksToAdd = [[NSMutableArray alloc] init];
    NSMutableArray *tasksToRemove = [[NSMutableArray alloc] init];
    NSMutableArray *tasksToReorder = [[NSMutableArray alloc] init];
    NSMutableArray *tasksToRename = [[NSMutableArray alloc] init];

    //Adding
    for(int i = 0; i < numberOfTasksToAdd; i++){
        STMTaskModel *add1 = [[STMTaskModel alloc] initWithName:[NSString stringWithFormat:@"task %d_%d", counter++, i]
                                                            uid:nil index:nil];
        [tasksToAdd addObject:add1];
    }


    for (int i = 0; i < numberOfTasksToRemove; i++) {
        STMTaskModel *taskModel = [tasksToChange firstObject];
        if(!taskModel){
            break;
        }

        [tasksToRemove addObject:taskModel];

        [tasksToChange removeObject:taskModel];
    }

    for (int i = 0; i < numberOfTasksToRename; i++) {
        STMTaskModel *taskModel = [tasksToChange firstObject];
        if(!taskModel){
            break;
        }

        [tasksToRename addObject:taskModel];
        [taskModel setName:[NSString stringWithFormat:@"renamed %d", renameCounter++]];
        [tasksToChange removeObject:taskModel];
    }

    for (int i = 0; i < numberOfTasksToReorder; i++) {
        STMTaskModel *taskModel = [tasksToChange firstObject];
        if(!taskModel){
            break;
        }

        [self setAnotherOrderNrForTask:taskModel fromPossible:numberOfTasks];
        [tasksToReorder addObject:taskModel];
        [tasksToChange removeObject:taskModel];
    }

    [self.remoteLeg syncAddedTasks:[NSArray arrayWithArray:tasksToAdd]
                      removedTasks:[NSArray arrayWithArray:tasksToRemove]
                      renamedTasks:[NSArray arrayWithArray:tasksToRename]
                    reorderedTasks:[NSArray arrayWithArray:tasksToReorder]
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

- (void)setAnotherOrderNrForTask:(STMTaskModel *)taskModel fromPossible:(NSUInteger)possible {
    if(possible < 2){
        return;
    }

    NSUInteger theNewIndex = [taskModel.index unsignedIntegerValue];
    while (theNewIndex == [taskModel.index unsignedIntegerValue]){
        theNewIndex =  arc4random_uniform(possible);
    }

    taskModel.index = [NSNumber numberWithUnsignedInt:theNewIndex];
}

- (NSMutableArray *)drawFromArray:(NSArray *)tasks numberOfItems:(int) numberOfTasksToDraw {
    NSMutableArray *result = [[NSMutableArray alloc] init];

    NSMutableArray *stillToDraw = [tasks mutableCopy];
    int numberOfAllItems = [stillToDraw count];
    if(numberOfTasksToDraw >= numberOfAllItems){
        return stillToDraw;
    }

    for(int i = 0; i < numberOfTasksToDraw; i++){
        STMTaskModel *taskDrawn = [self drawItemFromArray:stillToDraw];
        if(taskDrawn){
            [result addObject:taskDrawn];
            [stillToDraw removeObject:taskDrawn];
        } else {
            break;
        }
    }

    return result;
}

- (id)drawItemFromArray:(NSMutableArray *)tasks {
    uint32_t numberOfTasks = [tasks count];
    uint32_t index = arc4random_uniform(numberOfTasks);
    if(index >=0 && index < numberOfTasks){
        return [tasks objectAtIndex:index];
    }

    return nil;
}

-(void) stopTrafficGenerator{
    [self.timer invalidate];
}

- (void)dealloc {
    [self stopTrafficGenerator];
}


@end