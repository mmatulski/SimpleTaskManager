//
// Created by Marek M on 14.03.2014.
// Copyright (c) 2014 Tomato. All rights reserved.
//

#import "TheNewTaskHintView.h"


@implementation TheNewTaskHintView {

}
- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setCornersSize:4.0];
        [self roundLeftCorners];
    }

    return self;
}

@end