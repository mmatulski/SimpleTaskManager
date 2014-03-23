//
// Created by Marek M on 16.03.2014.
// Copyright (c) 2014 Tomato. All rights reserved.
//

#import "DBController+Internal.h"
#import "STMTask.h"


@implementation DBController (Internal)

#pragma mark - basic methods

- (STMTask *)addTaskWithName:(NSString *)name withUid:(NSString *) uid withIndex:(NSNumber *) indexNumber{
    STMTask *task = (STMTask *)[NSEntityDescription insertNewObjectForEntityForName:kSTMTaskEntityName inManagedObjectContext:self.context];
    task.name = [name copy];
    if(uid){
        //this case means that task was added on remote side
        task.uid = uid;
    } else {
        task.uid = [[NSUUID UUID] UUIDString];
    }

    if(indexNumber){
        task.index = indexNumber;
        //TODO needs reordering
    }

    //order is inversely proportional to index value

    [self increaseNumberOfAllTasks];
    task.index = [NSNumber numberWithUnsignedInteger:self.numberOfAllTasks];
    return task;
}



- (BOOL) markAsCompletedTaskWithId:(NSString *)uid error:(NSError **) error {
    NSError *err = nil;
    STMTask *task = [self findTaskWithId:uid error:&err];
    if (!task) {
        forwardError(err, error);
        return false;
    }

    if([self removeTask:task error:&err]){
       return true;
    } else {
        forwardError(err, error);
        return false;
    }
}

- (STMTask *)renameTaskWithId:(NSString *)uid withName:(NSString *)theNewName error:(NSError **)error {
    NSError *err = nil;
    STMTask *task = [self findTaskWithId:uid error:&err];
    if (!task) {
        forwardError(err, error);
        return nil;
    }

    task.name = theNewName;

    return task;
}

- (STMTask *)reorderTaskWithId:(NSString *)uid toIndex:(NSUInteger)index error:(NSError **) error {
    NSError *err = nil;
    STMTask *task = [self findTaskWithId:uid error:&err];
    if (!task) {
        forwardError(err, error);
        return nil;
    }

    if([self reorderTask:task withIndex:index error:&err]){
        return task;
    } else {
        forwardError(err, error);
       return nil;
    }
}


#pragma mark -

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
    NSUInteger indexOfTaskToRemove = [indexNumber unsignedIntegerValue];

    [self.context deleteObject:task];

    [self decreaseNumberOfAllTasks];

    NSError *err = nil;
    if(![self changeIndexBy:-1 inAllTaskWithIndexGreaterThan:indexOfTaskToRemove error:&err]){
        DDLogError(@"DBController err when removeTask %d: %@", (uint32_t)indexOfTaskToRemove, [err localizedDescription]);
        forwardError(err, error);
        return false;
    }

    return true;
}

- (BOOL)changeIndexBy:(NSInteger)change inAllTaskWithIndexGreaterThan:(NSUInteger)relatedOrder error:(NSError **)error {
    NSError *err = nil;
    NSArray * tasks = [self findAllTasksWithIndexHigherThan:relatedOrder error:&err];

    if(!tasks){
        DDLogError(@"DBController err when changeIndexBy inAllTaskWithIndexGreaterThan  %td: %@", relatedOrder, [err localizedDescription]);
        forwardError(err, error);
        return false;
    }

    for (STMTask *task in tasks){
        [self changeIndexBy:change inTask:task];
    }

    return true;
}

- (BOOL)changeIndexBy:(NSInteger)change inAllTasksWithIndexHigherThan:(NSUInteger)higherThan butLowerThan:(NSUInteger)lowerThan error:(NSError **)error {
    DDLogTrace(@"changeIndexBy %zd  higherThan %td lowerThan %td", change, higherThan, lowerThan);

    NSError *err = nil;
    NSArray * tasks = [self findAllTasksWithIndexHigherThan:higherThan andLowerThan:lowerThan error:&err];

    if(!tasks){
        DDLogError(@"DBController err when changeIndexBy inAllTasksWithIndexHigherThan %td - %td: %@", higherThan, lowerThan, [err localizedDescription]);
        forwardError(err, error);
        return false;
    }

    for (STMTask *task in tasks){
        [self changeIndexBy:change inTask:task];
    }

    return true;
}

