//
// Created by Marek M on 13.03.2014.
// Copyright (c) 2014 Tomato. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface CGEstimations : NSObject

+ (CGPoint)centerOfRect:(CGRect)rect;

+(CGFloat)pointDistanceToCenterOfAxis:(CGPoint) point;

@end