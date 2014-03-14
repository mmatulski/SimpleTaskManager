//
// Created by Marek M on 11.03.2014.
// Copyright (c) 2014 Tomato. All rights reserved.
//

#import "TheNewTaskDialog.h"



@implementation TheNewTaskDialog {

}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self updateLayer];
    }

    return self;
}

+ (Class)layerClass {
    return [CAGradientLayer class];
}

-(void) updateGradientInLayer:(CAGradientLayer *) gradientLayer{

    UIColor *colorOne = [UIColor colorWithHue:5.0/36.0 saturation:7.0 brightness:1.0 alpha:1.0];
    UIColor *colorTwo = [UIColor colorWithHue:5.0/36.0 saturation:7.0 brightness:0.95 alpha:1.0];
    UIColor *colorThree     = [UIColor colorWithHue:5.0/36.0 saturation:7.0 brightness:0.9 alpha:1.0];
    UIColor *colorFour = [UIColor colorWithHue:5.0/36.0 saturation:7.0 brightness:0.8 alpha:1.0];

    NSArray *colors =  [NSArray arrayWithObjects:(id)colorOne.CGColor, (id)colorTwo.CGColor, (id)colorThree.CGColor, (id)colorFour.CGColor, nil];

    NSNumber *stopOne = [NSNumber numberWithFloat:0.0];
    NSNumber *stopTwo = [NSNumber numberWithFloat:0.05];
    NSNumber *stopThree     = [NSNumber numberWithFloat:0.95];
    NSNumber *stopFour = [NSNumber numberWithFloat:1.0];

    NSArray *locations = [NSArray arrayWithObjects:stopOne, stopTwo, stopThree, stopFour, nil];

    gradientLayer.colors = colors;
    gradientLayer.locations = locations;
}

-(void) updateLayer{
    [self updateGradientInLayer:[self gradientLayer]];
}

-(CAGradientLayer *) gradientLayer{
    return MakeSafeCast(self.layer, [CAGradientLayer class]);
}

@end