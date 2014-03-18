//
// Created by Marek M on 18.03.2014.
// Copyright (c) 2014 Tomato. All rights reserved.
//

#import <Foundation/Foundation.h>

@class RemoteLeg;
@protocol SyncingLegProtocol;


@interface RemoteConnection : NSObject

@property(nonatomic, weak) id<SyncingLegProtocol> localSync;

- (void)connect;
@end