//
//  PhotoStitch.h
//  Stitch
//
//  Created by Thomas Traylor on 1/10/14.
//  Copyright (c) 2014 Thomas Traylor. All rights reserved.
//

#ifndef Stitch_Stitch_h
#define Stitch_Stitch_h

#include <CoreGraphics/CoreGraphics.h>
#include <sys/cdefs.h>
#include <vector>

#include <opencv2/opencv.hpp>

class PhotoStitch
{
public:
    PhotoStitch();
    ~PhotoStitch();
    
    void addImage(CGImageRef image);
    
    CGImageRef imageCreate();
    
private:
    
    std::vector<cv::Mat> imageArray;
    
};

#if 0
__BEGIN_DECLS

CGImageRef stitchedImageCreate(CGImageRef image1, CGImageRef image2);

__END_DECLS

#endif

#endif
