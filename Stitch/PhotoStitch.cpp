//
//  PhotoStitch.cpp
//  Stitch
//
//  Created by Thomas Traylor on 1/9/14.
//  Copyright (c) 2014 Thomas Traylor. All rights reserved.
//

#include <iostream>
#include <opencv2/opencv.hpp>
#include <opencv2/nonfree/nonfree.hpp>
#include <opencv2/stitching/stitcher.hpp>


#include "PhotoStitch.h"

using namespace cv;

PhotoStitch::PhotoStitch()
{
    imageArray.clear();
}

PhotoStitch::~PhotoStitch()
{
    
}

void PhotoStitch::addImage(CGImageRef image)
{
    std::cout << "Add Image" << std::endl;
    
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

    cv::Mat rgbmat((int)rows, (int)cols, CV_8UC3); // 8 bits per component, 3 channels
    cvtColor(cvmat, rgbmat, CV_RGBA2RGB, 3);
    
    std::cout << "rgbmat cols: " << rgbmat.cols << std::endl;
    std::cout << "rgbmat rows: " << rgbmat.rows << std::endl;
    imageArray.push_back(rgbmat);

    std::cout << "Image Array size: " << imageArray.size() << std::endl;
    
    return;
}

CGImageRef PhotoStitch::imageCreate()
{
    std::cout << "imageCreate" << std::endl;
    
    cv::Mat result;
    bool try_use_gpu = true;
    cv::Stitcher stitcher = cv::Stitcher::createDefault(try_use_gpu);
    std::cout << "Image Array size: " << imageArray.size() << std::endl;
    stitcher.stitch(imageArray, result);
    CGColorSpaceRef colorSpace;
    
    CFDataRef data = CFDataCreate(kCFAllocatorDefault, result.data, result.elemSize()*result.total());
    
    std::cout << "results cols: " << result.cols << std::endl;
    std::cout << "results rows: " << result.rows << std::endl;
    
    std::cout << "data size: " << CFDataGetLength(data) << std::endl;
    
    if (result.elemSize() == 1)
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
