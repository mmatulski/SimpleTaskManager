//
// Created by Marek M on 15.01.2014.
// Copyright (c) 2014 Tomato. All rights reserved.
//

#import "NotificationsSender.h"


@implementation NotificationsSender {

}

+ (void)send:(NSString *)notificationKey from:(id)sender withData:(NSDictionary *)data {
    runOnMainThread(^{
        [[NSNotificationCenter defaultCenter] postNotificationName:notificationKey
                                                            object:sender
                                                          userInfo:data];
    });
}

+ (void)send:(NSString *)notificationKey withData:(NSDictionary *)data {
    runOnMainThread(^{
        [[NSNotificationCenter defaultCenter] postNotificationName:notificationKey
                                                            object:self
                                                          userInfo:data];
    });
}

+ (void)send:(NSString *)notificationKey{
    runOnMainThread(^{
        [[NSNotificationCenter defaultCenter] postNotificationName:notificationKey
                                                            object:self];
    });
}

@end