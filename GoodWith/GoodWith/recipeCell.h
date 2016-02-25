//
//  recipeCell.h
//  GoodWith
//
//  Created by Adam Wilson on 10/10/14.
//  Copyright (c) 2014 Adam Wilson. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface recipeCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *loadingSpinner;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIImageView *thumbnail;
@end
