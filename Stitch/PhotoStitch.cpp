//
//  PhotoStitch.cpp
//  Stitch
//
//  Created by Thomas Traylor on 1/9/14.
//  Copyright (c) 2014 Thomas Traylor. All rights reserved.
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#include <iostream>
#include <opencv2/opencv.hpp>
#include <opencv2/nonfree/nonfree.hpp>
#include <opencv2/stitching/stitcher.hpp>

#include "PhotoStitch.h"

PhotoStitch::PhotoStitch()
{
    imageArray.clear();
}

PhotoStitch::~PhotoStitch()
{
    
}

void PhotoStitch::addImage(CGImageRef image)
{
    // std::cout << "Add Image" << std::endl;
    
    CGColorSpaceRef colorSpace = CGImageGetColorSpace(image);
    size_t cols = CGImageGetWidth(image);
    size_t rows = CGImageGetHeight(image);
    
    cv::Mat cvmat((int)rows, (int)cols, CV_8UC4);

    CGContextRef contextRef = CGBitmapContextCreate(cvmat.data, cols, rows, 8,
                                                    cvmat.step[0], colorSpace,
                                                    kCGImageAlphaNoneSkipLast |
                                                    kCGBitmapByteOrderDefault);
    
    CGContextDrawImage(contextRef, CGRectMake(0, 0, cols, rows), image);
    CGContextRelease(contextRef);

    cv::Mat rgbmat((int)rows, (int)cols, CV_8UC3);
    cvtColor(cvmat, rgbmat, CV_RGBA2RGB, 3);
    
    // std::cout << "rgbmat cols: " << rgbmat.cols << std::endl;
    // std::cout << "rgbmat rows: " << rgbmat.rows << std::endl;
    
    imageArray.push_back(rgbmat);

    return;
}

CGImageRef PhotoStitch::imageCreate()
{
    // std::cout << "imageCreate" << std::endl;
    
    cv::Mat result;
    bool try_use_gpu = true;
    
    // create the pano image
    cv::Stitcher stitcher = cv::Stitcher::createDefault(try_use_gpu);
    stitcher.stitch(imageArray, result);
    CGColorSpaceRef colorSpace;
    
    CFDataRef data = CFDataCreate(kCFAllocatorDefault, result.data, result.elemSize()*result.total());
    
    // std::cout << "results cols: " << result.cols << std::endl;
    // std::cout << "results rows: " << result.rows << std::endl;
    // std::cout << "data size: " << CFDataGetLength(data) << std::endl;
    
    if(result.elemSize() == 1)
    {
        colorSpace = CGColorSpaceCreateDeviceGray();
    }
    else
    {
        colorSpace = CGColorSpaceCreateDeviceRGB();
    }
    
    CGDataProviderRef provider = CGDataProviderCreateWithCFData(data);
    
    CGImageRef retImage = CGImageCreate(result.cols, result.rows, 8, 8 * result.elemSize(),
                                        result.step[0], colorSpace,
                                        kCGImageAlphaNone | kCGBitmapByteOrderDefault,
                                        provider, NULL, false, kCGRenderingIntentDefault);
    
    CFRelease(data);
    CGDataProviderRelease(provider);
    CGColorSpaceRelease(colorSpace);
    imageArray.clear();
    return retImage;
}
