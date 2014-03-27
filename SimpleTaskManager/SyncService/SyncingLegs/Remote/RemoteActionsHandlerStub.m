//
// Created by Marek M on 18.03.2014.
// Copyright (c) 2014 Tomato. All rights reserved.
//

#import "RemoteActionsHandlerStub.h"
#import "DBAccess.h"
#import "DBController.h"
#import "RemoteLeg.h"
#import "DBController+BasicActions.h"
#import "STMTaskModel+JSONSerializer.h"
#import "RemoteActionsHandlerStub+SerializedData.h"

@implementation RemoteActionsHandlerStub {

@private
    NSTimeInterval _timerInterval;
    CGFloat _changedItemsShare;
    CGFloat _increaseRate;
    CGFloat _renameItemsShare;
    CGFloat _reorderedItemsShare;

}

- (id)init {
    self = [super init];
    if (self) {
        _timerInterval = 20.0;
        _changedItemsShare = 0.25;
        _increaseRate = 1.01; //no less than 1
        _renameItemsShare = 0.33;
        _reorderedItemsShare = 0.33;
    }

    return self;
}

#pragma mark - Traggic Generator Timer

- (void)connect {
    [super connect];

    [self startTrafficGenerator];
}

- (void)disconnect {
    [super disconnect];

    [self stopTrafficGenerator];
}


- (void)startTrafficGenerator {
    self.timer = [NSTimer scheduledTimerWithTimeInterval:_timerInterval target:self selector:@selector(generateTraffic) userInfo:nil repeats:YES];
    //self.timer = [NSTimer scheduledTimerWithTimeInterval:3 target:self selector:@selector(addCommonTasks) userInfo:nil repeats:NO];
}

- (void)stopTrafficGenerator {
    [self.timer invalidate];
}

#pragma mark -

/*
    This methods will begin traffic generation (standard and delayed for serialized items)
 */
- (void)generateTraffic {
    DDLogInfo(@"TRAFFIC");
    BlockWeakSelf selfWeak = self;

    DBController *controller = [DBAccess createBackgroundWorker];
    [controller fetchAllTasksAsModels:^(NSArray *tasks) {
        //draw tasks to change
        NSMutableArray *tasksToChange = [selfWeak drawTaskToChangeFromArray:tasks];

        // take previously drawn data for serialized generator before it will be overwritten by drawn a moment ago
        NSData *previousData = self.lastTimeChangedItemsJSON;

        //remember drawn data for serialized generator in next cycle
        selfWeak.lastTimeChangedItemsJSON = [self serializedTaskModels:tasksToChange];

        [selfWeak generateActionsForTasks:tasksToChange addNewTasks:YES numberOfAllTasks:0];
        [selfWeak generateActionsForSerializedTasks:previousData withDelayInSeconds:_timerInterval / 2.0];

    }                    failureBlock:^(NSError *error) {
        DDLogError(@"generateTraffic Problem with fetching all tasks %@", [error localizedDescription]);
    }];
}

/*
    Method draws adequate number of tasks from tasks array.
    (this number os estimated according to _changedItemsShare factor)
 */
- (NSMutableArray *)drawTaskToChangeFromArray:(NSArray *)tasks {
    NSUInteger numberOfTasks = [tasks count];

    NSUInteger numberOfItemsToChange = (NSUInteger) floor((float) numberOfTasks * _changedItemsShare);
    if (numberOfItemsToChange > numberOfTasks) {
        numberOfItemsToChange = numberOfTasks;
    }

    return [self drawFromArray:tasks numberOfItems:numberOfItemsToChange];
}

/*
    This method generates traffic for array of tasks
    - tasksToChange - array of tasks to change (STMTaskModel)
    - addNewTasks - indicates if also new tasks should be added
    - numberOfAllTasks - number of all tasks in db - this is helpful to simulate reordering
 */
