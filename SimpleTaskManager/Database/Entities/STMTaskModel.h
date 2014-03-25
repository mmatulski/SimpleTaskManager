//
// Created by Marek M on 18.03.2014.
// Copyright (c) 2014 Tomato. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "STMTaskModifcationType.h"

@class STMTask;

@interface STMTaskModel : NSObject

@property (nonatomic, copy) NSString * name;
@property (nonatomic, copy) NSString * uid;
@property (nonatomic, strong) NSNumber * index;
@property (nonatomic, strong) NSManagedObjectID * objectId;

@property(nonatomic) BOOL completedByUser; //it means "to remove"
@property (nonatomic) STMTaskModificationType modificationType;

- (instancetype)initWithName:(NSString *)name uid:(NSString *)uid index:(NSNumber *)index;
- (instancetype)initWitTask:(STMTask *) task;

@end