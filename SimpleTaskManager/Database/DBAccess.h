//
// Created by Marek M on 09.03.2014.
// Copyright (c) 2014 Tomato. All rights reserved.
//

#import <Foundation/Foundation.h>

@class DBController;


@interface DBAccess : NSObject

@property(readonly, nonatomic, strong) DBController* masterController;

@property(readonly, nonatomic, strong) DBController* mainQueueController;

+ (instancetype) sharedInstance;

+ (DBController *)createBackgroundController;

@end