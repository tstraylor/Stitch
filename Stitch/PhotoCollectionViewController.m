//
//  PhotoCollectionViewController.m
//  Stitch
//
//  Created by Thomas Traylor on 1/12/14.
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

#import <MobileCoreServices/MobileCoreServices.h>
#import <AVFoundation/AVFoundation.h>
#import "PhotoCollectionViewController.h"
#import "PhotoCollectionViewCell.h"
#import "PanoViewController.h"
#import "UIImage+Scale.h"

@interface PhotoCollectionViewController ()

@property (strong, nonatomic) NSMutableArray *photoArray;
@property (weak, nonatomic) IBOutlet UICollectionView *photoCollectionView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *trashButton;

@property (weak, nonatomic) IBOutlet UIToolbar *toolBar;

@end

@implementation PhotoCollectionViewController

@synthesize photoArray = _photoArray;
@synthesize photoCollectionView = _photoCollectionView;
@synthesize trashButton = _trashButton;
@synthesize toolBar = _toolBar;

#pragma mark - View Lifecycle

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    // NSLog(@"[%@ %@]", NSStringFromClass([self class]), NSStringFromSelector(_cmd));

    self.photoArray = [[NSMutableArray alloc] init];
    self.trashButton.enabled = NO;
    self.photoCollectionView.delegate = self;
    self.photoCollectionView.dataSource = self;

    // check to see if there is a camera, if not then we'll pick the photos needed
    // from the photo library
    if (![UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceRear])
    {
        UIBarButtonItem *add = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
                                                                             target:self
                                                                             action:@selector(addImage:)];
        
        NSMutableArray *items = [[NSMutableArray alloc] initWithArray:self.toolBar.items];
        [items removeObjectAtIndex:0];
        [items insertObject:add atIndex:0];
        [self.toolBar setItems:items];
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    // NSLog(@"[%@ %@]", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    [super viewDidAppear:animated];
    if([self.photoArray count] > 0)
    {
        self.trashButton.enabled = YES;
    }
    
    [self.photoCollectionView reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - CollectionViewControllerDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    // NSLog(@"[%@ %@]", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    // NSLog(@"[%@ %@]", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    return self.photoArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    //NSLog(@"[%@ %@] item: %ld", NSStringFromClass([self class]), NSStringFromSelector(_cmd), (long)indexPath.item);
    PhotoCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"PhotoCell" forIndexPath:indexPath];
    cell.photoImageView.image = (UIImage*)[self.photoArray objectAtIndex:indexPath.item];
    [cell.photoImageView setFrame:AVMakeRectWithAspectRatioInsideRect(cell.photoImageView.image.size, cell.photoImageView.frame)];

    return cell;
}

#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    // NSLog(@"[%@ %@]", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
}

#pragma mark - Segue

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // NSLog(@"[%@ %@] segue id: %@.", NSStringFromClass([self class]), NSStringFromSelector(_cmd), segue.identifier);
    
    if ([segue.identifier isEqualToString:@"ViewPhoto"])
    {
        PhotoCollectionViewCell *cell = (PhotoCollectionViewCell *)sender;
        NSIndexPath *indexPath = [self.photoCollectionView indexPathForCell:cell];
        UIImage *image = [self.photoArray objectAtIndex:indexPath.item];

        [segue.destinationViewController setImage:image];

    }
    else if([segue.identifier isEqualToString:@"PanoView"])
    {
            [segue.destinationViewController setPhotos:self.photoArray];
    }
    
}

#pragma mark - IBAction

- (IBAction)panoButtonPressed:(UIBarButtonItem *)sender
{
    // check to see if there are photos to work with.
    if(self.photoArray.count > 0)
    {
        [self performSegueWithIdentifier:@"PanoView" sender:self];
    }
    else
    {
        UIAlertView *noPhotos = [[UIAlertView alloc] initWithTitle:@"No Photos Found"
                                                           message:@"More than one photo is needed to create a pano image."
                                                          delegate:nil
                                                 cancelButtonTitle:@"OK"
                                                 otherButtonTitles:nil, nil];
        [noPhotos show];
        
    }

}

- (IBAction)trashPhotos:(UIBarButtonItem *)sender
{
    [self.photoArray removeAllObjects];
    self.trashButton.enabled = NO;
    [self.photoCollectionView reloadData];
}

- (IBAction)takePhoto:(UIBarButtonItem *)sender
{
    NSLog(@"[%@ %@]", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    NSArray *mediaTypes = [UIImagePickerController availableMediaTypesForSourceType:UIImagePickerControllerSourceTypeCamera];
    
    if ([mediaTypes containsObject:(NSString *)kUTTypeImage])
    {
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.delegate = self;
        picker.sourceType = UIImagePickerControllerSourceTypeCamera;
        picker.mediaTypes = [NSArray arrayWithObject:(NSString *)kUTTypeImage];
        picker.allowsEditing = NO;
        [self presentViewController:picker animated:YES completion:nil];
    }
}

- (IBAction)addImage:(UIBarButtonItem *)sender
{
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    picker.mediaTypes = [NSArray arrayWithObject:(NSString *)kUTTypeImage];
    picker.allowsEditing = NO;
    [self presentViewController:picker animated:YES completion:nil];
}

#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    // dismiss the uiimagepickercontroller
    [self dismissViewControllerAnimated:YES completion:nil];
    
    UIImage *photo = [info objectForKey:UIImagePickerControllerEditedImage];
    
    if(!photo)
        photo = [info objectForKey:UIImagePickerControllerOriginalImage];

    if(photo)
    {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            
            // we need to reduce the size of the images we are working with.
            // if we don't we will run out of memory quickly
            [self.photoArray addObject:[photo scaleImageBy:0.60f]];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                if(!self.trashButton.enabled)
                    self.trashButton.enabled = YES;
                
                [self.photoCollectionView reloadData];
                
            });
        });
    }
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
