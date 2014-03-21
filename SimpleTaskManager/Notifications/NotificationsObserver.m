//
// Created by Marek M on 16.01.2014.
// Copyright (c) 2014 Tomato. All rights reserved.
//

#import "NotificationsObserver.h"


@implementation NotificationsObserver {

}

- (id)init {
    self = [super init];
    if (self) {
        self.notificationsKeys = [[NSMutableArray alloc] init];
    }

    return self;
}

- (instancetype)initWithNotificationsKeys:(NSArray *)notificationsKeys {
    self = [super init];
    if (self) {
        self.notificationsKeys = [notificationsKeys mutableCopy];
        [self startListening];
    }

    return self;
}


- (void)startListenNotification:(NSString *)notificationKey {
    if(notificationKey){
        [self listenNotification:notificationKey];
        [self.notificationsKeys addObject:notificationKey];
    }
}

- (void)listenNotification:(NSString *)notificationKey {
    [[NSNotificationCenter defaultCenter] addObserver: self selector:@selector(notificationArrived:)
                                                     name: notificationKey object: nil];
}

- (void)notificationArrived:(NSNotification*) notification {

}

-(void) startListening{
    for(NSString *notificationKey in self.notificationsKeys){
        [self listenNotification:notificationKey];
    }
}

- (void) stopListening {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


- (void)dealloc {
    [self stopListening];
}

- (NSObject *)objectForKey:(NSString *)paramKey fromNotification:(NSNotification *)notification {
    return [[notification userInfo] objectForKey:paramKey];
}
@end