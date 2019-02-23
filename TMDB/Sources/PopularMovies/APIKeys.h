//
//  APIKeys.h
//  TMDB
//
//  Created by Maksym Bondar on 2/23/19.
//  Copyright © 2019 Maksym Bondar. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface APIKeys : NSObject

+ (NSURL *)popularFilmsFromPage:(NSNumber *)pageNumber;
+ (NSURL *)moviePosterWithPath:(NSString *)imagePath ;

@end
