//
//  PopularMoviesViewController.m
//  TMDB
//
//  Created by Maksym Bondar on 2/23/19.
//  Copyright © 2019 Maksym Bondar. All rights reserved.
//

#import "PopularMoviesViewController.h"
#import "MovieTableViewCell.h"
#import "APITMDB.h"
#import "MovieViewController.h"

static NSString *kDelailsAboutFilmSegueIdentifier = @"delailsAboutFilmSegueIdentifier";
static NSString *kKVOOperationQueue = @"operations";
static NSString *kDefaultPosterName = @"film";

@interface PopularMoviesViewController ()

@property (strong, nonatomic, readwrite) NSOperationQueue *queue;
@property (strong, nonatomic) NSMutableArray *films;
@property (strong, nonatomic) NSIndexPath *selectedFilm;
@end

@implementation PopularMoviesViewController

// MARK: Controller lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.queue = [NSOperationQueue new];
    self.queue.maxConcurrentOperationCount = 5;
    self.queue.qualityOfService = NSQualityOfServiceUserInitiated;
    self.films = [[NSMutableArray alloc] init];
    
    for (NSUInteger page = 0; page < 1; page++) {
        __weak typeof(self) weakSelf = self;
        [self.queue addOperationWithBlock:^{
            typeof(self) strongSelf = weakSelf;
            NSURLSessionDataTask *loadTask = [APITMDB makeRequestForPage:@(page + 1)
                             completion:^(NSDictionary *JSONResults) {
                                 if (JSONResults[kPopularFilms] != nil) {
                                     for (NSDictionary *film in JSONResults[kPopularFilms]) {
                                         [strongSelf.films addObject:film];
                                     }
                                     dispatch_async(dispatch_get_main_queue(), ^{
                                         [self.tableView reloadData];
                                         NSLog(@"Reload data");
                                     });
                                 }}];
            [loadTask resume];
        }];
    }
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.queue addObserver:self forKeyPath:kKVOOperationQueue options:NSKeyValueObservingOptionInitial context:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.queue removeObserver:self forKeyPath:kKVOOperationQueue context:nil];
}

// MARK: TableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.films.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MovieTableViewCell *movieCell = [tableView dequeueReusableCellWithIdentifier:MovieTableViewCell.reuseIdentifier];
    
    if (nil != movieCell) {
        if (self.films.count > 0) {
            NSDictionary *film = self.films[indexPath.row];
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
                UIImage *moviePoster = [self getPosterWithName:film[kMoviePosterPath]];
                dispatch_async(dispatch_get_main_queue(), ^(void){
                    movieCell.filmPoster.image = moviePoster;
                });
            });
            movieCell.filmTitle.text = film[kMovieOriginalTitle];
            movieCell.filmAvarateVote.text = [NSString stringWithFormat:@"Vote average: %@", film[kMovieVoteAvarage]];
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
    [self performSegueWithIdentifier:kDelailsAboutFilmSegueIdentifier sender:self];
}

// MARK: KVO

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (object == self.queue && [keyPath isEqualToString:kKVOOperationQueue] && self.queue.operationCount == 0) {
        
    }
}

// MARK: Segue

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:kDelailsAboutFilmSegueIdentifier] && self.selectedFilm != nil) {
        MovieViewController *destinationVC = [segue destinationViewController];
        destinationVC.movieId = self.films[self.selectedFilm.row][kMovieId];
        destinationVC.movieOriginalTitle = self.films[self.selectedFilm.row][kMovieOriginalTitle];
        destinationVC.moviePosterPath = self.films[self.selectedFilm.row][kMoviePosterPath];
    }
}

- (UIImage *)getPosterWithName:(NSString *)posterPath {
    if (posterPath == nil) {
        return [UIImage imageNamed:kDefaultPosterName];
    }
    
    NSData *imageData = nil;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsPath = [paths objectAtIndex:0]; //Get the docs directory
    NSString *filePath = [documentsPath stringByAppendingPathComponent:posterPath];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    if (![fileManager fileExistsAtPath:filePath]){
        imageData = [NSData dataWithContentsOfURL:[APITMDB moviePosterWithPath:posterPath]];
        NSLog(@"Image loaded from server with name %@", posterPath);
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^(void){
            [imageData writeToFile:filePath atomically:YES];
        });
    } else {
        imageData = [NSData dataWithContentsOfFile:filePath];
        NSLog(@"Image loaded by path %@", filePath);
    }
    return [UIImage imageWithData:imageData];
}

@end
