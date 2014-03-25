//
// Created by Marek M on 17.03.2014.
// Copyright (c) 2014 Tomato. All rights reserved.
//

#import "RemoteLeg.h"
#import "SingleOperation.h"
#import "RemoteActionsHandler.h"
#import "MockedRemoteActionsHandler.h"
#import "SyncGuardService.h"


@implementation RemoteLeg {

}

- (void)connect {
    self.remoteActionsHandler = [[MockedRemoteActionsHandler alloc] init];
    self.remoteActionsHandler.remoteLeg = self;
    [self.remoteActionsHandler connect];
}

- (void)disconnect {
    [self.remoteActionsHandler disconnect];
}

- (BOOL) isConnected {
    return [self.remoteActionsHandler isConnected];
}

@end