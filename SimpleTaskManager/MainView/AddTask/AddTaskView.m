//
// Created by Marek M on 11.03.2014.
// Copyright (c) 2014 Tomato. All rights reserved.
//

#import "AddTaskView.h"



@implementation AddTaskView {

}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        //self.backgroundColor = [UIColor redColor];

        [self createGradientLayer];

       // [self setTranslatesAutoresizingMaskIntoConstraints:NO];
    }

    return self;
}



- (void)layoutSublayersOfLayer:(CALayer *)layer {
    [super layoutSublayersOfLayer:layer];

    if(!self.bgLayer){
        [self.bgLayer removeFromSuperlayer];
        [self createGradientLayer];
    }


    self.bgLayer.frame = self.bounds;
}

- (void)createGradientLayer {
    self.bgLayer = [self prepareGradient];
    self.bgLayer.frame = self.bounds;
    [self.layer insertSublayer:self.bgLayer atIndex:0];
}

- (CAGradientLayer*) prepareGradient {

    UIColor *colorOne = [UIColor colorWithHue:5.0/36.0 saturation:7.0 brightness:1.0 alpha:1.0];
    UIColor *colorTwo = [UIColor colorWithHue:5.0/36.0 saturation:7.0 brightness:0.95 alpha:1.0];
    UIColor *colorThree     = [UIColor colorWithHue:5.0/36.0 saturation:7.0 brightness:0.9 alpha:1.0];
    UIColor *colorFour = [UIColor colorWithHue:5.0/36.0 saturation:7.0 brightness:0.8 alpha:1.0];

    NSArray *colors =  [NSArray arrayWithObjects:(id)colorOne.CGColor, colorTwo.CGColor, colorThree.CGColor, colorFour.CGColor, nil];

    NSNumber *stopOne = [NSNumber numberWithFloat:0.0];
    NSNumber *stopTwo = [NSNumber numberWithFloat:0.05];
    NSNumber *stopThree     = [NSNumber numberWithFloat:0.95];
    NSNumber *stopFour = [NSNumber numberWithFloat:1.0];

    NSArray *locations = [NSArray arrayWithObjects:stopOne, stopTwo, stopThree, stopFour, nil];
    CAGradientLayer *headerLayer = [CAGradientLayer layer];
    headerLayer.colors = colors;
    headerLayer.locations = locations;

    return headerLayer;

}

@end