//
//  piechartView.m
//  GoodWith
//
//  Created by Adam Wilson on 6/2/14.
//  Copyright (c) 2014 Adam Wilson. All rights reserved.
//

#import "piechartView.h"

@implementation piechartView

-(void)drawRect:(CGRect)rect
{
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGRect bounds = [self bounds];
    
    //center point
    CGPoint center;
    center.x = bounds.origin.x + bounds.size.width / 2.0;
    center.y = bounds.origin.y + bounds.size.height / 2.0;
    
    //max size circle for view's size
    float maxRadius = bounds.size.height / 2.0;
    
    //shape properties
    [[UIColor colorWithRed:1 green:.4 blue:.1 alpha:1] setFill];
    CGContextAddArc(ctx, center.x, center.y, maxRadius, 0.0, M_PI * 2, YES);
    
    CGContextFillPath(ctx);
}

@end
