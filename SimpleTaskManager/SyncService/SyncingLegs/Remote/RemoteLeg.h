//
// Created by Marek M on 17.03.2014.
// Copyright (c) 2014 Tomato. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SyncingLeg.h"

@class RemoteActionsHandler;


@interface RemoteLeg : SyncingLeg

@property(nonatomic, strong) RemoteActionsHandler *remoteActionsHandler;

- (void) connect;

- (void)disconnect;

- (BOOL)isConnected;

@end