//
// Created by Marek M on 18.03.2014.
// Copyright (c) 2014 Tomato. All rights reserved.
//

#import <Foundation/Foundation.h>

@class STMTask;


@interface STMTaskModel : NSObject

@property (nonatomic, copy) NSString * name;
@property (nonatomic, copy) NSString * uid;
@property (nonatomic, strong) NSNumber * index;
@property (nonatomic, strong) NSManagedObjectID * objectId;

@property(nonatomic) bool completed;

- (instancetype)initWithName:(NSString *)name uid:(NSString *)uid index:(NSNumber *)index;
- (instancetype)initWitEntity:(STMTask *) task;

@end