//
// Created by Marek M on 14.03.2014.
// Copyright (c) 2014 Tomato. All rights reserved.
//

#import "MiniHintView.h"


@implementation MiniHintView {

}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
    }

    return self;
}

- (void) buttonSelected {
    if(self.target && self.action){
        if([self.target respondsToSelector:self.action]){
            [self.target performSelector:self.action];
        }
    }
}

@end