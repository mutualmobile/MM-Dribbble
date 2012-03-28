//
//  MMFullScreenDribbbleViewController.m
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

#import "MMFullScreenDribbbleViewController.h"
#import "TWTweet.h"
#import "MMDataManager.h"
#import "MMTweetCell.h"
#import "MMShotCycleManager.h"
#import "MMShotView.h"
#import "UIImageView+AFNetworking.h"
#import "DBPlayer.h"
#import "UIView+Animations.h"
#import "MMReboundCycleManager.h"
#import "DBShot.h"

#import <QuartzCore/QuartzCore.h>

static const NSInteger kOnDeckPlayers = 4;

static const CGFloat kAvatarHeightDifference = 110.0f;
static const CGFloat kAvatarStartingX = 1058.0f;

@interface MMFullScreenDribbbleViewController () <MMShotCycleManagerDelegate, MMReboundCycleManagerDelegate>
@property (strong, nonatomic) NSArray               * tweetArray;
@property (strong, nonatomic) NSTimer               * tweetTimer;
@property (strong, nonatomic) MMShotCycleManager    * shotCycleManager;
@property (strong, nonatomic) MMReboundCycleManager * reboundCycleManager;
@property (strong, nonatomic) MMShotView            * currentShotView;
@property (strong, nonatomic) MMShotView            * nextShotView;
@property (nonatomic)         CGRect                  shotRect;
@property (strong, nonatomic) NSMutableArray        * avatarImageViews;

@property (strong, nonatomic) NSString              * dribbbleUserName;
@property (strong, nonatomic) NSString              * reboundShotID;
@property (strong, nonatomic) NSString              * twitterSearchString;

- (void)fetchNewTweets;
- (void)updateTweetArrayWithNewTweets:(NSArray*)tweets;
- (void)updateAvatarImageViewPositionsExceptOnDeckImageView;
- (void)updateAvatarImageViewURLsWithPlayers:(NSArray*)players;
- (UIImageView*)onDeckImageView;
- (void)roundThemCornersForImageViews:(NSArray*)imageViews;
- (void)dribbbbleBallAnimation;

@end

@implementation MMFullScreenDribbbleViewController
@synthesize tweetTableView = _tweetTableView;
@synthesize tweetArray = _tweetArray;
@synthesize tweetTimer = _tweetTimer;
@synthesize shotCycleManager = _shotCycleManager;
@synthesize reboundCycleManager = _reboundCycleManager;
@synthesize currentShotView = _currentShotView;
@synthesize nextShotView = _nextShotView;
@synthesize shotRect = _shotRect;
@synthesize avatarImageViews = avatarImageViews_;
@synthesize currentRebound = currentRebound_;
@synthesize nextRebound = nextRebound_;
@synthesize dribbbleBall = _dribbbleBall;
@synthesize currentTagImageView = _currentTagImageView;
@synthesize reboundContainerView = _reboundContainerView;
@synthesize dribbbleUserName = _dribbbleUserName;
@synthesize reboundShotID = _reboundShotID;
@synthesize twitterSearchString = _twitterSearchString;

- (id)initWithDribbbleUserName:(NSString *)dribbbleUserName reboundShotID:(NSString *)reboundShotID twitterSearchString:(NSString *)twitterSearchString {
    if ((self = [self initWithNibName:@"MMFullScreenDribbbleViewController" bundle:nil])) {
        _dribbbleUserName = dribbbleUserName;
        _reboundShotID = reboundShotID;
        _twitterSearchString = twitterSearchString;
    }
    
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.shotRect = CGRectMake(70.0f, 180.0f, 900.0f, 400.0f);
    
    self.currentShotView = [[MMShotView alloc] initWithFrame:self.shotRect];
    [self.view addSubview:self.currentShotView];
    
    CGFloat avatarStartingX = 1058.0f;
    
    UIImageView *avatarImageView = [[UIImageView alloc] initWithFrame:CGRectMake(avatarStartingX, 439.0f, 80.0f, 80.0f)];
    UIImageView *avatarImageView2 = [[UIImageView alloc] initWithFrame:CGRectMake(avatarStartingX, 329.0f, 80.0f, 80.0f)];
    UIImageView *avatarImageView3 = [[UIImageView alloc] initWithFrame:CGRectMake(avatarStartingX, 219.0f, 80.0f, 80.0f)];
    UIImageView *avatarImageView4 = [[UIImageView alloc] initWithFrame:CGRectMake(avatarStartingX, 109.0f, 80.0f, 80.0f)];

    self.avatarImageViews = [NSMutableArray arrayWithObjects:avatarImageView, avatarImageView2, avatarImageView3, avatarImageView4, nil];
    
    [self.view addSubview:avatarImageView];
    [self.view addSubview:avatarImageView2];
    [self.view addSubview:avatarImageView3];
    [self.view addSubview:avatarImageView4];

    [self roundThemCornersForImageViews:self.avatarImageViews];
}

