//
//  PanoViewController.m
//  Stitch
//
//  Created by Thomas Traylor on 1/10/14.
//  Copyright (c) 2014 Thomas Traylor. All rights reserved.
//
#import <AssetsLibrary/AssetsLibrary.h>
#import "PanoViewController.h"
#import "Stitcher.h"

@interface PanoViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (strong, nonatomic) Stitcher *stitcher;
@property (strong, nonatomic) NSArray *photos;

@end

@implementation PanoViewController

@synthesize imageView = _imageView;
@synthesize activityIndicator = _activityIndicator;
@synthesize stitcher = _stitcher;
@synthesize photos = _photos;

- (void)setPhotos:(NSArray *)photos
{
    _photos = photos;
}

- (void)viewDidLoad
{
    NSLog(@"[%@ %@]", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.

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
    self.imageView.image = [self.stitcher imageCreate];
    [self.activityIndicator stopAnimating];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)saveButtonPressed:(UIBarButtonItem *)sender
{
    ALAssetsLibrary *lib = [[ALAssetsLibrary alloc] init];
    [lib writeImageToSavedPhotosAlbum:self.imageView.image.CGImage orientation:ALAssetOrientationUp completionBlock:^(NSURL *assetURL, NSError *error) {
        if(error)
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                UIAlertView *noPhotos = [[UIAlertView alloc] initWithTitle:@"Unable to Save Photo"
                                                                   message:error.localizedDescription
                                                                  delegate:nil
                                                         cancelButtonTitle:@"OK"
                                                         otherButtonTitles:nil, nil];
                [noPhotos show];
            });
        }
    }];
}

@end
