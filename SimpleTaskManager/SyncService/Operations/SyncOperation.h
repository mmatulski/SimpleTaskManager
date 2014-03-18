//
// Created by Marek M on 18.03.2014.
// Copyright (c) 2014 Tomato. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SingleOperation.h"


@interface SyncOperation : SingleOperation

@property(nonatomic, strong) NSArray *addedTasks;
@property(nonatomic, strong) NSArray *removedTasks;
@property(nonatomic, strong) NSArray *renamedTasks;
@property(nonatomic, strong) NSArray *reorderedTasks;

@end