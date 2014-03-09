//
// Created by Marek M on 09.03.2014.
// Copyright (c) 2014 Tomato. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface DBController : NSObject

@property(readonly, nonatomic, strong) NSManagedObjectContext *context;
@property(readonly, nonatomic, strong) DBController *parentController;

- (instancetype)initWithContext:(NSManagedObjectContext *)context;
- (instancetype)initWithParentController:(DBController *)parentController;
- (instancetype)initWithContext:(NSManagedObjectContext *)context parentController:(DBController *)parentController;

@end