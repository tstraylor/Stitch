//
//  PanoViewController.m
//  Stitch
//
//  Created by Thomas Traylor on 1/10/14.
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

#import <AssetsLibrary/AssetsLibrary.h>
#import "PanoViewController.h"
#import "Stitcher.h"

@interface PanoViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (strong, nonatomic) Stitcher *stitcher;
@property (strong, nonatomic) NSArray *photos;
@property (strong, nonatomic) UIImage *pano;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *saveButton;

@end

@implementation PanoViewController

@synthesize imageView = _imageView;
@synthesize activityIndicator = _activityIndicator;
@synthesize stitcher = _stitcher;
@synthesize photos = _photos;
@synthesize pano = _pano;
@synthesize saveButton = _saveButton;

#pragma mark - Setters

- (void)setPhotos:(NSArray *)photos
{
    _photos = photos;
}

#pragma mark - View Lifecycle

- (void)viewDidLoad
{
    // NSLog(@"[%@ %@]", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    [super viewDidLoad];
    
	// Do any additional setup after loading the view, typically from a nib.
    self.saveButton.enabled = YES;
    self.activityIndicator.hidesWhenStopped = YES;
    self.activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhiteLarge;
    self.activityIndicator.color = [UIColor redColor];
    self.stitcher = [[Stitcher alloc] init];
    
    for (UIImage *image in self.photos) {
        [self.stitcher addImage:image];
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.activityIndicator startAnimating];
    self.pano = [self.stitcher imageCreate];
    self.imageView.image = self.pano;
    [self.activityIndicator stopAnimating];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - IBAction

- (IBAction)saveButtonPressed:(UIBarButtonItem *)sender
{
    ALAssetsLibrary *lib = [[ALAssetsLibrary alloc] init];
    [lib writeImageToSavedPhotosAlbum:self.pano.CGImage
                          orientation:ALAssetOrientationUp
                      completionBlock:^(NSURL *assetURL, NSError *error) {
        if(error)
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                UIAlertView *noPhotos = [[UIAlertView alloc] initWithTitle:@"Unable to Save Photo."
                                                                   message:error.localizedDescription
                                                                  delegate:nil
                                                         cancelButtonTitle:@"OK"
                                                         otherButtonTitles:nil, nil];
                [noPhotos show];
            });
        }
        else
        {
            self.saveButton.enabled = NO;
            UIAlertView *photoSaved = [[UIAlertView alloc] initWithTitle:@"The photo has been saved."
                                                                 message:error.localizedDescription
                                                                delegate:nil
                                                       cancelButtonTitle:@"OK"
                                                       otherButtonTitles:nil, nil];
            [photoSaved show];
            
        }
    }];
}

@end
