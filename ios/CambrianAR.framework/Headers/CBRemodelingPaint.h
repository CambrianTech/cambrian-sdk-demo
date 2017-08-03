//
//  CBRemodelingPaint.h
//  CambrianAR
//
//  Created by Joel Teply on 3/3/17.
//  Copyright © 2017 Joel Teply. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CBAugmentedAsset.h"
#import "CBRemodelingTypes.h"

NS_ASSUME_NONNULL_BEGIN

__attribute__((visibility("default")))
@interface CBRemodelingPaint : CBAugmentedAsset

@property (nonatomic, strong, nonnull) UIColor* color;
@property (nonatomic, assign) CBTransparency transparency;
@property (nonatomic, assign) CBPaintSheen sheen;

@end

NS_ASSUME_NONNULL_END
