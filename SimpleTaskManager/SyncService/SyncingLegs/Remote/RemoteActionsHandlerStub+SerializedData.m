//
// Created by Marek M on 27.03.2014.
// Copyright (c) 2014 Tomato. All rights reserved.
//

#import "RemoteActionsHandlerStub+SerializedData.h"
#import "NSError+Log.h"
#import "STMTaskModel+JSONSerializer.h"


@implementation RemoteActionsHandlerStub (SerializedData)

- (NSArray *)deserializeTasksFromJsonData:(NSData *)data {

    if (!data) {
        DDLogError(@"deserializeTasksFromData data are nil");
        return nil;
    }

    NSString *stringWithData = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    DDLogTrace(@"deserializeTasksFromData string %@", stringWithData);

    NSError *err;
    NSArray *deserializedArrayOfSerializedTaskModels = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&err];
    if (!deserializedArrayOfSerializedTaskModels) {
        return nil;
    }

    NSArray *arrayOfTaskModels = [self deserializeTaskModelsFromArray:deserializedArrayOfSerializedTaskModels];
    if (!arrayOfTaskModels) {
        DDLogError(@"deserializeTasksFromData deserializedArrayOfSerializedTaskModels can not be deserialized");
    }

    return arrayOfTaskModels;
}

- (NSArray *)deserializeTaskModelsFromArray:(NSArray *)arrayOfSerializedTaskModels {

    if (!arrayOfSerializedTaskModels) {
        DDLogWarn(@"deserializeTaskModelsFromArray array is empty");
        return nil;
    }

    NSMutableArray *result = [[NSMutableArray alloc] init];

    for (NSDictionary *taskModelDictionary in arrayOfSerializedTaskModels) {
        STMTaskModel *taskModel = [[STMTaskModel alloc] initWithDictionary:taskModelDictionary];
        if (taskModel) {
            [result addObject:taskModel];
        }
    }

    return [NSArray arrayWithArray:result];
}

- (NSArray *)arrayOfSerializedTasksModels:(NSArray *)tasksModels {
    NSSortDescriptor *sortByUid = [[NSSortDescriptor alloc]
            initWithKey:@"uid" ascending:NO];

    NSArray *tasksSortedByUid = [tasksModels sortedArrayUsingDescriptors:@[sortByUid]];

    NSMutableArray *result = [[NSMutableArray alloc] init];

    NSEnumerator *sortedTasksEnumerator = [tasksSortedByUid objectEnumerator];
    STMTaskModel *model = [sortedTasksEnumerator nextObject];
    while (model) {
        //NSData *serializedModel = [model serializeToJSON];
        NSDictionary *serializedModel = [model serializeToDictionary];
        if (serializedModel) {
            [result addObject:serializedModel];
        }

        model = [sortedTasksEnumerator nextObject];
    }

    return [NSArray arrayWithArray:result];
}

- (NSData *)serializedTaskModels:(NSArray *)tasksModels {
    NSArray *arrayWithSerializedModels = [self arrayOfSerializedTasksModels:tasksModels];
    if (!arrayWithSerializedModels) {
        DDLogError(@"serializedTaskModels array is empty");
        return nil;
    }

    if (![NSJSONSerialization isValidJSONObject:arrayWithSerializedModels]) {
        DDLogError(@"serializedTaskModels array is not valid");
    }

    NSError *err = nil;
    NSData *result = [NSJSONSerialization dataWithJSONObject:arrayWithSerializedModels options:0 error:&err];
    if (!result) {
        DDLogError(@"serializedTaskModels serialization failed");
        [err log];
    }

    return result;
}

@end