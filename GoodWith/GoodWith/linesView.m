//
//  linesView.m
//  GoodWith
//
//  Created by Adam Wilson on 6/2/14.
//  Copyright (c) 2014 Adam Wilson. All rights reserved.
//

#import "linesView.h"

@implementation linesView

-(void)drawRect:(CGRect)rect
{
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGRect bounds = [self bounds];

    //center point
    CGPoint center;
    center.x = bounds.origin.x + bounds.size.width / 2.0;
    center.y = bounds.origin.y + bounds.size.height / 2.0;

    //line properties
    [[UIColor whiteColor] setStroke];
    CGContextSetLineWidth(ctx, 1.5);
    
    //lines start at 12 o'clock position
    CGContextMoveToPoint(ctx, center.x, 0);
    CGContextAddLineToPoint(ctx, center.x, center.y);
    CGContextStrokePath(ctx);
    
    //lines then rotate clockwise to destination
    //upon completion, use parametric equation to find endpoint of line on circle
    [UIView animateWithDuration:1 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        [self rotateViewAnimated:self withDuration:1 byAngle:self.angle];
    } completion:^(BOOL finished) {
        float x = center.x + (bounds.size.width / 2.0) * cos(self.angle);
        float y = center.y + (bounds.size.height / 2.0) * sin(self.angle);
        [self setEndpointX:x];
        [self setEndpointY:y];
    }];
}

- (void) rotateViewAnimated:(UIView*)view
               withDuration:(CFTimeInterval)duration
                    byAngle:(CGFloat)angle
{
    CABasicAnimation *rotationAnimation;
    rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    rotationAnimation.byValue = [NSNumber numberWithFloat:angle];
    rotationAnimation.duration = duration;
    
    [CATransaction setCompletionBlock:^{
        view.transform = CGAffineTransformRotate(view.transform, angle);
    }];
    
    [view.layer addAnimation:rotationAnimation forKey:@"rotationAnimation"];
}
@end
