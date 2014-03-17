//
// Created by Marek M on 16.03.2014.
// Copyright (c) 2014 Tomato. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DBController.h"

@class STMTask;

@interface DBController (Internal)
- (STMTask *)findTaskWithId:(NSString *)uid error:(NSError **)error;

- (NSFetchRequest *)prepareTaskFetchRequest;

- (BOOL)removeTask:(STMTask *)task error:(NSError **)error;

- (BOOL)reorderTask:(STMTask *)task withIndex:(int)index error:(NSError **)error;
@end