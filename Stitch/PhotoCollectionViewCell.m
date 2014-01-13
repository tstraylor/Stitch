//
//  PhotoCollectionViewCell.m
//  Stitch
//
//  Created by Thomas Traylor on 1/12/14.
//  Copyright (c) 2014 Thomas Traylor. All rights reserved.
//

#import "PhotoCollectionViewCell.h"

@implementation PhotoCollectionViewCell

@synthesize photoImageView = _photoImageView;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        _photoImageView = [[UIImageView alloc] init];
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
