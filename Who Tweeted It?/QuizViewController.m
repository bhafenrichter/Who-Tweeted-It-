//
//  QuizViewController.m
//  Who Tweeted It?
//
//  Created by Brandon Hafenrichter on 3/26/15.
//  Copyright (c) 2015 Brandon Hafenrichter. All rights reserved.
//

#import "QuizViewController.h"
#import <TwitterKit/TwitterKit.h> 
#import <Twitter/Twitter.h>
#import "Tweet.h"
#import "Question.h"

@interface QuizViewController ()
@property (weak, nonatomic) IBOutlet UILabel *lblQuestion;
@property (weak, nonatomic) IBOutlet UILabel *lblFavorites;
@property (weak, nonatomic) IBOutlet UILabel *lblRetweets;
@property (weak, nonatomic) IBOutlet UITableView *tblChoices;
@property (nonatomic, strong) NSMutableArray *tweets; // Hold all the loaded tweets
@property Question *currentQuestion;
@end

@implementation QuizViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    //removes twitter button
    UIView *viewToRemove = [self.view viewWithTag:39];
    [viewToRemove removeFromSuperview];
    
    //sets up table
    self.tblChoices.delegate = self;
    self.tblChoices.dataSource = self;
    
    //loads tweets
    [self loadTweets];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)checkAnswer:(id)sender {
    NSIndexPath *selectedIndexPath = [self.tblChoices indexPathForSelectedRow];
    int selectedRow = selectedIndexPath.row;
    
    if(selectedRow == self.currentQuestion.correctAnswer){
        NSLog(@"YOU GOT THE RIGHT ANSWER!");
    }else{
        NSLog(@"You got the wrong answer.");
        NSLog(@"Selected Row: %i, Correct Answer Row: %i", selectedRow, self.currentQuestion.correctAnswer);
    }
    [self generateQuestion];
}

-(void) generateQuestion {
    self.currentQuestion = [[Question alloc]init];
    int selectedQuestion = arc4random_uniform(3);
    self.currentQuestion.correctAnswer = selectedQuestion;
    self.currentQuestion.q1 = [self.tweets objectAtIndex:arc4random_uniform(self.tweets.count - 1)];
    self.currentQuestion.q2 = [self.tweets objectAtIndex:arc4random_uniform(self.tweets.count - 1)];
    self.currentQuestion.q3 = [self.tweets objectAtIndex:arc4random_uniform(self.tweets.count - 1)];
    self.currentQuestion.q4 = [self.tweets objectAtIndex:arc4random_uniform(self.tweets.count - 1)];
    
    //refreshes UI
    [self setupQuestionUI];
}

-(void) setupQuestionUI{
    self.lblQuestion.lineBreakMode = NSLineBreakByWordWrapping;
    self.lblQuestion.numberOfLines = 0;
    
    Tweet *question = [[Tweet alloc]init];
    
    switch (self.currentQuestion.correctAnswer) {
        case 0:
            question = self.currentQuestion.q1;
            break;
        case 1:
            question = self.currentQuestion.q2;
            break;
        case 2:
            question = self.currentQuestion.q3;
            break;
        case 3:
            question = self.currentQuestion.q4;
            break;
            
        default:
            break;
    }
    self.lblQuestion.text = question.contents;
    self.lblRetweets.text = [[NSString alloc] initWithFormat:@"Retweets: %@", question.numRetweets];
    self.lblFavorites.text = [[NSString alloc] initWithFormat:@"Favorites: %@", question.numFavorites];
    
    //table
    self.tblChoices.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    [self.tblChoices reloadData];
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return 4;    //count number of row from counting array hear cataGorry is An Array
}



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *MyIdentifier = @"MyIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:MyIdentifier];
    
    //custom styling
    [cell.layer setCornerRadius:20.0f];
    [cell.layer setMasksToBounds:YES];
    [cell.layer setBorderWidth:2.0f];
    
    cell.backgroundColor = [UIColor clearColor];
    switch (indexPath.row) {
            
        case 0:
            cell.textLabel.text = self.currentQuestion.q1.author;
            cell.detailTextLabel.text = self.currentQuestion.q1.authorName;
            cell.imageView.image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:self.currentQuestion.q1.pictureURL]]];
            break;
        case 1:
            cell.textLabel.text = self.currentQuestion.q2.author;
            cell.detailTextLabel.text = self.currentQuestion.q2.authorName;
            cell.imageView.image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:self.currentQuestion.q2.pictureURL]]];
            break;
        case 2:
            cell.textLabel.text = self.currentQuestion.q3.author;
            cell.detailTextLabel.text = self.currentQuestion.q3.authorName;
            cell.imageView.image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:self.currentQuestion.q3.pictureURL]]];
            break;
        case 3:
            cell.textLabel.text = self.currentQuestion.q4.author;
            cell.detailTextLabel.text = self.currentQuestion.q4.authorName;
            cell.imageView.image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:self.currentQuestion.q4.pictureURL]]];
            break;
        default:
            break;
    }
    return cell;
}

