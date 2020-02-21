//
//  CollectionViewCell.h
//  ZBCollectionViewSectionBackgroundDemo
//
//  Created by ZB on 2020/2/21.
//  Copyright © 2020 ZB. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface CollectionViewCell : UICollectionViewCell

@property (strong, nonatomic) IBOutlet UIImageView *imageView;
@property (strong, nonatomic) IBOutlet UILabel *titleLab;
@end

NS_ASSUME_NONNULL_END
