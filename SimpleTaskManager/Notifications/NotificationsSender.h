//
// Created by Marek M on 15.01.2014.
// Copyright (c) 2014 Tomato. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface NotificationsSender : NSObject

+ (void)send:(NSString *)notificationKey from:(id)sender withData:(NSDictionary *)data;
+ (void)send:(NSString*) notificationKey withData:(NSDictionary*) data;
+ (void)send:(NSString *)notificationKey;

@end