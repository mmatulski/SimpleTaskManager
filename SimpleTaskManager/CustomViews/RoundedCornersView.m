//
//  RoundedCornersView.h
//
//  Created by Marek Matulski on 04.12.2011.
//  Copyright (c) 2011 Marek Matulski. All rights reserved.
//

#import "RoundedCornersView.h"
#import <QuartzCore/QuartzCore.h>

@implementation RoundedCornersView

-(instancetype) init{
    self = [super init];
    if (self) {
        [self prepareRoundedCorners];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self prepareRoundedCorners];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        // Initialization code
        [self prepareRoundedCorners];
    }
    return self;
}

-(void) prepareRoundedCorners{
    self.cornersSize = 11.0;
    corners = 0; //default is without corners
    //corners = UIRectCornerAllCorners;
    //[self updateCorners];
}

-(void) setFrame:(CGRect)_frame{
    [super setFrame:_frame];
    [self updateCorners];
}

- (void)setCornersSize:(CGFloat)cornersSize {
    _cornersSize = cornersSize;
    [self updateCorners];
}


-(void) roundTopCorners{
    corners = UIRectCornerTopLeft | UIRectCornerTopRight;    
    [self updateCorners];
}

-(void) roundBottomCorners{
    corners = UIRectCornerBottomLeft | UIRectCornerBottomRight;
    [self updateCorners];
}

-(void) roundLeftCorners{
    corners = UIRectCornerTopLeft | UIRectCornerBottomLeft;  
    [self updateCorners];
}

-(void) roundRightCorners{
    corners = UIRectCornerTopRight | UIRectCornerBottomRight;  
    [self updateCorners];
}

-(void) roundAllCorners{
    corners = UIRectCornerAllCorners;
    [self updateCorners];
}

-(void) donotRoundCorners{
    corners = 0;
    
    self.layer.mask = nil;

    [self updateCorners];
}

-(void) updateCorners{
    if (corners == 0) {
        self.layer.mask = nil;
        
    } else {
        UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:self.layer.bounds 
                                                       byRoundingCorners:corners
                                                             cornerRadii:CGSizeMake(self.cornersSize, self.cornersSize)];
        CAShapeLayer *maskLayer = [CAShapeLayer layer];
        maskLayer.frame = self.layer.bounds;
        maskLayer.path = maskPath.CGPath;
        
        self.layer.mask = maskLayer; 
    }
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
