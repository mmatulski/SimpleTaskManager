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
    if(![self changeIndexBy:-1 inAllTaskWithIndexGreaterThan:indexOfTaskToRemove error:&err]){
        DDLogError(@"DBController err when removeTask %d: %@", indexOfTaskToRemove, [err localizedDescription]);
        forwardError(err, error);
        return false;
    }

    return true;
}

- (BOOL)changeIndexBy:(int)change inAllTaskWithIndexGreaterThan:(int)relatedOrder error:(NSError **)error {

    NSError *err = nil;
    NSArray * tasks = [self findAllTasksWithIndexHigherThan:relatedOrder error:&err];

    if(!tasks){
        DDLogError(@"DBController err when changeIndexBy inAllTaskWithIndexGreaterThan  %d: %@", relatedOrder, [err localizedDescription]);
        forwardError(err, error);
        return false;
    }

    for (STMTask *task in tasks){
        [self changeIndexBy:change inTask:task];
    }

    return true;
}

- (BOOL)changeIndexBy:(int)change inAllTasksWithIndexHigherThan:(int)higherThan butLowerThan:(int)lowerThan error:(NSError **)error {

    DDLogInfo(@"changeIndexBy %d  higherThan %d lowerThan %d", change, higherThan, lowerThan);

    NSError *err = nil;
    NSArray * tasks = [self findAllTasksWithIndexHigherThan:higherThan andLowerThan:lowerThan error:&err];

    if(!tasks){
        DDLogError(@"DBController err when changeIndexBy inAllTasksWithIndexHigherThan %d - %d: %@", higherThan, lowerThan, [err localizedDescription]);
        forwardError(err, error);
        return false;
    }

    for (STMTask *task in tasks){
        [self changeIndexBy:change inTask:task];
    }

    return true;
}

- (void)changeIndexBy:(int)change inTask:(STMTask *)task {
    NSNumber *indexNumber =  task.index;
    int index = [indexNumber intValue];
    int theNewIndex = index + change;
    NSNumber *changedIdnexNumber = [NSNumber numberWithInt:theNewIndex];

    DDLogInfo(@"----- change [%@] %d  from %d to %d", task.name ,change, index, theNewIndex);

    task.index = changedIdnexNumber;
}

- (NSArray *)findAllTasksWithIndexHigherThan:(int)relatedOrder error:(NSError **)error {

    NSFetchRequest *request = [self prepareTaskFetchRequest];

    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(index > %d)", relatedOrder];
    [request setPredicate:predicate];

    NSError *err = nil;
    NSArray *fetchResults = [self.context executeFetchRequest:request error:&err];
    if (fetchResults == nil) {
        DDLogError(@"DBController err when findAllTasksWithIndexHigherThan %d: %@", relatedOrder, [err localizedDescription]);
        forwardError(err, error);
        return nil;
    }

    return fetchResults;
}

- (NSArray *) findAllTasksWithIndexHigherThan:(int)higherThan andLowerThan:(int) lowerThan error:(NSError **)error {

    NSFetchRequest *request = [self prepareTaskFetchRequest];

    NSString *predicateString = [NSString stringWithFormat:@"(index > %d) AND (index < %d)", higherThan, lowerThan];
    DDLogInfo(@"findAllTasksWithIndexHigherThan higherThan %d lowerThan %d [%@]", higherThan, lowerThan, predicateString);
    NSPredicate *predicate = [NSPredicate predicateWithFormat:predicateString];
    [request setPredicate:predicate];

    NSError *err = nil;
    NSArray *fetchResults = [self.context executeFetchRequest:request error:&err];
    if (fetchResults == nil) {
        DDLogError(@"DBController err when findAllTasksWithIndexHigherThan %d andLowerThan %d: %@", higherThan, lowerThan, [err localizedDescription]);
        forwardError(err, error);
        return nil;
    }

    return fetchResults;
}

- (BOOL)reorderTask:(STMTask *)task withIndex:(int)index error:(NSError **)error {
    int currentIndex = [[task index] intValue];
    int change = index - currentIndex;

    int lowerOne = currentIndex;
    int higherOne = index;
    int diff = 1;
    if(change > 0){
         lowerOne = currentIndex + 1;
        higherOne = index;
        diff = -1;
    } else {
        lowerOne = index;
        higherOne = currentIndex - 1;
        diff = 1;
    }

    DDLogInfo(@"reorderTask %d -> %d", currentIndex, index);


    NSError *err = nil;
    if(![self changeIndexBy:diff inAllTasksWithIndexHigherThan:(lowerOne - 1) butLowerThan:(higherOne+1) error:&err]){
        DDLogError(@"DBController err when reorderTask %d %d: %@", currentIndex, index, [err localizedDescription]);
        forwardError(err, error);
        return false;
    }

    DDLogInfo(@"---- FINALLY %d -> %d", currentIndex, index);
    task.index = [NSNumber numberWithInt:index];

    return true;
}

@end