- (void)viewDidUnload
{
    [self setTweetTableView:nil];
    [self setDribbbleBall:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    self.view.frame = CGRectMake(0.0f, 0.0f, 1920.0f, 1080.0f);
    
    [self fetchNewTweets];
    _tweetTimer = [NSTimer scheduledTimerWithTimeInterval:5.0
                                                   target:self
                                                 selector:@selector(fetchNewTweets)
                                                 userInfo:nil
                                                  repeats:YES];
    
    self.shotCycleManager = [[MMShotCycleManager alloc] init];
    self.shotCycleManager.delegate = self;
    
    [self.shotCycleManager beginShotCycleWithCycleInterval:10 refreshInterval:20 followingUsername:self.dribbbleUserName numberOfOnDeckPlayers:kOnDeckPlayers + 1];
    
    self.reboundCycleManager = [[MMReboundCycleManager alloc] init];
    self.reboundCycleManager.delegate = self;
    
    [self.reboundCycleManager beginReboundCycleWithCycleInterval:10 refreshInterval:20 shotIdentifier:self.reboundShotID];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    
}

- (void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    [_tweetTimer invalidate];
    
    [self.shotCycleManager stopUpdating];
    [self.reboundCycleManager stopUpdating];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Private

- (void)roundThemCornersForImageViews:(NSArray *)imageViews {
    for (UIImageView *imageView in imageViews) {
        imageView.layer.cornerRadius = 5.0f;
        imageView.layer.masksToBounds = YES;
    }
}

- (void)fetchNewTweets{
    NSManagedObjectContext *context = [[MMDataManager sharedDataManager] managedObjectContext];
    NSString * maxIdString = nil;
    if([_tweetArray count]>0){
        NSSortDescriptor * sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"tweetIdString"
                                                                          ascending:NO];
        NSArray * sortedArray = [_tweetArray sortedArrayUsingDescriptors:[NSArray arrayWithObject:sortDescriptor]];
        TWTweet * latestTweet = [sortedArray objectAtIndex:0];
        maxIdString = latestTweet.tweetIdString;
    }
    
    [TWTweet 
     tweetsForSearchString:self.twitterSearchString
     maxIdString:maxIdString
     context:context
     resultBlock:^(NSArray *tweets) {
         if([tweets count]>0)
             [self dribbbbleBallAnimation];
         [self updateTweetArrayWithNewTweets:tweets];
     } 
     failureBlock:^(NSError *error) {

     }];
}
- (void)updateTweetArrayWithNewTweets:(NSArray*)tweets{
    if(!_tweetArray){
        _tweetArray = [[NSArray alloc] init];
    }
    
    NSMutableArray * tempArray = [NSMutableArray arrayWithArray:_tweetArray];
    NSIndexSet * indexSet = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, [tweets count])];
    [tempArray insertObjects:tweets atIndexes:indexSet];
    
    NSMutableArray * indexPaths = [NSMutableArray arrayWithCapacity:[tweets count]];
    for (int i = 0; i < [tweets count]; i++){
        NSIndexPath * indexPath = [NSIndexPath indexPathForRow:i
                                                     inSection:0];
        [indexPaths addObject:indexPath];
    }
    
    _tweetArray = [NSArray arrayWithArray:tempArray];
    
    [_tweetTableView insertRowsAtIndexPaths:indexPaths
                           withRowAnimation:UITableViewRowAnimationTop];
}

- (void)updateAvatarImageViewPositionsExceptOnDeckImageView {
    for (int i = 1; i < kOnDeckPlayers; i++) {
        UIImageView *imageView = [self.avatarImageViews objectAtIndex:i];

        imageView.center = CGPointMake(imageView.center.x, imageView.center.y + kAvatarHeightDifference);
    }
}

- (void)updateAvatarImageViewURLsWithPlayers:(NSArray *)players {
    for (int i = 0; i < kOnDeckPlayers; i++) {
        UIImageView *imageView = [self.avatarImageViews objectAtIndex:i];
        DBPlayer *player = [players objectAtIndex:i];
        
        [imageView setImageWithURL:player.avatarURL];
    }
}

- (UIImageView*)onDeckImageView {
    UIImageView *onDeckImageView = [self.avatarImageViews objectAtIndex:0];

    return onDeckImageView;
}

