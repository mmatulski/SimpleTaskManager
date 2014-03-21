//
// Created by Marek M on 21.03.2014.
// Copyright (c) 2014 Tomato. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SyncNotificationsObserver.h"

@class MainTableDataSource;


@interface MainTableDataSourceNotificationsObserver : SyncNotificationsObserver

@property(nonatomic, weak) MainTableDataSource *mainTableDataSource;

- (instancetype)initWithMainTableDataSource:(MainTableDataSource *)mainTableDataSource;

@end