- (void)generateActionsForTasks:(NSArray *)tasksToChange addNewTasks:(BOOL)addNewTasks numberOfAllTasks:(NSUInteger)numberOfAllTasks {

    runOnBackgroundThread(^{

        NSUInteger numberOfItemsToChange = [tasksToChange count];

        DDLogInfo(@"TRAFFIC generateActionsForTasks %td", numberOfItemsToChange);

        static NSUInteger counter = 0;
        static NSUInteger renameCounter = 0;

        //estimate number of to cahnge for each group

        NSUInteger numberOfTasksToRename = (NSUInteger) floor(_renameItemsShare * (float) numberOfItemsToChange);
        NSUInteger numberOfTasksToReorder = (NSUInteger) floor(_reorderedItemsShare * (float) numberOfItemsToChange);
        NSUInteger numberOfTasksToRemove = numberOfItemsToChange - (numberOfTasksToRename + numberOfTasksToReorder);


        CGFloat increaseF = (CGFloat) numberOfTasksToRemove * _increaseRate;
        NSInteger increase = (NSInteger) floor(increaseF) - numberOfTasksToRemove;

        if (increase < 1) {
            increase = 1;
        }

        NSUInteger numberOfTasksToAdd = addNewTasks ? numberOfTasksToRemove + increase : 0;


        NSMutableArray *leftTasksToChange = [tasksToChange mutableCopy];
        NSMutableArray *tasksToAdd = [[NSMutableArray alloc] init];
        NSMutableArray *tasksToRemove = [[NSMutableArray alloc] init];
        NSMutableArray *tasksToReorder = [[NSMutableArray alloc] init];
        NSMutableArray *tasksToRename = [[NSMutableArray alloc] init];

        //Adding
        for (int32_t i = 0; i < numberOfTasksToAdd; i++) {
            counter++;
            STMTaskModel *add1 = [[STMTaskModel alloc] initWithName:[NSString stringWithFormat:@"task %d_%d", (int32_t) counter, i]
                                                                uid:nil index:nil];
            [tasksToAdd addObject:add1];
        }


        for (int i = 0; i < numberOfTasksToRemove; i++) {
            STMTaskModel *taskModel = [leftTasksToChange firstObject];
            if (!taskModel) {
                break;
            }

            [tasksToRemove addObject:taskModel];

            [leftTasksToChange removeObject:taskModel];
        }

        for (int i = 0; i < numberOfTasksToRename; i++) {
            STMTaskModel *taskModel = [leftTasksToChange firstObject];
            if (!taskModel) {
                break;
            }

            [tasksToRename addObject:taskModel];
            renameCounter++;
            [taskModel setName:[NSString stringWithFormat:@"%@ ren %d", taskModel.name, (int32_t) renameCounter]];
            [leftTasksToChange removeObject:taskModel];
        }

        for (int i = 0; i < numberOfTasksToReorder; i++) {
            STMTaskModel *taskModel = [leftTasksToChange firstObject];
            if (!taskModel) {
                break;
            }

            [self setAnotherOrderNrForTask:taskModel fromPossible:numberOfAllTasks];
            [tasksToReorder addObject:taskModel];
            [leftTasksToChange removeObject:taskModel];
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
    });
}

- (void)generateActionsForSerializedTasks:(NSData *)data withDelayInSeconds:(NSTimeInterval) timeToDelayInSeconds {
    BlockWeakSelf selfWeak = self;

    int64_t timeToWaitInNanoSeconds =  (int64_t) (ceil(timeToDelayInSeconds * NSEC_PER_SEC));
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, timeToWaitInNanoSeconds);
    dispatch_after(popTime, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void) {
        if([selfWeak isConnected]){
            [selfWeak generateActionsForSerializedTasksUsedPreviously:data];
        }
    });
}

- (void)generateActionsForSerializedTasksUsedPreviously:(NSData *)data {
    if (!data) {
        DDLogWarn(@"generateActionsForSerializedTasks no data to process");
        return;
    }

    NSArray *taskModels = [self deserializeTasksFromJsonData:data];
    if (!taskModels) {
        DDLogWarn(@"generateActionsForSerializedTasks data was not deserialized");

    }

    DDLogInfo(@"generateActionsForSerializedTasksUsedPreviously");
    [self generateActionsForTasks:taskModels addNewTasks:YES numberOfAllTasks:0];
}

- (void)setAnotherOrderNrForTask:(STMTaskModel *)taskModel fromPossible:(NSUInteger)possible {
    if (possible < 2) {
        return;
    }

    NSUInteger theNewIndex = [taskModel.index unsignedIntegerValue];
    while (theNewIndex == [taskModel.index unsignedIntegerValue]) {
        theNewIndex = arc4random_uniform((u_int32_t) possible);
    }

    taskModel.index = [NSNumber numberWithUnsignedInteger:theNewIndex];
}

/*
    Draws specified number of tasks from tasks array.
 */
