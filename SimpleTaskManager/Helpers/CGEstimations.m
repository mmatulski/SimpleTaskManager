//
// Created by Marek M on 13.03.2014.
// Copyright (c) 2014 Tomato. All rights reserved.
//

#import "CGEstimations.h"


@implementation CGEstimations {

}

+(CGPoint) centerOfRect:(CGRect) rect{
    return CGPointMake(rect.origin.x + rect.size.width / 2, rect.origin.y + rect.size.height / 2);
}

+ (CGFloat)pointDistanceToCenterOfAxis:(CGPoint)point {
    return sqrtf(point.x * point.x + point.y * point.y);
}


@end