//
// Created by Marek M on 09.03.2014.
// Copyright (c) 2014 Tomato. All rights reserved.
//

inline id MakeSafeCast(id object, Class targetClass) {
    if(targetClass && object){
        return [object isKindOfClass:targetClass] ? object : nil;
    }

    return nil;
}

void forwardError(NSError *err, NSError **error) {
    if(error != NULL){
        *error = err;
    }
}

#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
inline id performSelectorIfRespondsTo(id object, SEL selector) {
    if ([object respondsToSelector:selector]){
        return [object performSelector:selector ];
    }
    return nil;
}

#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
inline void performSelectorIfRespondsToVoid(id object, SEL selector) {
    if ([object respondsToSelector:selector]){
        [object performSelector:selector ];
    }
}