//
//  ViewController.m
//  Who Tweeted It?
//
//  Created by Brandon Hafenrichter on 3/26/15.
//  Copyright (c) 2015 Brandon Hafenrichter. All rights reserved.
//

#import "ViewController.h"
#import <TwitterKit/TwitterKit.h>

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    TWTRLogInButton* logInButton =  [TWTRLogInButton buttonWithLogInCompletion: ^(TWTRSession* session, NSError* error) {
         if (session) {
             NSLog(@"signed in as %@", [session userName]);
             
             [self performSegueWithIdentifier:@"loginToHome" sender:self];
             
         } else {
             NSLog(@"error: %@", [error localizedDescription]);
         }}];
    logInButton.center = self.view.center;
    logInButton.tag = 39;
    [self.view addSubview:logInButton];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
