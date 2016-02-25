//
//  sliceOutlineView.m
//  GoodWith
//
//  Created by Adam Wilson on 10/13/14.
//  Copyright (c) 2014 Adam Wilson. All rights reserved.
//

#import "sliceOutlineView.h"

@implementation sliceOutlineView

//set the lines
-(void)outlineSlice:(linesView *)first and:(linesView *)second
{
    self.lineOne = first;
    self.lineTwo = second;
}

- (void)drawRect:(CGRect)rect {
    // Drawing code
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGRect bounds = [self bounds];
    
    //center point
    CGPoint center;
    center.x = bounds.origin.x + bounds.size.width / 2.0;
    center.y = bounds.origin.y + bounds.size.height / 2.0;
    
    //line properties
    [[UIColor blackColor] setStroke];
    CGContextSetLineWidth(ctx, 2);
    
    //lines start at endpoint on circumference
    //then moves across arc to second line endpoint,
    // back to center then up to starting point
    CGContextAddArc(ctx, center.x, center.y, (bounds.size.width / 2.0 - 1.15), self.lineOne.angle, self.lineTwo.angle, YES);
    CGContextAddLineToPoint(ctx, center.x, center.y);
    CGContextAddLineToPoint(ctx, self.lineOne.endpointX, self.lineOne.endpointY);
    
    //compensate for previous frame rotation
    self.transform = CGAffineTransformRotate(self.transform, -1*(2.475*M_2_PI));
    
    //add line
    CGContextStrokePath(ctx);
}

@end
