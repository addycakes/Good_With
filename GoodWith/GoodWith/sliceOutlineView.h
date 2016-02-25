//
//  sliceOutlineView.h
//  GoodWith
//
//  Created by Adam Wilson on 10/13/14.
//  Copyright (c) 2014 Adam Wilson. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "linesView.h"
#import "piechartView.h"

@interface sliceOutlineView : UIView
@property (nonatomic, strong) linesView *lineOne;
@property (nonatomic, strong) linesView *lineTwo;
@property (nonatomic, strong) UIView *pieSliceArc;

-(void)outlineSlice:(linesView *)first and:(linesView *)second;
@end
