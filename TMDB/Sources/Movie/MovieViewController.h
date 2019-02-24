//
//  MovieViewController.h
//  TMDB
//
//  Created by Maksym Bondar on 2/23/19.
//

#import <UIKit/UIKit.h>

@interface MovieViewController : UITableViewController

@property (strong, nonatomic) NSNumber *movieId;
@property (strong, nonatomic) NSString *movieOriginalTitle;
@property (strong, nonatomic) NSString *moviePosterPath;

@end
