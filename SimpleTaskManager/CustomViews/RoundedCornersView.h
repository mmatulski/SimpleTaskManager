//
//  RoundedCornersView.h
//
//  Created by Marek Matulski on 04.12.2011.
//  Copyright (c) 2011 Marek Matulski. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RoundedCornersView : UIView {
    UIRectCorner corners;
}

@property (nonatomic) CGFloat cornersSize;

-(void) roundTopCorners;
-(void) roundBottomCorners;
-(void) roundLeftCorners;
-(void) roundRightCorners;
-(void) roundAllCorners;
-(void) donotRoundCorners;
-(void) updateCorners;

@end
