//
// Created by Marek M on 16.03.2014.
// Copyright (c) 2014 Tomato. All rights reserved.
//

#import "DBController+Internal.h"
#import "STMTask.h"


@implementation DBController (Internal)

- (STMTask *)findTaskWithId:(NSString *)uid error:(NSError **) error{

    NSFetchRequest *request = [self prepareTaskFetchRequest];

    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(uid = %@)", uid];
    [request setPredicate:predicate];

    NSError *err = nil;
    NSArray *fetchResults = [self.context executeFetchRequest:request error:&err];
    if (fetchResults == nil) {
        DDLogError(@"DBController err when findTaskWithId %@: %@", uid, [err localizedDescription]);
        forwardError(err, error);
        return nil;
    }

    if([fetchResults count] > 1){
        DDLogWarn(@"DBController findTaskWithId %@ found more than one task", uid);
        //TODO remove redundant items
    } else if([fetchResults count] == 0){
        forwardError(__ERR(ERROR_TASK_NOT_FOUND), error);
        return nil;
    }

    return [fetchResults firstObject];
}

- (NSFetchRequest *)prepareTaskFetchRequest {
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription
            entityForName:kSTMTaskEntityName inManagedObjectContext:self.context];
    [fetchRequest setEntity:entity];
    return fetchRequest;
}

- (BOOL)removeTask:(STMTask *)task error:(NSError **)error {

    NSNumber *indexNumber =  task.index;
    int indexOfTaskToRemove = [indexNumber intValue];

    [self.context deleteObject:task];

    _numberOfAllTasks--;

    NSError *err = nil;
    if(![self decreaseOrderNrInAllTasksWithOrderGreaterThan:indexOfTaskToRemove error:&err]){
        DDLogError(@"DBController err when removeTask %d: %@", indexOfTaskToRemove, [err localizedDescription]);
        forwardError(err, error);
        return false;
    }

    return true;
}

- (BOOL)decreaseOrderNrInAllTasksWithOrderGreaterThan:(int)relatedOrder error:(NSError **)error{

    NSError *err = nil;
    NSArray * tasks = [self findAllTasksWithOrderGreaterThan:relatedOrder error:&err];

    if(!tasks){
        DDLogError(@"DBController err when decreaseOrderNrInAllTasksWithOrderGreaterThan %d: %@", relatedOrder, [err localizedDescription]);
        forwardError(err, error);
        return false;
    }

    for (STMTask *task in tasks){
        [self decreaseOrderNrOfTask:task];
    }

    return true;
}

- (void)decreaseOrderNrOfTask:(STMTask *)task {
    NSNumber *indexNumber =  task.index;
    int index = [indexNumber intValue];
    NSNumber *decreasedIndexNumber  = [NSNumber numberWithInt:index - 1];
    task.index = decreasedIndexNumber;
}

- (NSArray *)findAllTasksWithOrderGreaterThan:(int)relatedOrder error:(NSError **)error {

    NSFetchRequest *request = [self prepareTaskFetchRequest];

    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(index > %d)", relatedOrder];
    [request setPredicate:predicate];

    NSError *err = nil;
    NSArray *fetchResults = [self.context executeFetchRequest:request error:&err];
    if (fetchResults == nil) {
        DDLogError(@"DBController err when findAllTasksWithOrderGreaterThan %d: %@", relatedOrder, [err localizedDescription]);
        forwardError(err, error);
        return nil;
    }

    return fetchResults;
}

@end