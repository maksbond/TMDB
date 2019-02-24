//
//  CompanieCollectionViewCell.h
//  TMDB
//
//  Created by Maksym Bondar on 2/24/19.
//

#import <UIKit/UIKit.h>

@interface CompanieCollectionViewCell : UICollectionViewCell

@property (strong, nonatomic) IBOutlet UIImageView *companyLogo;

+(NSString *)reuseIdentifier;

@end
