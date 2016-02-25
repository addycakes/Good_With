//
//  breakdownVC.h
//  GoodWith
//
//  Created by Adam Wilson on 6/2/14.
//  Copyright (c) 2014 Adam Wilson. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface breakdownVC : UIViewController
@property (weak, nonatomic) IBOutlet UIView *piechart;
@property (weak, nonatomic) IBOutlet UIView *containerView;     //view that holds tableview
@property (strong, nonatomic) NSMutableDictionary *resultsDict;

-(void)showBreakdown:(NSString *)term;
@end
