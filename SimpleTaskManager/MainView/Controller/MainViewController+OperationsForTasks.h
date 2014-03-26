//
// Created by Marek M on 25.03.2014.
// Copyright (c) 2014 Tomato. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MainViewController.h"

@interface MainViewController (OperationsForTasks)

- (void)markSelectedTaskAsCompleted;

- (void)saveTaskWithName:(NSString *)name;

@end