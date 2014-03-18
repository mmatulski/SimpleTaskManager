//
// Created by Marek M on 18.03.2014.
// Copyright (c) 2014 Tomato. All rights reserved.
//

#import <Foundation/Foundation.h>

@class RemoteLeg;
@class SyncingLeg;
@protocol SyncingLegProtocol;
@class RemoteConnection;


@interface RemoteActionsHandler : NSObject

@property(nonatomic, weak) RemoteLeg * remoteLeg;

@property(nonatomic, strong) RemoteConnection *connection;

- (void)connect;

@end