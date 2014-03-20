//
// Created by Marek M on 09.03.2014.
// Copyright (c) 2014 Tomato. All rights reserved.
//

#import <Foundation/Foundation.h>

@class DBController;

@interface DBAccess : NSObject

@property(readonly, nonatomic, strong) DBController* masterControllerOnBackground;

@property(readonly, nonatomic, strong) DBController* controllerOnMainQueue;

+ (instancetype) sharedInstance;

+ (DBController *)createBackgroundWorker;

@end