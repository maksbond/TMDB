//
//  APITMDB.h
//  TMDB
//
//  Created by Maksym Bondar on 2/23/19.
//  Copyright © 2019 Maksym Bondar. All rights reserved.
//

#import <Foundation/Foundation.h>

extern const NSString *kPopularFilms;


extern const NSString *kMoviePosterPath;
extern const NSString *kMovieOriginalTitle;
extern const NSString *kMovieId;
extern const NSString *kMovieVoteAvarage;
extern const NSString *kMovieOverView;
extern const NSString *kMovieBudget;
extern const NSString *kMovieRevenue;
extern const NSString *kMovieStatus;
extern const NSString *kMovieProductionCompanies;
extern const NSString *kMovieProductionCompaniesLogoPath;

typedef void (^TMDBRequestResult)(NSDictionary *JSONResults);

@interface APITMDB : NSObject

+ (NSURLSessionDataTask *)makeRequestForPage:(NSNumber *)pageNumber completion:(TMDBRequestResult)completionBlock;
+ (NSURLSessionDataTask *)makeRequestForMovieWithId:(NSNumber *)movieId completion:(TMDBRequestResult)completionBlock;
+ (NSURL *)moviePosterWithPath:(NSString *)imagePath;

@end
