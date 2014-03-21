//
// Created by Marek M on 16.01.2014.
// Copyright (c) 2014 Tomato. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface NotificationsObserver : NSObject

@property(nonatomic, strong) NSMutableArray *notificationsKeys;

- (instancetype)initWithNotificationsKeys:(NSArray *)notificationsKeys;

-(void)startListenNotification:(NSString *) notificationKey;
- (void) startListening;

- (NSObject *)objectForKey:(NSString *)paramKey fromNotification:(NSNotification *)notification;

- (void) stopListening;

- (void) notificationArrived:(NSNotification *)notification;

@end