- (void)dribbbbleBallAnimation{
    CGFloat ballBounceHeight = 20;
    CGFloat ballSquish = 6.0;
    CGFloat dropTime = .08;
    CGFloat squishTime = .08;
    
    [UIView
     animateWithDuration:dropTime
     delay:0
     options:UIViewAnimationOptionCurveEaseIn
     animations:^{
         CGRect newRect = _dribbbleBall.frame;
         newRect.origin.y+=ballBounceHeight;
         [_dribbbleBall setFrame:newRect];
     } 
     completion:^(BOOL finished) {
         [UIView
          animateWithDuration:squishTime
          delay:0
          options:UIViewAnimationOptionCurveEaseOut
          animations:^{
              CGRect newRect = _dribbbleBall.frame;
              newRect.size.height-=ballSquish;
              newRect.origin.y+=ballSquish*1.5;
              newRect.size.width+=ballSquish;
              newRect.origin.x-=ballSquish/2.0;
              [_dribbbleBall setFrame:newRect];
          } 
          completion:^(BOOL finished) {
              [UIView
               animateWithDuration:squishTime
               delay:0
               options:UIViewAnimationOptionCurveEaseIn
               animations:^{
                   CGRect newRect = _dribbbleBall.frame;
                   newRect.size.height+=ballSquish;
                   newRect.origin.y-=ballSquish*1.5;
                   newRect.size.width-=ballSquish;
                   newRect.origin.x+=ballSquish/2.0;
                   [_dribbbleBall setFrame:newRect];
               } 
               completion:^(BOOL finished) {
                   [UIView
                    animateWithDuration:dropTime*1.4
                    delay:0
                    options:UIViewAnimationOptionCurveEaseOut
                    animations:^{
                        CGRect newRect = _dribbbleBall.frame;
                        newRect.origin.y-=ballBounceHeight*1.0;
                        [_dribbbleBall setFrame:newRect];
                    } 
                    completion:^(BOOL finished) {

                        
                    }];  
               }];         
          }];         
     }];
}

