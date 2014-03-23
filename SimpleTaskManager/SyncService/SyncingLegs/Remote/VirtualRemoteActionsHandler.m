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
#import "STMTaskModel+JSONSerializer.h"
#import "NSError+Log.h"

@implementation VirtualRemoteActionsHandler {

}

- (id)init {
    self = [super init];
    if (self) {
        _timerInterval = 10.0;
        _changedItemsFactor = 0.25;
        _increaseFactor = 1.0;
    }

    return self;
}


- (void)connect {
    [super connect];

    [self startTrafficGenerator];
}

- (void)startTrafficGenerator {
    self.timer = [NSTimer scheduledTimerWithTimeInterval:self.timerInterval target:self selector:@selector(generateTraffic) userInfo:nil repeats:YES];
    //self.timer = [NSTimer scheduledTimerWithTimeInterval:3 target:self selector:@selector(generateTrafficM) userInfo:nil repeats:NO];
}

- (void)generateTrafficM {
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

- (void)generateTraffic {
    DDLogInfo(@"TRAFFIC");
    BlockWeakSelf selfWeak = self;
    DBController* controller = [DBAccess createBackgroundWorker];
    [controller fetchAllTasksAsModels:^(NSArray *tasks) {

        NSData *previousData = self.lastTimeChangedItemsJSON;
        self.lastTimeChangedItemsJSON = [self serializedTaskModels:tasks];
        //[selfWeak generateActionsForTasks:tasks];
        [selfWeak generateActionsForSerializedTasks:previousData];
    } failureBlock:^(NSError *error) {
        DDLogError(@"generateTraffic Problem with fetching all tasks %@", [error localizedDescription]);
    }];
}

- (void)generateActionsForTasks:(NSArray *)tasks {

    DDLogInfo(@"TRAFFIC generateActionsForTasks %d", [tasks count]);



    static NSUInteger counter = 0;
    static NSUInteger renameCounter = 0;

    NSUInteger numberOfTasks = [tasks count];

    NSUInteger numberOfItemsToChange = (NSUInteger) floor((float) numberOfTasks * self.changedItemsFactor);
    if(numberOfItemsToChange > numberOfTasks){
        numberOfItemsToChange = numberOfTasks;
    }
    NSUInteger numberOfTasksToRename = (NSUInteger) floor(0.33 * (float) numberOfItemsToChange);
    NSUInteger numberOfTasksToReorder = (NSUInteger) floor(0.33 * (float) numberOfItemsToChange);
    NSUInteger numberOfTasksToRemove = numberOfItemsToChange - (numberOfTasksToRename + numberOfTasksToReorder);

//    NSUInteger increase = (NSUInteger) floor(0.2 * (float) numberOfItemsToChange);
//    if(increase == 0){
//        increase = 1;
//    }

//    numberOfTasksToReorder = 0;
//    numberOfTasksToRename = 0;
//    numberOfTasksToRemove = 0;

    CGFloat increseF = (CGFloat) numberOfTasksToRemove * self.increaseFactor;

    if(increseF == 0){
        increseF = 1.0;
    }

    if(increseF < 1 && increseF > 0){
        increseF = 1;
    }

    if(increseF > -1 && increseF < 0){
        increseF = -1;
    }

    NSInteger increase = (NSInteger)floor(increseF) - numberOfTasksToRemove;

    if(increase == 0){
        increase = 1;
    }

    NSUInteger numberOfTasksToAdd = numberOfTasksToRemove + increase;
    if(numberOfTasksToAdd < 0){
        numberOfTasksToAdd = 0;
    }

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
}

- (void)generateActionsForSerializedTasks:(NSData *)data {
    if(!data){
        DDLogWarn(@"generateActionsForSerializedTasks no data to process");
        return;
    }

    NSArray *taskModels = [self deserializeTasksFromJsonData:data];
    if(!taskModels){
        DDLogWarn(@"generateActionsForSerializedTasks data was not deserialized");

    }

    [self generateActionsForTasks:taskModels];
}

- (NSArray *)deserializeTasksFromJsonData:(NSData *)data {
    
    if(!data){
        DDLogError(@"deserializeTasksFromData data are nil");
        return nil;
    }
    
    NSString *stringWithData = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    DDLogInfo(@"deserializeTasksFromData string %@", stringWithData);

    NSError *err;
    NSArray *deserializedArrayOfSerializedTaskModels = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&err];
    if (!deserializedArrayOfSerializedTaskModels) {
        return nil;
    }

    NSArray *arrayOfTaskModels = [self deserializeTaskModelsFromArray:deserializedArrayOfSerializedTaskModels];
    if (!arrayOfTaskModels) {
        DDLogError(@"deserializeTasksFromData deserializedArrayOfSerializedTaskModels can not be deserialized");
    }

    return arrayOfTaskModels;
}

- (NSArray *)deserializeTaskModelsFromArray:(NSArray *)arrayOfSerializedTaskModels {
    
    if(!arrayOfSerializedTaskModels){
        DDLogWarn(@"deserializeTaskModelsFromArray array is empty");
        return nil;
    }
    
    NSMutableArray *result = [[NSMutableArray alloc] init];

    for (NSDictionary *taskModelDictionary in arrayOfSerializedTaskModels) {
        NSError *err = nil;
        STMTaskModel *taskModel = [[STMTaskModel alloc] initWithDictionary:taskModelDictionary];
        if (taskModel) {
            [result addObject:taskModel];
        }
    }

    return [NSArray arrayWithArray:result];
}

- (NSArray *)arrayOfSerializedTasksModels:(NSArray *)tasksModels {
    NSSortDescriptor *sortByUid = [[NSSortDescriptor alloc]
            initWithKey:@"uid" ascending:NO];

    NSArray *tasksSortedByUid = [tasksModels sortedArrayUsingDescriptors:@[sortByUid]];

    NSMutableArray *result = [[NSMutableArray alloc] init];

    NSEnumerator *sortedTasksEnumerator = [tasksSortedByUid objectEnumerator];
    STMTaskModel *model = [sortedTasksEnumerator nextObject];
    while (model){
        //NSData *serializedModel = [model serializeToJSON];
        NSDictionary *serializedModel = [model serializeToDctionary];
        if(serializedModel){
            [result addObject:serializedModel];
        }

        model = [sortedTasksEnumerator nextObject];
    }

    return [NSArray arrayWithArray:result];
}

-(NSData *) serializedTaskModels:(NSArray *)tasksModels{
    NSArray *arrayWithSerializedModels = [self arrayOfSerializedTasksModels:tasksModels];
    if(!arrayWithSerializedModels){
        DDLogError(@"serializedTaskModels array is empty");
        return nil;
    }
    
    if(![NSJSONSerialization isValidJSONObject:arrayWithSerializedModels]){
        DDLogError(@"serializedTaskModels array is not valid");
    }

    NSError *err = nil;
    NSData * result = [NSJSONSerialization dataWithJSONObject:arrayWithSerializedModels options:0 error:&err];
    if(!result){
        DDLogError(@"serializedTaskModels serialization failed");
        [err log];
    }

    return result;
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
    if(index < numberOfTasks){
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