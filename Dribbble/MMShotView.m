//
//  MMShotView.m
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

#import "MMShotView.h"

#import <QuartzCore/QuartzCore.h>

#import "DBShot.h"
#import "DBPlayer.h"
#import "UIImageView+AFNetworking.h"

@implementation MMShotView

@synthesize contentView;
@synthesize shotImageView;
@synthesize avatarView;
@synthesize nameLabel;
@synthesize locationLabel;
@synthesize usernameLabel;

- (void)initializeView {
    [[NSBundle mainBundle] loadNibNamed:@"MMShotView" owner:self options:nil];
    [self addSubview:self.contentView];
    
    self.avatarView.layer.cornerRadius = 5.0f;
    self.avatarView.layer.masksToBounds = YES;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    if ((self = [super initWithCoder:aDecoder])) {
        [self initializeView];
    }
    
    return self;
}

- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        [self initializeView];
    }
    
    return self;
}


- (void)populateWithShot:(DBShot *)shot {
    [self.shotImageView setImageWithURL:shot.imageURL];
    [self.avatarView setImageWithURL:shot.player.avatarURL];
    [self.nameLabel setText:shot.player.name];
    [self.locationLabel setText:shot.player.location];
    [self.usernameLabel setText:shot.player.username];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
