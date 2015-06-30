//
//  Question.h
//  Who Tweeted It?
//
//  Created by Brandon Hafenrichter on 3/30/15.
//  Copyright (c) 2015 Brandon Hafenrichter. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Tweet.h"

@interface Question : NSObject
@property Tweet *q1;
@property Tweet *q2;
@property Tweet *q3;
@property Tweet *q4;
@property int correctAnswer;
@end
