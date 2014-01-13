//
//  PhotoCollectionViewController.m
//  Stitch
//
//  Created by Thomas Traylor on 1/12/14.
//  Copyright (c) 2014 Thomas Traylor. All rights reserved.
//

#import <MobileCoreServices/MobileCoreServices.h>
#import <AVFoundation/AVFoundation.h>
#import "PhotoCollectionViewController.h"
#import "PhotoCollectionViewCell.h"
#import "PanoViewController.h"
#import "UIImage+Resize.h"

@interface PhotoCollectionViewController ()

@property (strong, nonatomic) NSMutableArray *photoArray;
@property (weak, nonatomic) IBOutlet UICollectionView *photoCollectionView;

@end

@implementation PhotoCollectionViewController

@synthesize photoArray = _photoArray;
@synthesize photoCollectionView = _photoCollectionView;

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
    NSLog(@"[%@ %@]", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    self.photoArray = [[NSMutableArray alloc] init];
    self.photoCollectionView.delegate = self;
    self.photoCollectionView.dataSource = self;

}

- (void)viewDidAppear:(BOOL)animated
{
    NSLog(@"[%@ %@]", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    [super viewDidAppear:animated];
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
    NSLog(@"[%@ %@]", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    NSLog(@"[%@ %@]", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    return self.photoArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"[%@ %@] item: %ld", NSStringFromClass([self class]), NSStringFromSelector(_cmd), (long)indexPath.item);
    PhotoCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"PhotoCell" forIndexPath:indexPath];
    
    cell.photoImageView.image = (UIImage*)[self.photoArray objectAtIndex:indexPath.item];
    [cell.photoImageView setFrame:AVMakeRectWithAspectRatioInsideRect(cell.photoImageView.image.size, cell.photoImageView.frame)];

    return cell;
}

#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"[%@ %@]", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
}

#pragma mark - Segue

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSLog(@"[%@ %@] segue id: %@.", NSStringFromClass([self class]), NSStringFromSelector(_cmd), segue.identifier);
    
    if ([segue.identifier isEqualToString:@"ViewPhoto"])
    {
        PhotoCollectionViewCell *cell = (PhotoCollectionViewCell *)sender;
        NSIndexPath *indexPath = [self.photoCollectionView indexPathForCell:cell];
        NSLog(@"[%@ %@] Number of sections: %ld Number of rows: %ld.", NSStringFromClass([self class]), NSStringFromSelector(_cmd),(long)indexPath.section, (long)indexPath.row);
        UIImage *image = [self.photoArray objectAtIndex:indexPath.item];

        [segue.destinationViewController setImage:image];

    }
    else if([segue.identifier isEqualToString:@"PanoView"])
    {
            [segue.destinationViewController setPhotos:self.photoArray];
    }
    
}

- (IBAction)panoButtonPressed:(UIBarButtonItem *)sender
{
    if(self.photoArray.count > 0)
    {
        [self performSegueWithIdentifier:@"PanoView" sender:self];
    }
    else
    {
        UIAlertView *noPhotos = [[UIAlertView alloc] initWithTitle:@"No Photos Found"
                                                           message:@"There are no photos to create a pano image."
                                                          delegate:nil
                                                 cancelButtonTitle:@"OK"
                                                 otherButtonTitles:nil, nil];
        [noPhotos show];
        
    }

}

- (IBAction)trashPhotos:(UIBarButtonItem *)sender
{
    [self.photoArray removeAllObjects];
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

#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [self dismissViewControllerAnimated:YES completion:nil];
    UIImage *photo = [info objectForKey:UIImagePickerControllerEditedImage];
    
    if(!photo)
        photo = [info objectForKey:UIImagePickerControllerOriginalImage];

    if(photo)
    {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            
            [self.photoArray addObject:[photo resizedImage:CGSizeMake(480.0, 640.0)
                                      interpolationQuality:kCGInterpolationDefault]];
            
            dispatch_async(dispatch_get_main_queue(), ^{
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