#pragma mark - UITableview
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [_tweetArray count];
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *CellIdentifier = @"MMTweetCell";
    
    MMTweetCell *cell = (MMTweetCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        
        cell = [[MMTweetCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    TWTweet * tweet = [_tweetArray objectAtIndex:indexPath.row];
    [cell updateWithTweet:tweet];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    TWTweet * tweet = [_tweetArray objectAtIndex:indexPath.row];
    return [MMTweetCell cellHeightForWidth:tableView.bounds.size.width
                                 withTweet:tweet];
}

#pragma mark - MMShotCycleManagerDelegate

- (void)shotCycleManager:(MMShotCycleManager *)shotCycleManager didUpdateToShot:(DBShot *)shot onDeckPlayers:(NSArray *)players {
    [self updateAvatarImageViewURLsWithPlayers:players];
    
    if (self.nextShotView == nil) {
        [self.currentShotView populateWithShot:shot];
        
        self.nextShotView = [[MMShotView alloc] initWithFrame:self.shotRect];
        self.nextShotView.alpha = 0.0f;
        [self.view addSubview:self.nextShotView];
    } else {
        [self.nextShotView populateWithShot:shot];
        
        NSTimeInterval stage1Duration = 0.46;
        [UIView animateWithDuration:stage1Duration animations:^{
            [self moveCurrentShotOffScreen];
            [self moveOnDeckAvatarToCurrentShotPositionWithDuration:1.0];
            [self updateAvatarImageViewPositionsExceptOnDeckImageView];
            //self.nextShotView.alpha = 0.5f;
        } completion:^(BOOL finished) {
            [self.currentShotView removeFromSuperview];
            self.currentShotView = self.nextShotView;
            
            self.nextShotView.center = CGPointMake(self.nextShotView.center.x + 200.0f, self.nextShotView.center.y);
            
            [UIView 
             animateWithDuration:0.57f
             animations:^{
                 [self.view bringSubviewToFront:self.onDeckImageView];
                 [self showNextShot];
                 self.nextShotView.avatarView.hidden = YES;
                 self.nextShotView.center = CGPointMake(self.nextShotView.center.x - 200.0f, self.nextShotView.center.y);
             }
             completion:^(BOOL finished) {
                 self.nextShotView.avatarView.hidden = NO;
                 [self recycleOnDeckAvatar];
                 [self cyclePlayerAvatars:players];

                 [self rebuildNextShot];
                 [self revealNewPlayerWithDuration:stage1Duration];
             }];
        }];
    }
}


- (void)moveCurrentShotOffScreen
{
    self.currentShotView.center = CGPointMake(0.0f - (self.nextShotView.frame.size.width / 2.0f) - 100.0f, self.currentShotView.center.y);
    self.currentShotView.alpha = 0.0f;
}


- (void)moveOnDeckAvatarToCurrentShotPositionWithDuration:(NSTimeInterval)duration
{
    UIBezierPath* path = [[UIBezierPath alloc] init];
    
    CGPoint startPoint = self.onDeckImageView.layer.position;
    [path moveToPoint:startPoint];

    CGPoint endPoint = CGPointMake(self.nextShotView.frame.origin.x + self.nextShotView.avatarView.center.x, self.nextShotView.frame.origin.y + self.nextShotView.avatarView.center.y);
    CGFloat xDelta = fabsf(endPoint.x - startPoint.x);
    CGPoint controlPoint = CGPointMake((startPoint.x + endPoint.x) / 2.0f, MAX(startPoint.y, endPoint.y) + (xDelta / 2.0f));
    [path addQuadCurveToPoint:endPoint controlPoint:controlPoint];
    
    CAKeyframeAnimation* animation = [CAKeyframeAnimation animationWithKeyPath:@"position"];
    
    //Set some variables on the animation
    animation.calculationMode = kCAAnimationPaced;
    //We want the animation to persist - not so important in this case - but kept for clarity
    //If we animated something from left to right - and we wanted it to stay in the new position,
    //then we would need these parameters
    animation.fillMode = kCAFillModeForwards;
    animation.removedOnCompletion = YES;
    animation.path = [path CGPath];
    animation.duration = duration;
    animation.delegate = self;
    animation.repeatCount = 0;
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    
    self.onDeckImageView.layer.position = endPoint;
    
    [self.onDeckImageView.layer addAnimation:animation forKey:@"RopeSwing"];
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag {

}

- (void)showNextShot
{
    self.nextShotView.alpha = 1.0f;
}


- (void)rebuildNextShot
{
    self.nextShotView = [[MMShotView alloc] initWithFrame:self.shotRect];
    self.nextShotView.alpha = 0.0f;
    [self.view addSubview:self.nextShotView];
}


- (void)recycleOnDeckAvatar
{
    UIImageView *onDeckImageView = [self onDeckImageView];
    [self.avatarImageViews removeObject:onDeckImageView];
    [self.avatarImageViews addObject:onDeckImageView];
    [onDeckImageView setAlpha:0.0f];
    [onDeckImageView setFrame:CGRectMake(kAvatarStartingX, 109.0f, 80.0f, 80.0f)];
    
    [onDeckImageView applyPopUpAnimation:0.35f withAlpha:YES];

    return;
}


- (void)cyclePlayerAvatars:(NSArray*)players
{
    NSMutableArray *newPlayers = [NSMutableArray arrayWithArray:players];
    [newPlayers removeObjectAtIndex:0];
    
    [self updateAvatarImageViewURLsWithPlayers:newPlayers];
}


- (void)revealNewPlayerWithDuration:(NSTimeInterval)duration
{
    return;
    [UIView animateWithDuration:duration animations:^{
        UIImageView* onDeckImageView = [self onDeckImageView];

        [onDeckImageView setAlpha:1.0f];
    }];
}


#pragma mark - MMReboundCycleManagerDelegate

- (void)reboundCycleManager:(MMReboundCycleManager *)reboundCycleManager didUpdateToNextShot:(DBShot *)shot {
    self.nextRebound = [[UIImageView alloc] initWithFrame:self.currentRebound.frame];
    [self.nextRebound setImageWithURL:shot.imageURL];
    
    [self.nextRebound
     setImageWithURLRequest:[NSURLRequest requestWithURL:shot.imageURL] 
     placeholderImage:nil 
     success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
         [UIView transitionFromView:self.currentRebound toView:self.nextRebound duration:0.45f options:UIViewAnimationOptionTransitionFlipFromRight completion:^(BOOL finished) {
             self.currentRebound = self.nextRebound;
             
             self.currentTagImageView.alpha = 0.0f;
         }];
     } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
         
     }];
}

- (void)reboundCycleManager:(MMReboundCycleManager *)reboundCycleManager didUpdateToCurrentShot:(DBShot *)shot {
    self.nextRebound = [[UIImageView alloc] initWithFrame:self.currentRebound.frame];
    [self.nextRebound setImageWithURL:shot.imageURL];
    
    [self.nextRebound
     setImageWithURLRequest:[NSURLRequest requestWithURL:shot.imageURL] 
     placeholderImage:nil 
     success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
        [UIView transitionFromView:self.currentRebound toView:self.nextRebound duration:0.45f options:UIViewAnimationOptionTransitionFlipFromRight completion:^(BOOL finished) {
            self.currentRebound = self.nextRebound;
            
            [self.reboundContainerView bringSubviewToFront:self.currentTagImageView];
            
            [UIView animateWithDuration:0.25f animations:^{
                self.currentTagImageView.alpha = 1.0f;
            }];
        }];
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
        
    }];
}

@end
