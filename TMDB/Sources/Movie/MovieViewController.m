//
//  MovieViewController.m
//  TMDB
//
//  Created by Maksym Bondar on 2/23/19.
//

#import "MovieViewController.h"
#import "CompanieCollectionViewCell.h"
#import "APITMDB.h"

@interface MovieViewController () <UICollectionViewDelegate, UICollectionViewDataSource>

@property (strong, nonatomic) IBOutlet UIImageView *moviePoster;
@property (strong, nonatomic) IBOutlet UILabel *voteAvarageLabel;
@property (strong, nonatomic) IBOutlet UITextView *overviewTextView;
@property (strong, nonatomic) IBOutlet UILabel *movieBudget;
@property (strong, nonatomic) IBOutlet UILabel *movieStatus;
@property (strong, nonatomic) IBOutlet UILabel *movieRevenue;
@property (strong, nonatomic) NSMutableArray<UIImage *> *companiesLogos;
@property (strong, nonatomic) IBOutlet UICollectionView *companiesCollectionView;

@end

@implementation MovieViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.companiesLogos = [[NSMutableArray alloc] init];
    self.title = self.movieOriginalTitle;
    NSURLSessionDataTask *loadTask = [APITMDB makeRequestForMovieWithId:self.movieId
                                                      completion:^(NSDictionary *JSONResults) {
                                                          NSLog(@"%@", JSONResults);
                                                          [self updateInfoWithJSON:JSONResults];
                                                      }];
    [loadTask resume];
    [self setupPoster];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)setupPoster {
    NSData *imageData = nil;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsPath = [paths objectAtIndex:0]; //Get the docs directory
    NSString *filePath = [documentsPath stringByAppendingPathComponent:self.moviePosterPath];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    if (![fileManager fileExistsAtPath:filePath]){
        imageData = [NSData dataWithContentsOfURL:[APITMDB moviePosterWithPath:self.moviePosterPath]];
        NSLog(@"Image loaded from server with name %@", self.moviePosterPath);
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^(void){
            [imageData writeToFile:filePath atomically:YES];
        });
    } else {
        imageData = [NSData dataWithContentsOfFile:filePath];
        NSLog(@"Image loaded by path %@", filePath);
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        self.moviePoster.image = [UIImage imageWithData:imageData];
    });
}

- (void)updateInfoWithJSON:(NSDictionary *)movieInfo {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
        NSArray *companies = movieInfo[kMovieProductionCompanies];
        NSData *imageData = nil;
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsPath = [paths objectAtIndex:0]; //Get the docs directory
        for (NSDictionary *company in companies) {
            NSString *filePath = [documentsPath stringByAppendingPathComponent:company[kMovieProductionCompaniesLogoPath]];
            NSFileManager *fileManager = [NSFileManager defaultManager];
            
            BOOL saveImage = NO;
            if (![fileManager fileExistsAtPath:filePath]){
                imageData = [NSData dataWithContentsOfURL:[APITMDB moviePosterWithPath:company[kMovieProductionCompaniesLogoPath]]];
                NSLog(@"Image loaded from server with name %@", company[kMovieProductionCompaniesLogoPath]);
                saveImage = YES;
                
            } else {
                imageData = [NSData dataWithContentsOfFile:filePath];
                NSLog(@"Image loaded by path %@", filePath);
            }
            UIImage *originalImage = [UIImage imageWithData:imageData];
            imageData = UIImageJPEGRepresentation(originalImage, 0.25);
            if (saveImage) {
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^(void){
                    [imageData writeToFile:filePath atomically:YES];
                });
            }
            [self.companiesLogos addObject:[UIImage imageWithData:imageData]];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.companiesCollectionView reloadData];
        });
    });
    dispatch_async(dispatch_get_main_queue(), ^{
        self.voteAvarageLabel.text = [(NSNumber *)movieInfo[kMovieVoteAvarage] stringValue];
        self.overviewTextView.text = movieInfo[kMovieOverView];
        NSString *movieBudget = @"Unknown";
        if (movieInfo[kMovieBudget] != nil) {
            movieBudget = [NSString stringWithFormat:@"%@$", movieInfo[kMovieBudget]];
        }
        self.movieBudget.text = movieBudget;
        NSString *movieStatus = @"Unknown";
        if (movieInfo[kMovieStatus] != nil) {
            movieStatus = movieInfo[kMovieStatus];
        }
        self.movieStatus.text = movieStatus;
        NSString *movieRevenue = @"Unknown";
        if (movieInfo[kMovieRevenue] != nil) {
            movieRevenue = [NSString stringWithFormat:@"%@$", movieInfo[kMovieRevenue]];
        }
        self.movieRevenue.text = movieRevenue;
    });
}

- (NSInteger)collectionView:(nonnull UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.companiesLogos.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    CompanieCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:CompanieCollectionViewCell.reuseIdentifier forIndexPath:indexPath];
    
    if (cell != nil) {
        if (self.companiesLogos.count > 0) {
            cell.companyLogo.image = self.companiesLogos[indexPath.item];
        }
    } else {
        return [[UICollectionViewCell alloc] init];
    }
    return cell;
}

@end
