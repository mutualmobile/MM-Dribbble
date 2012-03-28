//
//  MMViewController.m
//  Dribbble
//
//  Copyright (c) 2012 Mutual Mobile. All rights reserved.
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
// 
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
// 
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import "MMViewController.h"

#import "MMDataManager.h"
#import "DBShot.h"
#import "TWTweet.h"

@interface MMViewController ()
- (void)setupImageForInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation;
@end

@implementation MMViewController
@synthesize imageView = _imageView;

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
//    NSManagedObjectContext *context = [[MMDataManager sharedDataManager] managedObjectContext];
//    
//    [DBShot shotsFromPlayersFollowingUsername:@"bjango" context:context resultBlock:^(NSArray *shots) {
//    } failureBlock:^(NSError *error) {
//    }];
//    
//    [TWTweet tweetsForSearchString:@"mmdribbble" maxIdString:@"176862714361163776" context:context resultBlock:^(NSArray *tweets) {
//        [tweets
//         enumerateObjectsUsingBlock:^(TWTweet * tweet, NSUInteger idx, BOOL *stop) {
//             NSLog(@"%@",tweet.tweet);
//         }];
//    } failureBlock:^(NSError *error) {
//    }];
}

- (void)viewDidUnload
{
    [self setImageView:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self setupImageForInterfaceOrientation:self.interfaceOrientation];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return YES;
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration{
    [self setupImageForInterfaceOrientation:toInterfaceOrientation];
}

- (void)setupImageForInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation{
    if(UIInterfaceOrientationIsLandscape(interfaceOrientation)){
        [_imageView setImage:[UIImage imageNamed:@"iPad-landscape.png"]];
    }  
    else {
        [_imageView setImage:[UIImage imageNamed:@"iPad-portrait.png"]];
    }
}

@end
