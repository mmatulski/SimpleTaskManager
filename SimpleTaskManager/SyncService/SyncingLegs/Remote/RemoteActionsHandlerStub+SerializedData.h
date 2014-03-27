//
// Created by Marek M on 27.03.2014.
// Copyright (c) 2014 Tomato. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RemoteActionsHandlerStub.h"

@interface RemoteActionsHandlerStub (SerializedData)
- (NSArray *)deserializeTasksFromJsonData:(NSData *)data;

- (NSData *)serializedTaskModels:(NSArray *)tasksModels;
@end