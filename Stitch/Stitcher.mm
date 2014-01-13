//
//  Stitcher.m
//  Stitch
//
//  Created by Thomas Traylor on 1/11/14.
//  Copyright (c) 2014 Thomas Traylor. All rights reserved.
//

#import "Stitcher.h"
#import "PhotoStitch.h"

@interface Stitcher ()

@property (nonatomic, readwrite, assign) PhotoStitch *ps;

@end

@implementation Stitcher

@synthesize ps = _ps;

- (id)init
{
    self = [super init];
    if(self)
    {
        _ps = new PhotoStitch;
    }
    
    return self;
}

- (void)dealloc
{
    delete _ps;
}

- (void)addImage:(UIImage *)image
{
    self.ps->addImage(image.CGImage);
    
}

- (UIImage*)imageCreate
{
    CGImageRef image = self.ps->imageCreate();
    UIImage *im = [UIImage imageWithCGImage:image scale:1.0 orientation:UIImageOrientationRight];
    CGImageRelease(image);
    return im;
}

@end
