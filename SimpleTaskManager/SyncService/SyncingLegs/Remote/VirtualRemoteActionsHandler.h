//
// Created by Marek M on 18.03.2014.
// Copyright (c) 2014 Tomato. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RemoteActionsHandler.h"


@interface VirtualRemoteActionsHandler : RemoteActionsHandler

@property NSTimeInterval timerInterval;
@property CGFloat changedItemsFactor;
@property CGFloat increaseFactor;


@property(nonatomic, strong) NSTimer *timer;

@property(nonatomic, strong) NSData *lastTimeChangedItemsJSON;

- (void)generateActionsForTasks:(NSArray *)array;

- (void)generateActionsForSerializedTasksUsedPreviously:(NSData *)data;
@end