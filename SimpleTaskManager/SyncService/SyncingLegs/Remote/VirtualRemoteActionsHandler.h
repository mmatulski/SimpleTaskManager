//
// Created by Marek M on 18.03.2014.
// Copyright (c) 2014 Tomato. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RemoteActionsHandler.h"


@interface VirtualRemoteActionsHandler : RemoteActionsHandler

@property(nonatomic) NSTimeInterval timerInterval;

@property(nonatomic, strong) NSTimer *timer;

- (void)generateActionsForTasks:(NSArray *)array;
@end