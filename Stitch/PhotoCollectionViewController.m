//
//  PhotoCollectionViewController.m
//  Stitch
//
//  Created by Thomas Traylor on 1/12/14.
//  Copyright (c) 2014 Thomas Traylor. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>
#import "PhotoCollectionViewController.h"
#import "PhotoCollectionViewCell.h"
#import "PanoViewController.h"

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
    UIImage *image;
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"image1" ofType:@"jpg"];
    image = [[UIImage alloc] initWithContentsOfFile:filePath];
    [self.photoArray addObject:image];
    
    filePath = [[NSBundle mainBundle] pathForResource:@"image2" ofType:@"jpg"];
    image = [[UIImage alloc] initWithContentsOfFile:filePath];
    [self.photoArray addObject:image];
    
    filePath = [[NSBundle mainBundle] pathForResource:@"image3" ofType:@"jpg"];
    image = [[UIImage alloc] initWithContentsOfFile:filePath];
    [self.photoArray addObject:image];
    
    filePath = [[NSBundle mainBundle] pathForResource:@"image4" ofType:@"jpg"];
    image = [[UIImage alloc] initWithContentsOfFile:filePath];
    [self.photoArray addObject:image];
    
    NSLog(@"[%@ %@] photoArray count: %d", NSStringFromClass([self class]), NSStringFromSelector(_cmd), self.photoArray.count);
   
    self.photoCollectionView.delegate = self;
    self.photoCollectionView.dataSource = self;
    //[self.photoCollectionView registerClass:[PhotoCollectionViewCell class] forCellWithReuseIdentifier:@"PhotoCell"];
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
    NSLog(@"[%@ %@] item: %d", NSStringFromClass([self class]), NSStringFromSelector(_cmd), indexPath.item);
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
        NSLog(@"[%@ %@] Number of sections: %d Number of rows: %d.", NSStringFromClass([self class]), NSStringFromSelector(_cmd),indexPath.section, indexPath.row);
        UIImage *image = [self.photoArray objectAtIndex:indexPath.item];

        [segue.destinationViewController setImage:image];

    }
    else if([segue.identifier isEqualToString:@"PanoView"])
    {
        [segue.destinationViewController setPhotos:self.photoArray];
    }
}
@end
