//
// Created by Marek M on 23.03.2014.
// Copyright (c) 2014 Tomato. All rights reserved.
//

NSString * kJsonUIDKey = @"uid";
NSString * kJsonNameKey = @"name";
NSString * kJsonIndexKey = @"index";
NSString * kJsonNoUIDValue= @"nouid";


#import "STMTaskModel+JSONSerializer.h"
#import "NSError+Log.h"

@implementation STMTaskModel (JSONSerializer)

- (instancetype)initWithDictionary:(NSDictionary *) dictionary{
    self = [super init];
    if (self) {
        [self deserializeFromDictionary:dictionary];
    }

    return self;
}

-(NSData *) serializeToJSON{
    NSDictionary *dictionary = [self serializeToDictionary];
    if(![NSJSONSerialization isValidJSONObject:dictionary]){
        DDLogError(@"serializeToJSON dictionary %@ is not valid for json serialization", self.uid);
        return nil;
    }

    NSError *err = nil;
    NSData *result = [NSJSONSerialization dataWithJSONObject:dictionary options:0 error:&err];
    if(!result){
        DDLogError(@"serializeToJSON dataWithJSONObject failed %@", self.uid);
        [err log];
    }

    return result;
}

-(NSDictionary *)serializeToDictionary {
    NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
    if(self.uid){
        [dictionary setObject:self.uid forKey:kJsonUIDKey];
    } else {
        [dictionary setObject:kJsonNoUIDValue forKey:kJsonUIDKey];
    }

    if(self.name){
        [dictionary setObject:self.name forKey:kJsonNameKey];
    }

    if(self.index){
        [dictionary setObject:self.index forKey:kJsonIndexKey];
    }

    return [NSDictionary dictionaryWithDictionary:dictionary];
}

- (void)deserializeFromDictionary:(NSDictionary *)dictionary {
    if(!dictionary){
        DDLogWarn(@"deserializeFromDictionary but dictionary is nil");
        return;
    }

    self.uid = [dictionary objectForKey:kJsonUIDKey];
    self.name = [dictionary objectForKey:kJsonNameKey];
    self.index = [dictionary objectForKey:kJsonIndexKey];
}

@end