//
//  ZBCollectionViewFlowLayout.h
//  ZBCollectionViewSectionBackgroundDemo
//
//  Created by ZB on 2020/2/21.
//  Copyright © 2020 ZB. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@protocol ZBCollectionViewDelegateFlowLayout <UICollectionViewDelegateFlowLayout>

- (UIColor *)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout backgroundColorForSection:(NSInteger)section;

@end

@interface ZBCollectionViewFlowLayout : UICollectionViewFlowLayout

@property (strong, nonatomic) NSMutableArray<UICollectionViewLayoutAttributes *> *attributesArray;


@end

NS_ASSUME_NONNULL_END
