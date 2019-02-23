//
//  PopularMoviesViewController.m
//  TMDB
//
//  Created by Maksym Bondar on 2/23/19.
//  Copyright © 2019 Maksym Bondar. All rights reserved.
//

#import "PopularMoviesViewController.h"
#import "MovieTableViewCell.h"
#import "APIKeys.h"

static NSString *kDelailsAboutFilm = @"detailsAboutFilm";

@interface PopularMoviesViewController ()

@property (strong, nonatomic, readwrite) NSOperationQueue *queue;
@property (strong, nonatomic) NSMutableArray *films;
@property (strong, nonatomic) NSIndexPath *selectedFilm;
@end

@implementation PopularMoviesViewController



- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.queue = [NSOperationQueue new];
    self.queue.maxConcurrentOperationCount = 5;
    self.queue.qualityOfService = NSQualityOfServiceUserInitiated;
    self.films = [[NSMutableArray alloc] init];
    
    for (NSUInteger page = 0; page < 5; page++) {
        [self.queue addOperationWithBlock:^{
            NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
            NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[APIKeys popularFilmsFromPage:@(page + 1)]];
            [request setHTTPMethod:@"GET"];
            NSURLSessionDataTask *downloadTask = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                if (!error) {
                    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse*)response;
                    if (httpResponse.statusCode == 200) {
                        NSDictionary *JSON = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
                        if (JSON[@"results"] != nil) {
                            for (NSDictionary *film in JSON[@"results"]) {
                                [self.films addObject:film];
                            }
                        }
                    } else if (httpResponse.statusCode == 401) {
                        NSLog(@"Invalid API key: You must be granted a valid key.");
                    } else {
                        NSLog(@"The resource you requested could not be found.");
                    }
                }
                
            }];
            [downloadTask resume];
        }];
    }
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.queue addObserver:self forKeyPath:@"operations" options:NSKeyValueObservingOptionNew context:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.queue removeObserver:self forKeyPath:@"operations" context:nil];
}

// MARK: TableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger filmsCount = 10;
    if (self.films.count != 0) {
        filmsCount = self.films.count;
    }
    return filmsCount;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MovieTableViewCell *movieCell = [tableView dequeueReusableCellWithIdentifier:MovieTableViewCell.reuseIdentifier];
    
    if (nil != movieCell) {
        if (self.films.count > 0) {
            NSDictionary *film = self.films[indexPath.row];
            dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
                NSString *posterName = film[@"poster_path"];
                NSData *data = [NSData dataWithContentsOfURL:[APIKeys moviePosterWithPath:posterName]];
                UIImage *filmPoster = [UIImage imageWithData:data];
                dispatch_async(dispatch_get_main_queue(), ^(void){
                    movieCell.filmPoster.image = filmPoster;
                });
            });
            movieCell.filmTitle.text = film[@"original_title"];
            movieCell.filmAvarateVote.text = [NSString stringWithFormat:@"Vote average: %@", film[@"vote_average"]];
        } else {
            UIImage *theImage = [UIImage imageNamed:@"film"];
            movieCell.filmPoster.image = theImage;
            movieCell.filmTitle.text = @"Film title";
            movieCell.filmAvarateVote.text = @"Vote avarage: 10";
        }
    } else {
        return [[UITableViewCell alloc] init];
    }
    return movieCell;
}

// MARK: TableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    self.selectedFilm = indexPath;
    [self performSegueWithIdentifier:kDelailsAboutFilm sender:self];
}

// MARK: KVO

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (object == self.queue && [keyPath isEqualToString:@"operations"]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
        });
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if (segue.identifier == kDelailsAboutFilm) {
        
    }
}

@end
