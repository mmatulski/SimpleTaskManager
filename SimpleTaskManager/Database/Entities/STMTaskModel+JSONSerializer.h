//
// Created by Marek M on 23.03.2014.
// Copyright (c) 2014 Tomato. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "STMTaskModel.h"

@interface STMTaskModel (JSONSerializer)

- (instancetype)initWithDictionary:(NSDictionary *)dictionary;

- (NSData *)serializeToJSON;

- (NSDictionary *)serializeToDictionary;

@end