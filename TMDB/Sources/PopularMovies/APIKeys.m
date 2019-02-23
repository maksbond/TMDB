//
//  APIKeys.m
//  TMDB
//
//  Created by Maksym Bondar on 2/23/19.
//  Copyright © 2019 Maksym Bondar. All rights reserved.
//

#import "APIKeys.h"

@implementation APIKeys

+ (NSString *)apiKey {
    return @"6322befaa622f6bce01b023e2c9645d9";
}

+ (NSURL *)popularFilmsFromPage:(NSNumber *)pageNumber; {
    return [NSURL URLWithString:[NSString stringWithFormat:@"https://api.themoviedb.org/3/movie/popular?api_key=%@&language=en-US&page=%@", [self apiKey], pageNumber.stringValue]];
}

+ (NSURL *)moviePosterWithPath:(NSString *)imagePath {
    return [NSURL URLWithString:[NSString stringWithFormat:@"https://image.tmdb.org/t/p/w500%@", imagePath]];
}


@end
