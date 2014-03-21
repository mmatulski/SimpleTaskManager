//
// Created by Marek M on 15.01.2014.
// Copyright (c) 2014 Tomato. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString * const NTFKEY_REMOTE_SYNC_STARTED;
extern NSString * const NTFKEY_REMOTE_SYNC_FINISHED;

@interface CommonNotifications : NSObject

+(void) remoteSyncStarted;
+(void) remoteSyncFinished;

@end