- (void)changeIndexBy:(NSInteger)change inTask:(STMTask *)task {
    NSNumber *indexNumber =  task.index;
    NSUInteger index = [indexNumber unsignedIntegerValue];
    NSUInteger theNewIndex = index + change;

    if(theNewIndex < 1){
        //TODO
        //it is only index so maybe there is no need to do anything
        //one solution can be setting flag . i.e. needsOrdersRework which will cause estimating orders again
        DDLogWarn(@"changeIndexBy error: the new index for task %@ is not valid %td less than 0", task.uid, theNewIndex);
        theNewIndex = 1;
    } else if(theNewIndex > self.numberOfAllTasks){
        //TODO
        //it is only index so maybe there is no need to do anything
        //one solution can be setting flag . i.e. needsOrdersRework which will cause estimating orders again
        DDLogWarn(@"changeIndexBy error: the new index for task %@ is not valid %td greater than %td", task.uid, theNewIndex, self.numberOfAllTasks);
        theNewIndex = self.numberOfAllTasks;
    }

    NSNumber *changedIndexNumber = [NSNumber numberWithUnsignedInteger:theNewIndex];

    DDLogTrace(@"----- change [%@] %zd  from %td to %td", task.name ,change, index, theNewIndex);

    task.index = changedIndexNumber;
}

- (NSArray *)findAllTasksWithIndexHigherThan:(NSUInteger)relatedOrder error:(NSError **)error {

    NSFetchRequest *request = [self prepareTaskFetchRequest];

    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(index > %d)", relatedOrder];
    [request setPredicate:predicate];

    NSError *err = nil;
    NSArray *fetchResults = [self.context executeFetchRequest:request error:&err];
    if (fetchResults == nil) {
        DDLogError(@"DBController err when findAllTasksWithIndexHigherThan %td: %@", relatedOrder, [err localizedDescription]);
        forwardError(err, error);
        return nil;
    }

    return fetchResults;
}

- (NSArray *) findAllTasksWithIndexHigherThan:(NSUInteger)higherThan andLowerThan:(NSUInteger) lowerThan error:(NSError **)error {

    NSFetchRequest *request = [self prepareTaskFetchRequest];

    NSString *predicateString = [NSString stringWithFormat:@"(index > %td) AND (index < %td)", higherThan, lowerThan];
    DDLogTrace(@"findAllTasksWithIndexHigherThan higherThan %td lowerThan %td [%@]", higherThan, lowerThan, predicateString);
    NSPredicate *predicate = [NSPredicate predicateWithFormat:predicateString];
    [request setPredicate:predicate];

    NSError *err = nil;
    NSArray *fetchResults = [self.context executeFetchRequest:request error:&err];
    if (fetchResults == nil) {
        DDLogError(@"DBController err when findAllTasksWithIndexHigherThan %td andLowerThan %td: %@", higherThan, lowerThan, [err localizedDescription]);
        forwardError(err, error);
        return nil;
    }

    return fetchResults;
}

- (NSArray *) fetchAllTasks:(NSError **) error {
    NSFetchRequest *request = [self prepareTaskFetchRequest];

    NSError *err = nil;
    NSArray *fetchResults = [self.context executeFetchRequest:request error:&err];
    if (fetchResults == nil) {
        DDLogError(@"DBController err when fetchAllTasks %@", [err localizedDescription]);
        forwardError(err, error);
        return nil;
    }

    return fetchResults;
}

- (BOOL)reorderTask:(STMTask *)task withIndex:(NSUInteger)index error:(NSError **)error {

    NSUInteger currentIndex = [[task index] unsignedIntegerValue];
    NSInteger change = (NSInteger) index - (NSInteger) currentIndex;

    NSUInteger lowerOne;
    NSUInteger higherOne;
    NSInteger diff;
    if(change > 0){
         lowerOne = currentIndex + 1;
        higherOne = index;
        diff = -1;
    } else {
        lowerOne = index;
        higherOne = currentIndex - 1;
        diff = 1;
    }

    DDLogInfo(@"reorderTask %td -> %td", currentIndex, index);


    NSError *err = nil;
    if(![self changeIndexBy:diff inAllTasksWithIndexHigherThan:(lowerOne - 1) butLowerThan:(higherOne+1) error:&err]){
        DDLogError(@"DBController err when reorderTask %td %td: %@", currentIndex, index, [err localizedDescription]);
        forwardError(err, error);
        return false;
    }

    DDLogTrace(@"---- FINALLY %td -> %td", currentIndex, index);
    task.index = [NSNumber numberWithInteger:index];

    return true;
}

@end