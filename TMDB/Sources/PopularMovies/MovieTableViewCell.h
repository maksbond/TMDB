//
//  MovieTableViewCell.h
//  TMDB
//
//  Created by Maksym Bondar on 2/23/19.
//  Copyright © 2019 Maksym Bondar. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MovieTableViewCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UIImageView *filmPoster;
@property (strong, nonatomic) IBOutlet UILabel *filmTitle;
@property (strong, nonatomic) IBOutlet UILabel *filmAvarateVote;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *imageLoadingIndicator;

+ (NSString *)reuseIdentifier;

@end
