//
//  Stitcher.h
//  Stitch
//
//  Created by Thomas Traylor on 1/11/14.
//  Copyright (c) 2014 Thomas Traylor. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Stitcher : NSObject

- (id)init;
- (void)addImage:(UIImage*)image;
- (UIImage *)imageCreate;

@end
