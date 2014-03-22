//
// Created by Marek M on 15.03.2014.
// Copyright (c) 2014 Tomato. All rights reserved.
//

#import "DragAndDropHandler.h"
#import "UIView+ScreenshootExtension.h"

@implementation DragAndDropHandler {

}

- (instancetype)initWithDraggingSpace:(UIView *)draggingSpace {
    self = [super init];
    if (self) {
        self.draggingSpace = draggingSpace;
    }

    return self;
}


-(void) dragView:(UIView*) viewToDrag fromPoint: (CGPoint) point{

    if (viewToDrag) {
        CGPoint newCenter = [self.draggingSpace convertPoint:point fromView:nil];
        CGPoint popViewCenter = [self estimateCenterPointForPopingView:viewToDrag];

        CALayer *highLightLayer = [CALayer layer];
        highLightLayer.backgroundColor = [UIColor colorWithRed:1.0 green:0.9 blue:0.0 alpha:0.5].CGColor;
        highLightLayer.frame = viewToDrag.layer.bounds;
        [viewToDrag.layer addSublayer:highLightLayer];
        UIImageView*screenShotOfDraggedView = [[UIImageView alloc] initWithImage:[viewToDrag screenshotWithWidth:250.f]];
        [highLightLayer removeFromSuperlayer];

        self.draggedView = screenShotOfDraggedView;

        self.draggedView.center = popViewCenter;
        [self.draggingSpace addSubview:self.draggedView];

        [self setDraggingStyleInDraggedView];

        [UIView animateWithDuration:0.2 animations:^{
            self.draggedView.transform = CGAffineTransformMakeScale( 1.0, 1.0 );
            self.draggedView.alpha = 0.7;
            self.draggedView.center = newCenter;
        } completion:^(BOOL finished) {

        }];

        [self moveDraggedViewToPoint:point];
    }
}

-(void) setDraggingStyleInDraggedView{
    if (self.draggedView) {

        self.draggedView.opaque = NO;
        //self.draggedView.backgroundColor = [UIColor colorWithHue:150.0f/255.0f saturation:0.94f brightness:0.98f alpha:0.5f];
        self.draggedView.layer.cornerRadius = 8; // if you like rounded corners
        self.draggedView.layer.shadowOffset = CGSizeMake(-5, 2);
        self.draggedView.layer.shadowRadius = 5;
        self.draggedView.layer.shadowOpacity = 0.5;
        self.draggedView.layer.masksToBounds = YES;;
    }
}

-(CGPoint) estimateCenterPointForPopingView:(UIView*) viewToPop{
    CGPoint viewCenterPointInGlobal = [viewToPop.superview convertPoint:viewToPop.center toView:nil];
    CGPoint convertedViewCenterPoint = [self.draggingSpace convertPoint:viewCenterPointInGlobal fromView:nil];
    convertedViewCenterPoint.x -= 0.35 * viewToPop.frame.size.width;
    return convertedViewCenterPoint;
}

-(void) moveDraggedViewToPoint:(CGPoint)point{
    CGPoint newCenter = [self.draggingSpace convertPoint:point fromView:nil];
    self.draggedView.center = newCenter;
}

- (void)stopDragging {
    [self.draggedView removeFromSuperview];
}

@end