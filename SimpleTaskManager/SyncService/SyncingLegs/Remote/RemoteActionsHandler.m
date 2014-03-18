//
// Created by Marek M on 18.03.2014.
// Copyright (c) 2014 Tomato. All rights reserved.
//

#import "RemoteActionsHandler.h"
#import "RemoteConnection.h"

@implementation RemoteActionsHandler {

}
- (void)connect {
    [self prepareConnection];
    [self.connection connect];
}

- (void)prepareConnection {
    self.connection = [[RemoteConnection alloc] init];
}

@end