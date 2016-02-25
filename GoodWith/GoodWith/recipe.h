//
//  recipe.h
//  GoodWith
//
//  Created by Adam Wilson on 9/29/14.
//  Copyright (c) 2014 Adam Wilson. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface recipe : NSObject
@property (strong, nonatomic) NSString *recipeTitle;
@property (strong, nonatomic) NSURL *recipeURL;
@property (strong, nonatomic) NSData *imageData;
@end
