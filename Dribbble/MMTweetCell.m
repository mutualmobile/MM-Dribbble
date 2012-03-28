//
//  MMTweetCell.m
//  Dribbble
//
//  Copyright (c) Mutual Mobile. All rights reserved.
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

#import "MMTweetCell.h"
#import "NSAttributedString+Attributes.h"
#import "UIImageView+AFNetworking.h"

#import <QuartzCore/QuartzCore.h>

#define CONTENT_INSET 15.0
#define IMAGE_VIEW_HEIGHT 48.0
#define IMAGE_VIEW_OFFSET 8.0

@interface MMTweetCell ()

+ (NSAttributedString*)attributedStringForTweet:(TWTweet*)tweet;
+ (CGSize)tweetLabelSizeForTweet:(TWTweet*)tweet forWidth:(CGFloat)width;

@end

@implementation MMTweetCell
@synthesize tweetLabel = _tweetLabel;
@synthesize tweet = _tweet;
@synthesize userImageView = _userImageView;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        _tweetLabel = [[TTTAttributedLabel alloc] initWithFrame:CGRectZero];
        _tweetLabel.font = [UIFont systemFontOfSize:25];
        _tweetLabel.textColor = [UIColor colorWithRed:180.0/255.0
                                                green:180.0/255.0
                                                 blue:180.0/255.0
                                                alpha:1.0];
        _tweetLabel.shadowColor = [UIColor whiteColor];
        _tweetLabel.shadowOffset = CGSizeMake(0, 1);
        _tweetLabel.lineBreakMode = UILineBreakModeWordWrap;
        _tweetLabel.numberOfLines = 0;
        [self addSubview:_tweetLabel];
        [self setBackgroundColor:[UIColor clearColor]];
        [_tweetLabel setBackgroundColor:[UIColor clearColor]];
        
        _userImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        _userImageView.layer.cornerRadius = 5.0f;
        _userImageView.layer.masksToBounds = YES;
        [self addSubview:_userImageView];
    }
    return self;
}

- (void)layoutSubviews{
    [super layoutSubviews];
    
    CGRect contentRect = CGRectInset(self.bounds, CONTENT_INSET, CONTENT_INSET);
    
    CGRect imageViewRect = CGRectMake(contentRect.origin.x, contentRect.origin.y+IMAGE_VIEW_OFFSET, IMAGE_VIEW_HEIGHT, IMAGE_VIEW_HEIGHT);
    [_userImageView setFrame:imageViewRect];
    
    CGSize tweetSize = [MMTweetCell tweetLabelSizeForTweet:_tweet forWidth:CGRectGetWidth(contentRect)-CGRectGetWidth(imageViewRect)-CONTENT_INSET];
    [_tweetLabel setFrame:CGRectMake(CGRectGetMaxX(imageViewRect)+CONTENT_INSET, contentRect.origin.y, tweetSize.width, tweetSize.height)];
}

- (void)updateWithTweet:(TWTweet *)tweet{
    [self setTweet:tweet];
    
    [_tweetLabel setText:[MMTweetCell attributedStringForTweet:tweet]];
    [_userImageView setImageWithURL:tweet.userPhotoURL];
    
    [self setNeedsLayout];
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

+ (CGFloat)cellHeightForWidth:(CGFloat)width withTweet:(TWTweet*)tweet{
    NSAttributedString * attrString = [MMTweetCell attributedStringForTweet:tweet];
    
    CGSize suggestedSize = [attrString sizeConstrainedToSize:CGSizeMake((width-CONTENT_INSET*2)-IMAGE_VIEW_HEIGHT-CONTENT_INSET, MAXFLOAT)];
    
    return MAX(IMAGE_VIEW_HEIGHT+IMAGE_VIEW_OFFSET, suggestedSize.height)+CONTENT_INSET*2;
}

#pragma mark - Private Methods
+ (NSAttributedString*)attributedStringForTweet:(TWTweet*)tweet{
    
    NSString * tweetText = [NSString stringWithFormat:@"@%@: %@",tweet.username,tweet.tweet];
    NSMutableAttributedString * mutableAttributedString = [NSMutableAttributedString attributedStringWithString:tweetText];
    
    NSRange boldRange = NSMakeRange(0, tweet.username.length+2);
    
    
    // Core Text APIs use C functions without a direct bridge to UIFont. See Apple's "Core Text Programming Guide" to learn how to configure string attributes.
    UIFont *boldSystemFont = [UIFont boldSystemFontOfSize:25]; 
    CTFontRef boldFont = CTFontCreateWithName((__bridge CFStringRef)boldSystemFont.fontName, boldSystemFont.pointSize, NULL);
    if (boldFont) {
        UIColor * textColor = [UIColor colorWithRed:197.0/255.0
                                              green:55.0/255.0
                                               blue:109.0/255.0
                                              alpha:1.0];
        [mutableAttributedString addAttribute:(NSString *) kCTForegroundColorAttributeName value:(id)[textColor CGColor] range:boldRange];
        [mutableAttributedString addAttribute:(NSString *)kCTFontAttributeName value:(__bridge id)boldFont range:boldRange];
        CFRelease(boldFont);
    }

    NSRange regularRange = NSMakeRange(boldRange.length, tweetText.length-boldRange.length);

    UIFont *systemFont = [UIFont systemFontOfSize:25]; 
    CTFontRef font = CTFontCreateWithName((__bridge CFStringRef)systemFont.fontName, systemFont.pointSize, NULL);
    if (font) {
        [mutableAttributedString addAttribute:(NSString *)kCTFontAttributeName value:(__bridge id)font range:regularRange];
        CFRelease(font);
    }
    
    [[tweetText componentsSeparatedByString:@" "] 
     enumerateObjectsUsingBlock:^(NSString * string, NSUInteger idx, BOOL *stop) {
         NSRange hashtagRange = [string rangeOfString:@"#"];
         if(hashtagRange.location == 0){
             NSRange stringRange = [tweetText rangeOfString:string];
             UIColor * textColor = [UIColor colorWithRed:68.0/255.0
                                                   green:68.0/255.0
                                                    blue:68.0/255.0
                                                   alpha:1.0];
             [mutableAttributedString addAttribute:(NSString *) kCTForegroundColorAttributeName value:(id)[textColor CGColor] range:stringRange];
         }
     }];
    
    return mutableAttributedString;
}

+ (CGSize)tweetLabelSizeForTweet:(TWTweet*)tweet forWidth:(CGFloat)width{
    NSAttributedString * attrString = [MMTweetCell attributedStringForTweet:tweet];
    
    CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString( (__bridge CFMutableAttributedStringRef) attrString); 
    CGSize suggestedSize = CTFramesetterSuggestFrameSizeWithConstraints(framesetter, CFRangeMake(0, 0), NULL, CGSizeMake(width, CGFLOAT_MAX), NULL);
    CFRelease(framesetter);
    
    return suggestedSize;
}

@end
