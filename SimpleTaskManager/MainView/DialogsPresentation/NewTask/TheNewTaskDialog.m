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
        [self prepareTextView];
    }

    return self;
}

+ (Class)layerClass {
    return [CAGradientLayer class];
}

-(void) updateGradientInLayer:(CAGradientLayer *) gradientLayer{

    UIColor *colorOne = [UIColor colorWithHue:5.0/36.0 saturation:0.0 brightness:1.0 alpha:1.0];
    UIColor *colorTwo = [UIColor colorWithHue:5.0/36.0 saturation:0.0 brightness:0.95 alpha:1.0];
    UIColor *colorThree     = [UIColor colorWithHue:5.0/36.0 saturation:0.0 brightness:0.9 alpha:1.0];
    UIColor *colorFour = [UIColor colorWithHue:5.0/36.0 saturation:0.0 brightness:0.8 alpha:1.0];

    NSArray *colors =  [NSArray arrayWithObjects:(id)colorOne.CGColor, (id)colorTwo.CGColor, (id)colorThree.CGColor, (id)colorFour.CGColor, nil];

    NSNumber *stopOne = [NSNumber numberWithFloat:0.0];
    NSNumber *stopTwo = [NSNumber numberWithFloat:0.05];
    NSNumber *stopThree     = [NSNumber numberWithFloat:0.95];
    NSNumber *stopFour = [NSNumber numberWithFloat:1.0];

    NSArray *locations = [NSArray arrayWithObjects:stopOne, stopTwo, stopThree, stopFour, nil];

    gradientLayer.colors = colors;
    gradientLayer.locations = locations;
    gradientLayer.cornerRadius = 4.0;
}

-(void) updateLayer{
    [self updateGradientInLayer:[self gradientLayer]];
}

-(CAGradientLayer *) gradientLayer{
    return MakeSafeCast(self.layer, [CAGradientLayer class]);
}

- (void)prepareTextView {
    self.textView = [[UITextView alloc] initWithFrame:CGRectMake(10.0, 10.0, 100.0, 80.0)];
    self.textView.font = [UIFont fontWithName:@"HelveticaNeue" size:26.0];
    self.textView.backgroundColor = [UIColor clearColor];
    self.textView.textAlignment = NSTextAlignmentLeft;
    [self.textView setTranslatesAutoresizingMaskIntoConstraints:false];
    [self addSubview:self.textView];

    NSLayoutConstraint * H1 = [NSLayoutConstraint constraintWithItem:self.textView
                                                           attribute:NSLayoutAttributeLeading
                                                           relatedBy:NSLayoutRelationEqual
                                                              toItem:self
                                                           attribute:NSLayoutAttributeLeading
                                                          multiplier:1.0
                                                            constant:10.0];

    NSLayoutConstraint * H2 = [NSLayoutConstraint constraintWithItem:self.textView
                                                           attribute:NSLayoutAttributeTrailing
                                                           relatedBy:NSLayoutRelationEqual
                                                              toItem:self
                                                           attribute:NSLayoutAttributeTrailing
                                                          multiplier:1.0
                                                            constant:-10.0];

    NSLayoutConstraint * V1 = [NSLayoutConstraint constraintWithItem:self.textView
                                                           attribute:NSLayoutAttributeTop
                                                           relatedBy:NSLayoutRelationEqual
                                                              toItem:self
                                                           attribute:NSLayoutAttributeTop
                                                          multiplier:1.0
                                                            constant:15.0];

    NSLayoutConstraint * V2 = [NSLayoutConstraint constraintWithItem:self.textView
                                                           attribute:NSLayoutAttributeHeight
                                                           relatedBy:NSLayoutRelationEqual
                                                              toItem:self
                                                           attribute:NSLayoutAttributeHeight
                                                          multiplier:1.0
                                                            constant:-30.0];

    [self addConstraints:@[H1,H2,V1,V2]];
}

- (void)setEditing {
    [self.textView becomeFirstResponder];
}

- (BOOL)isNameValid {
    return [[self taskName]length] > 0;
}

- (NSString *)taskName {
    return self.textView.text;
}
@end