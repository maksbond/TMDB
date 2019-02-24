//
//  APITMDB.m
//  TMDB
//
//  Created by Maksym Bondar on 2/23/19.
//  Copyright © 2019 Maksym Bondar. All rights reserved.
//

#import "APITMDB.h"

const NSString *kPopularFilms = @"results";
const NSString *kMoviePosterPath = @"poster_path";
const NSString *kMovieOriginalTitle = @"original_title";
const NSString *kMovieId = @"id";
const NSString *kMovieVoteAvarage = @"vote_average";
const NSString *kMovieOverView = @"overview";
const NSString *kMovieBudget = @"budget";
const NSString *kMovieRevenue = @"revenue";
const NSString *kMovieStatus = @"status";
const NSString *kMovieProductionCompanies = @"production_companies";
const NSString *kMovieProductionCompaniesLogoPath = @"logo_path";

@implementation APITMDB

+ (NSString *)apiKey {
    return @"6322befaa622f6bce01b023e2c9645d9";
}

+ (NSURL *)popularFilmsFromPage:(NSNumber *)pageNumber; {
    return [NSURL URLWithString:[NSString stringWithFormat:@"https://api.themoviedb.org/3/movie/popular?api_key=%@&language=en-US&page=%@", [self apiKey], pageNumber.stringValue]];
}

+ (NSURL *)moviePosterWithPath:(NSString *)imagePath {
    return [NSURL URLWithString:[NSString stringWithFormat:@"https://image.tmdb.org/t/p/w500%@", imagePath]];
}

+ (NSURL *)movieById:(NSNumber *)movieId {
    return [NSURL URLWithString:[NSString stringWithFormat:@"https://api.themoviedb.org/3/movie/%@?api_key=%@&language=en-US", movieId, [self apiKey]]];
}

+ (NSURLSessionDataTask *)makeRequestForPage:(NSNumber *)pageNumber completion:(TMDBRequestResult)completionBlock {
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[APITMDB popularFilmsFromPage:pageNumber]];
    [request setHTTPMethod:@"GET"];
    __block NSMutableDictionary *JSON;
    NSURLSessionDataTask *downloadTask = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (!error) {
            NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse*)response;
            if (httpResponse.statusCode == 200) {
                JSON = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
                NSLog(@"Succesfully load page #%@", pageNumber);
                completionBlock(JSON);
            } else if (httpResponse.statusCode == 401) {
                NSLog(@"Invalid API key: You must be granted a valid key.");
            } else {
                NSLog(@"The resource you requested could not be found.");
            }
        }
        
    }];
    return downloadTask;
}

+ (NSURLSessionDataTask *)makeRequestForMovieWithId:(NSNumber *)movieId completion:(TMDBRequestResult)completionBlock {
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[APITMDB movieById:movieId]];
    [request setHTTPMethod:@"GET"];
    __block NSMutableDictionary *JSON;
    NSURLSessionDataTask *downloadTask = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (!error) {
            NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse*)response;
            if (httpResponse.statusCode == 200) {
                JSON = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
                NSLog(@"Succesfully load movie by id #%@", movieId);
                completionBlock(JSON);
            } else if (httpResponse.statusCode == 401) {
                NSLog(@"Invalid API key: You must be granted a valid key.");
            } else {
                NSLog(@"The resource you requested could not be found.");
            }
        }
        
    }];
    return downloadTask;
}

@end
