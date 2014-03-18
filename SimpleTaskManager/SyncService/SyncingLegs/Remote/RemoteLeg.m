//
// Created by Marek M on 17.03.2014.
// Copyright (c) 2014 Tomato. All rights reserved.
//

#import "RemoteLeg.h"
#import "SingleOperation.h"
#import "RemoteActionsHandler.h"
#import "VirtualRemoteActionsHandler.h"


@implementation RemoteLeg {

}

- (void)connect {
    self.remoteActionsHandler = [[VirtualRemoteActionsHandler alloc] init];
    self.remoteActionsHandler.remoteLeg = self;
    [self.remoteActionsHandler connect];
}

- (void)operationFinished:(SingleOperation *)operation {

}


@end