- (NSMutableArray *)drawFromArray:(NSArray *)tasks numberOfItems:(NSUInteger)numberOfTasksToDraw {
    NSMutableArray *result = [[NSMutableArray alloc] init];

    NSMutableArray *stillToDraw = [tasks mutableCopy];
    NSUInteger numberOfAllItems = [stillToDraw count];
    if (numberOfTasksToDraw >= numberOfAllItems) {
        return stillToDraw;
    }

    for (int i = 0; i < numberOfTasksToDraw; i++) {
        STMTaskModel *taskDrawn = [self drawItemFromArray:stillToDraw];
        if (taskDrawn) {
            [result addObject:taskDrawn];
            [stillToDraw removeObject:taskDrawn];
        } else {
            break;
        }
    }

    return result;
}

/*
    Draws single item from array.
 */
- (id)drawItemFromArray:(NSMutableArray *)tasks {
    NSUInteger numberOfTasks = [tasks count];
    uint32_t index = arc4random_uniform((uint32_t) numberOfTasks);
    if (index < numberOfTasks) {
        return [tasks objectAtIndex:index];
    }

    return nil;
}



#pragma mark - nice data

- (void)addCommonTasks {
    NSMutableArray *tasksToAdd = [[NSMutableArray alloc] init];

    //Adding
    [tasksToAdd addObject:[[STMTaskModel alloc] initWithName:@"Pierwszy" uid:nil index:nil]];
    [tasksToAdd addObject:[[STMTaskModel alloc] initWithName:@"Drugi" uid:nil index:nil]];
    [tasksToAdd addObject:[[STMTaskModel alloc] initWithName:@"Trzeci" uid:nil index:nil]];
    [tasksToAdd addObject:[[STMTaskModel alloc] initWithName:@"Czwarty" uid:nil index:nil]];
    [tasksToAdd addObject:[[STMTaskModel alloc] initWithName:@"Piaty" uid:nil index:nil]];
    [tasksToAdd addObject:[[STMTaskModel alloc] initWithName:@"Szósty" uid:nil index:nil]];
    [tasksToAdd addObject:[[STMTaskModel alloc] initWithName:@"Siódmy" uid:nil index:nil]];
    [tasksToAdd addObject:[[STMTaskModel alloc] initWithName:@"Ósmy" uid:nil index:nil]];
    [tasksToAdd addObject:[[STMTaskModel alloc] initWithName:@"Dziewiąty" uid:nil index:nil]];
    [tasksToAdd addObject:[[STMTaskModel alloc] initWithName:@"Dziesiąty" uid:nil index:nil]];
    [tasksToAdd addObject:[[STMTaskModel alloc] initWithName:@"Jedenasty" uid:nil index:nil]];
    [tasksToAdd addObject:[[STMTaskModel alloc] initWithName:@"Dwunasty" uid:nil index:nil]];
    [tasksToAdd addObject:[[STMTaskModel alloc] initWithName:@"Trzynasty" uid:nil index:nil]];
    [tasksToAdd addObject:[[STMTaskModel alloc] initWithName:@"Czternasty" uid:nil index:nil]];
    [tasksToAdd addObject:[[STMTaskModel alloc] initWithName:@"Piętnasty" uid:nil index:nil]];
    [tasksToAdd addObject:[[STMTaskModel alloc] initWithName:@"Szesnasty" uid:nil index:nil]];
    [tasksToAdd addObject:[[STMTaskModel alloc] initWithName:@"Siedemnasty" uid:nil index:nil]];
    [tasksToAdd addObject:[[STMTaskModel alloc] initWithName:@"Osiemnasty" uid:nil index:nil]];
    [tasksToAdd addObject:[[STMTaskModel alloc] initWithName:@"Dziewiętnasty" uid:nil index:nil]];
    [tasksToAdd addObject:[[STMTaskModel alloc] initWithName:@"Dwudziesty" uid:nil index:nil]];
    [tasksToAdd addObject:[[STMTaskModel alloc] initWithName:@"Dwudziesty pierwszy" uid:nil index:nil]];
    [tasksToAdd addObject:[[STMTaskModel alloc] initWithName:@"Dwudziesty drugi" uid:nil index:nil]];
    [tasksToAdd addObject:[[STMTaskModel alloc] initWithName:@"Dwudziesty trzeci" uid:nil index:nil]];
    [tasksToAdd addObject:[[STMTaskModel alloc] initWithName:@"Dwudziesty czwarty" uid:nil index:nil]];
    [tasksToAdd addObject:[[STMTaskModel alloc] initWithName:@"Dwudziesty piąty" uid:nil index:nil]];
    [tasksToAdd addObject:[[STMTaskModel alloc] initWithName:@"Dwudziesty szósty" uid:nil index:nil]];
    [tasksToAdd addObject:[[STMTaskModel alloc] initWithName:@"Dwudziesty siódmy" uid:nil index:nil]];
    [tasksToAdd addObject:[[STMTaskModel alloc] initWithName:@"Dwudziesty ósmy" uid:nil index:nil]];
    [tasksToAdd addObject:[[STMTaskModel alloc] initWithName:@"Dwudziesty dziewiąty" uid:nil index:nil]];
    [tasksToAdd addObject:[[STMTaskModel alloc] initWithName:@"Trzydiesty" uid:nil index:nil]];
    [tasksToAdd addObject:[[STMTaskModel alloc] initWithName:@"Trzydiesty pierwszy" uid:nil index:nil]];
    [tasksToAdd addObject:[[STMTaskModel alloc] initWithName:@"Trzydiesty drugi" uid:nil index:nil]];
    [tasksToAdd addObject:[[STMTaskModel alloc] initWithName:@"Trzydiesty trzeci" uid:nil index:nil]];
    [tasksToAdd addObject:[[STMTaskModel alloc] initWithName:@"Trzydiesty czwarty" uid:nil index:nil]];
    [tasksToAdd addObject:[[STMTaskModel alloc] initWithName:@"Trzydiesty piąty" uid:nil index:nil]];
    [tasksToAdd addObject:[[STMTaskModel alloc] initWithName:@"Trzydiesty szósty" uid:nil index:nil]];
    [tasksToAdd addObject:[[STMTaskModel alloc] initWithName:@"Trzydiesty siódmy" uid:nil index:nil]];
    [tasksToAdd addObject:[[STMTaskModel alloc] initWithName:@"Trzydiesty ósmy" uid:nil index:nil]];
    [tasksToAdd addObject:[[STMTaskModel alloc] initWithName:@"Trzydiesty dziewiąty" uid:nil index:nil]];
    [tasksToAdd addObject:[[STMTaskModel alloc] initWithName:@"Czterdziesty" uid:nil index:nil]];
    [tasksToAdd addObject:[[STMTaskModel alloc] initWithName:@"Czterdziesty pierwszy" uid:nil index:nil]];
    [tasksToAdd addObject:[[STMTaskModel alloc] initWithName:@"Czterdziesty drugi" uid:nil index:nil]];
    [tasksToAdd addObject:[[STMTaskModel alloc] initWithName:@"Czterdziesty trzeci" uid:nil index:nil]];
    [tasksToAdd addObject:[[STMTaskModel alloc] initWithName:@"Czterdziesty czwarty" uid:nil index:nil]];
    [tasksToAdd addObject:[[STMTaskModel alloc] initWithName:@"Czterdziesty piąty" uid:nil index:nil]];
    [tasksToAdd addObject:[[STMTaskModel alloc] initWithName:@"Czterdziesty szósty" uid:nil index:nil]];
    [tasksToAdd addObject:[[STMTaskModel alloc] initWithName:@"Czterdziesty siódmy" uid:nil index:nil]];
    [tasksToAdd addObject:[[STMTaskModel alloc] initWithName:@"Czterdziesty ósmy" uid:nil index:nil]];
    [tasksToAdd addObject:[[STMTaskModel alloc] initWithName:@"Czterdziesty dziewiąty" uid:nil index:nil]];

    [self.remoteLeg syncAddedTasks:[NSArray arrayWithArray:tasksToAdd]
                      removedTasks:[NSArray arrayWithArray:nil]
                      renamedTasks:[NSArray arrayWithArray:nil]
                    reorderedTasks:[NSArray arrayWithArray:nil]
                  successFullBlock:^(id o) {
                      DDLogInfo(@"generateActionsForTasks SUCCESS");
                  } failureBlock:^(NSError *error) {
        DDLogInfo(@"generateActionsForTasks FAILURE %@", [error localizedDescription]);
    }];
}

#pragma mark -

- (void)dealloc {
    [self stopTrafficGenerator];
}


@end