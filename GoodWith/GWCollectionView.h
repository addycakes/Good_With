//
//  GWCollectionView.h
//  GoodWith
//
//  Created by Adam Wilson on 6/25/13.
//  Copyright (c) 2013 Adam Wilson. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GWsqlite.h"

@interface GWCollectionView : UICollectionViewController <UICollectionViewDataSource, UICollectionViewDelegate, UIAlertViewDelegate>
{
    NSString *searchTerm;
}
@property (nonatomic, strong) NSMutableDictionary *resultsDict;
@property (nonatomic, strong) NSArray *resultsArray;
@property (nonatomic, strong) NSNumber *count;
@property (nonatomic, strong) NSMutableArray *resultsFilter;

-(void)showBreakdown:(NSString *)term;  //segue method
@end
