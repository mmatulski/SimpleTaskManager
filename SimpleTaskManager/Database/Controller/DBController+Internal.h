//
// Created by Marek M on 16.03.2014.
// Copyright (c) 2014 Tomato. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DBController.h"

@class STMTask;

@interface DBController (Internal)

#pragma mark Basic methods

- (STMTask *)addTaskWithName:(NSString *)name withUid:(NSString *)uid withIndex:(NSNumber *)indexNumber;

- (BOOL)markAsCompletedTaskWithId:(NSString *)uid error:(NSError **)error;

- (STMTask *)renameTaskWithId:(NSString *)uid withName:(NSString *)theNewName error:(NSError **)error;

- (STMTask *)reorderTaskWithId:(NSString *)uid toIndex:(int)index1 error:(NSError **)error;

- (STMTask *)findTaskWithId:(NSString *)uid error:(NSError **)error;

- (NSFetchRequest *)prepareTaskFetchRequest;

- (BOOL)removeTask:(STMTask *)task error:(NSError **)error;

- (NSArray *)fetchAllTasks:(NSError **)error;

- (BOOL)reorderTask:(STMTask *)task withIndex:(int)index error:(NSError **)error;
@end