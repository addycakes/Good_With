//
//  GWBreakdownTVC.h
//  GoodWith
//
//  Created by Adam Wilson on 5/10/13.
//  Copyright (c) 2013 Adam Wilson. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GWBreakdownTVC : UITableViewController <UITableViewDataSource, UITableViewDelegate>
{

}
@property (nonatomic, strong) NSMutableDictionary *resultsDict;
@property (nonatomic, strong) NSArray *resultsArray;
@property (nonatomic, strong) NSNumber *count;

-(void)showBreakdown:(NSString *)term;  //segue method
@end