- (void) loadTweets {
    self.tweets = [[NSMutableArray alloc]init];
    
    
    //loads tweets from twitter api
    NSString *statusesShowEndpoint = @"https://api.twitter.com/1.1/statuses/home_timeline.json";
    //TODO: change it so it isn't hardcoded id
    NSDictionary *params = @{@"user_id" : @"291407873", @"count" : @"200", @"exclude_replies" : @"true"};
    NSError *clientError;
    NSURLRequest *request = [[[Twitter sharedInstance] APIClient]
                             URLRequestWithMethod:@"GET"
                             URL:statusesShowEndpoint
                             parameters:params
                             error:&clientError];
    
    if (request) {
        NSLog(@"Twitter API Called");
        [[[Twitter sharedInstance] APIClient]
         sendTwitterRequest:request
         completion:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
             if (data) {
                 // handle the response data e.g.
                 NSError *jsonError;
                 NSArray *array = [NSJSONSerialization JSONObjectWithData: data options:NSJSONReadingMutableContainers error:&jsonError];
                 
                 //SEE JSON RESPONSE
                 NSLog(@"%@", array);
                 
                 
                 //loads tweets
                 for(int i = 0; i < array.count; i++){
                     NSDictionary *jsonDict = [array objectAtIndex:i];
                     Tweet *cur = [[Tweet alloc]init];
                     
                     //gets tweet information
                     cur.contents = [jsonDict objectForKey:@"text"];
                     
                     //check to make sure tweet is longer than 40 characters
                     if([cur.contents length] <= 40){
                         continue;
                     }//checks the tweet to make sure its not a reply or retweet
                     else if([cur.contents hasPrefix:@"RT"] || [cur.contents hasPrefix:@"."] || [cur.contents hasPrefix:@"@"]){
                         continue;
                     }else if([cur.contents containsString:@"http"]){
                         continue;
                     }
                     cur.numFavorites = [jsonDict objectForKey:@"favorite_count"];
                     cur.numRetweets = [jsonDict objectForKey:@"retweet_count"];
                     
                     //gets user information
                     NSDictionary *userDict = [jsonDict objectForKey:@"user"];
                     cur.author = [userDict objectForKey:@"screen_name"];
                     cur.pictureURL = [userDict objectForKey:@"profile_image_url"];
                     cur.authorName = [userDict objectForKey:@"name"];
                     [self.tweets addObject:cur];
                     
                     
                     //NSLog(@"Author: %@ / Contents: %@ / pictureURL: %@ / Favorites: %@ / Retweets: %@ ||", cur.author, cur.contents, cur.pictureURL, cur.numFavorites, cur.numRetweets);
                 }
                 NSLog(@"Size of Potential Tweets: %lu", (unsigned long)self.tweets.count);
                 
                 //set up ui and create first question
                 [self generateQuestion];
             }
             else {
                 NSLog(@"Error: %@", connectionError);
             }
         }];
    }
    else {
        NSLog(@"Error: %@", clientError);
    }
}

@end
