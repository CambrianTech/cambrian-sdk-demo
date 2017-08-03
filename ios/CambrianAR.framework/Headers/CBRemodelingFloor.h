//
//  CBRemodelingFloor.h
//  CambrianAR
//
//  Created by Joel Teply on 3/3/17.
//  Copyright © 2017 Joel Teply. All rights reserved.
//

#import "CBAugmentedAsset.h"

NS_ASSUME_NONNULL_BEGIN

__attribute__((visibility("default")))
@interface CBRemodelingFloor : CBAugmentedAsset

- (void)setPath:(NSString *) path scale:(float)scale;

@end


NS_ASSUME_NONNULL_END
