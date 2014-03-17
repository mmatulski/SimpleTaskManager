//
// Created by Marek M on 17.03.2014.
// Copyright (c) 2014 Tomato. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SingleOperation.h"


@interface AddTaskOperation : SingleOperation

@property(nonatomic, copy) NSString *taskName;
@property(nonatomic, strong) STMTask *createdTask;

- (instancetype)initWithTaskName:(NSString *)taskName;

@end