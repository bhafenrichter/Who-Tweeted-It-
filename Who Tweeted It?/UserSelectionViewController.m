//
//  UserSelectionViewController.m
//  Who Tweeted It?
//
//  Created by Brandon Hafenrichter on 4/2/15.
//  Copyright (c) 2015 Brandon Hafenrichter. All rights reserved.
//

#import "UserSelectionViewController.h"
#import <TwitterKit/TwitterKit.h>
#import "User.h"
#import "QuizViewController.h"

@interface UserSelectionViewController ()
@property (weak, nonatomic) IBOutlet UITableView *tblUserList;
@property (weak, nonatomic) IBOutlet UITextField *tbSearchUser;

@property NSMutableArray *userList;
@end

@implementation UserSelectionViewController

-(void) viewDidLoad{
    [super viewDidLoad];
    
    //removes twitter button
    UIView *viewToRemove = [self.view viewWithTag:39];
    [viewToRemove removeFromSuperview];
    
    //sets up table
    self.tblUserList.delegate = self;
    self.tblUserList.dataSource = self;
    
    //loads users
    [self loadUsers];
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return self.userList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *MyIdentifier = @"UserIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:MyIdentifier];
    
    User *curUser = [self.userList objectAtIndex:indexPath.row];
    
    cell.textLabel.text = curUser.full_name;
    cell.detailTextLabel.text = curUser.handle;
    cell.imageView.image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:curUser.pictureURL]]];
    
    return cell;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if([[segue identifier] isEqualToString:@"UserToQuiz"]){
        QuizViewController *qv = [segue destinationViewController];
        //gets selected row
        NSIndexPath *selectedIndexPath = [self.tblUserList indexPathForSelectedRow];
        
        User *selectedUser = [self.userList objectAtIndex:selectedIndexPath.row];
        qv.userID = selectedUser.userID;
        NSLog(@"id: %@, user: %@", selectedUser.userID, selectedUser.handle);
    }
}


-(void) loadUsers {
    self.userList = [[NSMutableArray alloc]init];
    
    
    //loads tweets from twitter api
    NSString *statusesShowEndpoint = @"https://api.twitter.com/1.1/followers/list.json";
    //TODO: change it so it isn't hardcoded id
    NSDictionary *params = @{@"id" : @"291407873"};
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
                 NSMutableDictionary *returnedDict = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&jsonError];
                 NSArray *users = [returnedDict objectForKey:@"users"];
                 
                 //SEE JSON RESPONSE
                 //NSLog(@"%@", users);
                 
                 
                 for(int i = 0; i < users.count; i++){
                     //gets user information
                     NSDictionary *userDict = [users objectAtIndex:i];
                     
                     User *curUser = [[User alloc] init];
                     curUser.handle = [userDict objectForKey:@"screen_name"];
                     curUser.full_name = [userDict objectForKey:@"name"];
                     curUser.pictureURL = [userDict objectForKey:@"profile_image_url"];
                     curUser.userID = [userDict objectForKey:@"id_str"];
                     [self.userList addObject:curUser];
                     //NSLog(@"%@", curUser.full_name);
                 }
                 
                 [self.tblUserList reloadData];
             }
             
         }];
    }
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
