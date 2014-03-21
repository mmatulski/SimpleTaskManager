//
// Created by Marek M on 16.03.2014.
// Copyright (c) 2014 Tomato. All rights reserved.
//

#import "DBController+Internal.h"
#import "STMTask.h"


@implementation DBController (Internal)

#pragma mark - basic methods

- (STMTask *)addTaskWithName:(NSString *)name withUid:(NSString *) uid withIndex:(NSNumber *) indexNumber{
    [self loadNumberOfAllTasksIfNotLoaded];

    STMTask *task = (STMTask *)[NSEntityDescription insertNewObjectForEntityForName:kSTMTaskEntityName inManagedObjectContext:self.context];
    task.name = [name copy];
    if(uid){
        //this case means that task was added on remote side
        task.uid = uid;
    } else {
        task.uid = [[NSUUID UUID] UUIDString];
    }

    //order is inversely proportional to index value
    task.index = [NSNumber numberWithUnsignedInt:++self.numberOfAllTasks];
    return task;
}

- (BOOL) markAsCompletedTaskWithId:(NSString *)uid error:(NSError **) error {
    [self loadNumberOfAllTasksIfNotLoaded];

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

- (STMTask *)reorderTaskWithId:(NSString *)uid toIndex:(NSInteger)index error:(NSError **) error {
    [self loadNumberOfAllTasksIfNotLoaded];

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
    [self loadNumberOfAllTasksIfNotLoaded];

    NSNumber *indexNumber =  task.index;
    int indexOfTaskToRemove = [indexNumber integerValue];

    [self.context deleteObject:task];

    self.numberOfAllTasks--;

    NSError *err = nil;
    if(![self changeIndexBy:-1 inAllTaskWithIndexGreaterThan:indexOfTaskToRemove error:&err]){
        DDLogError(@"DBController err when removeTask %d: %@", indexOfTaskToRemove, [err localizedDescription]);
        forwardError(err, error);
        return false;
    }

    return true;
}

- (BOOL)changeIndexBy:(NSInteger)change inAllTaskWithIndexGreaterThan:(NSInteger)relatedOrder error:(NSError **)error {
    [self loadNumberOfAllTasksIfNotLoaded];

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

- (BOOL)changeIndexBy:(NSInteger)change inAllTasksWithIndexHigherThan:(NSInteger)higherThan butLowerThan:(NSInteger)lowerThan error:(NSError **)error {
    [self loadNumberOfAllTasksIfNotLoaded];

    DDLogTrace(@"changeIndexBy %d  higherThan %d lowerThan %d", change, higherThan, lowerThan);

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

- (void)changeIndexBy:(NSInteger)change inTask:(STMTask *)task {
    [self loadNumberOfAllTasksIfNotLoaded];

    NSNumber *indexNumber =  task.index;
    NSInteger index = [indexNumber integerValue];
    NSInteger theNewIndex = index + change;

    if(theNewIndex < 1){
        //TODO
        //it is only index so maybe there is no need to do anything
        //one solution can be setting flag . i.e. needsOrdersRework which will cause estimating orders again
        DDLogWarn(@"changeIndexBy error: the new index for task %@ is not valid %d less than 0", task.uid, theNewIndex);
        theNewIndex = 1;
    } else if(theNewIndex > self.numberOfAllTasks){
        //TODO
        //it is only index so maybe there is no need to do anything
        //one solution can be setting flag . i.e. needsOrdersRework which will cause estimating orders again
        DDLogWarn(@"changeIndexBy error: the new index for task %@ is not valid %d greater than %d", task.uid, theNewIndex, self.numberOfAllTasks);
        theNewIndex = self.numberOfAllTasks;
    }

    NSNumber *changedIndexNumber = [NSNumber numberWithInteger:theNewIndex];

    DDLogTrace(@"----- change [%@] %d  from %d to %d", task.name ,change, index, theNewIndex);

    task.index = changedIndexNumber;
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

- (NSArray *) findAllTasksWithIndexHigherThan:(NSInteger)higherThan andLowerThan:(NSInteger) lowerThan error:(NSError **)error {

    NSFetchRequest *request = [self prepareTaskFetchRequest];

    NSString *predicateString = [NSString stringWithFormat:@"(index > %d) AND (index < %d)", higherThan, lowerThan];
    DDLogTrace(@"findAllTasksWithIndexHigherThan higherThan %d lowerThan %d [%@]", higherThan, lowerThan, predicateString);
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

- (BOOL)reorderTask:(STMTask *)task withIndex:(NSInteger)index error:(NSError **)error {
    NSInteger currentIndex = [[task index] integerValue];
    NSInteger change = index - currentIndex;

    NSInteger lowerOne;
    NSInteger higherOne;
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

    DDLogTrace(@"reorderTask %d -> %d", currentIndex, index);


    NSError *err = nil;
    if(![self changeIndexBy:diff inAllTasksWithIndexHigherThan:(lowerOne - 1) butLowerThan:(higherOne+1) error:&err]){
        DDLogError(@"DBController err when reorderTask %d %d: %@", currentIndex, index, [err localizedDescription]);
        forwardError(err, error);
        return false;
    }

    DDLogTrace(@"---- FINALLY %d -> %d", currentIndex, index);
    task.index = [NSNumber numberWithInteger:index];

    return true;
}

- (void) loadNumberOfAllTasksIfNotLoaded {
    if(!_numberOfAllTasksEstimated){
        BlockWeakSelf selfWeak = self;
        [self.context performBlockAndWait:^{
            NSFetchRequest *request = [[NSFetchRequest alloc] init];
            [request setEntity:[NSEntityDescription entityForName:kSTMTaskEntityName
                                           inManagedObjectContext:selfWeak.context]];
            [request setIncludesSubentities:NO];

            NSError *err;
            NSUInteger count = [selfWeak.context countForFetchRequest:request error:&err];
            if(count == NSNotFound) {
                DDLogError(@"There was problem with loading number of all tasks %@", [err localizedDescription]);
            } else {
                self.numberOfAllTasks = count;
                _numberOfAllTasksEstimated = true;

                DDLogInfo(@"number of all Tasks is %u", self.numberOfAllTasks);
            }
        }];
    }
}

@end