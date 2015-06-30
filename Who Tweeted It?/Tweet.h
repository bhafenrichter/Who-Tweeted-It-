//
//  Tweet.h
//  Who Tweeted It?
//
//  Created by Brandon Hafenrichter on 3/30/15.
//  Copyright (c) 2015 Brandon Hafenrichter. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Tweet : NSObject
@property NSString *author;
@property NSString *authorName;
@property NSString *contents;
@property NSString *pictureURL;
@property NSString *numFavorites;
@property NSString *numRetweets;
@end
