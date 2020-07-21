//
//  ZBCollectionViewFlowLayout.m
//  ZBCollectionViewSectionBackgroundDemo
//
//  Created by ZB on 2020/2/21.
//  Copyright © 2020 ZB. All rights reserved.
//

#import "ZBCollectionViewFlowLayout.h"
#import "ZBCollectionReusableView.h"

NSString *const ZBCollectionViewSectionBackground = @"ZBCollectionViewSectionBackground";

@implementation ZBCollectionViewFlowLayout

- (instancetype)init {
    self = [super init];
    if (self) {
        self.attributesArray = [NSMutableArray array];
        [self registerClass:[ZBCollectionReusableView class] forDecorationViewOfKind:ZBCollectionViewSectionBackground];
    }
    return self;
}

- (void)prepareLayout{
    [super prepareLayout];
    [self.attributesArray removeAllObjects];
    
    NSInteger numberOfSections = [self.collectionView numberOfSections];
    id delegate = self.collectionView.delegate;
    if (!numberOfSections || ![delegate conformsToProtocol:@protocol(ZBCollectionViewDelegateFlowLayout)]) {
        return;
    }
    
    for (NSInteger section = 0; section < numberOfSections; section++) {
        NSInteger numberOfItems = [self.collectionView numberOfItemsInSection:section];
        if (numberOfItems <= 0) {
            continue;
        }
        UICollectionViewLayoutAttributes *firstItem = [self layoutAttributesForItemAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:section]];
        UICollectionViewLayoutAttributes *lastItem = [self layoutAttributesForItemAtIndexPath:[NSIndexPath indexPathForItem:numberOfItems - 1 inSection:section]];
        if (!firstItem || !lastItem) {
            continue;
        }
        
        
        UIEdgeInsets sectionInset = [self sectionInset];
        
        if ([delegate respondsToSelector:@selector(collectionView:layout:insetForSectionAtIndex:)]) {
            UIEdgeInsets inset = [delegate collectionView:self.collectionView layout:self insetForSectionAtIndex:section];
            sectionInset = inset;
        }
        
        CGRect sectionFrame = CGRectUnion(firstItem.frame, lastItem.frame);
        sectionFrame.origin.x -= sectionInset.left - 15;
        sectionFrame.origin.y -= sectionInset.top;
        
        if (self.scrollDirection == UICollectionViewScrollDirectionHorizontal) {
            sectionFrame.size.width += sectionInset.left + sectionInset.right - 30;
            sectionFrame.size.height = self.collectionView.frame.size.height;
        } else {
            sectionFrame.size.width = self.collectionView.frame.size.width - 30;
            sectionFrame.size.height += sectionInset.top + sectionInset.bottom;
        }
        
        
        UICollectionViewLayoutAttributes *attr = [UICollectionViewLayoutAttributes layoutAttributesForDecorationViewOfKind:ZBCollectionViewSectionBackground withIndexPath:[NSIndexPath indexPathForItem:0 inSection:section]];
        attr.frame = sectionFrame;
        attr.zIndex = -1;
        [self.attributesArray addObject:attr];
    }
}

- (NSArray<UICollectionViewLayoutAttributes *> *)layoutAttributesForElementsInRect:(CGRect)rect{
    NSMutableArray *attrs = [[super layoutAttributesForElementsInRect:rect] mutableCopy];
    for (UICollectionViewLayoutAttributes *attr in self.attributesArray) {
        if (CGRectIntersectsRect(rect, attr.frame)) {
            [attrs addObject:attr];
        }
    }
    return attrs;
}

- (nullable UICollectionViewLayoutAttributes *)layoutAttributesForDecorationViewOfKind:(NSString*)elementKind atIndexPath:(NSIndexPath *)indexPath{
    if ([elementKind isEqualToString:ZBCollectionViewSectionBackground]) {
        return [self.attributesArray objectAtIndex:indexPath.section];
    }
    return [super layoutAttributesForDecorationViewOfKind:elementKind atIndexPath:indexPath];
}

@end
