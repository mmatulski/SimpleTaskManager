//
// Created by Marek M on 14.03.2014.
// Copyright (c) 2014 Tomato. All rights reserved.
//

#import "WrappedButton.h"

@implementation WrappedButton {

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
        performSelectorIfRespondsToVoid(self.target, self.action);
    }
}

@end