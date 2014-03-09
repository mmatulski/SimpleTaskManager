//
// Created by Marek M on 09.03.2014.
// Copyright (c) 2014 Tomato. All rights reserved.
//

#import "AppMacros.h"

inline id MakeSafeCast(id object, Class targetClass) {
    if(targetClass && object){
        return [object isKindOfClass:targetClass] ? object : nil;
    }

    return nil;
}