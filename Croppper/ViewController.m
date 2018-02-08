//
//  ViewController.m
//  Croppper
//
//  Created by Hovhannes Stepanyan on 2/7/18.
//  Copyright © 2018 Hovhannes Stepanyan. All rights reserved.
//

#import "ViewController.h"
#import "DashLayer.h"
@import Photos;

@interface ViewController () <UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIGestureRecognizerDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIView *croppingView;
@property (nonatomic) DashLayer *border;
@property (nonatomic) CGAffineTransform imageInitialTransform;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.border = [[DashLayer alloc] initWithFrame:self.croppingView.bounds];
    self.imageInitialTransform = self.imageView.transform;
    NSString *message = @"Choose an image to crop it";
    UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:nil
                                                                     message:message
                                                              preferredStyle:UIAlertControllerStyleAlert];
    __weak ViewController *weakSelf = self;
    UIAlertAction *ok = [UIAlertAction actionWithTitle:@"OK"
                                                 style:UIAlertActionStyleDefault
                                               handler:^(UIAlertAction * _Nonnull action) {
                                                   [weakSelf openImagePicker:nil];
                                               }];
    [alertVC addAction:ok];
    [self presentViewController:alertVC animated:YES completion:NULL];
}

#pragma mark - button actions

// Open image picker view controller to choose image
- (IBAction)openImagePicker:(UIBarButtonItem *)sender {
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    [self presentViewController:picker animated:YES completion:NULL];
}

// Save cropped image
- (IBAction)save:(UIBarButtonItem *)sender {

}

- (void)addBorderToCroppingView {
    [self.croppingView.layer addSublayer:self.border];
}


#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(nonnull NSDictionary<NSString *,id> *)info {
    UIImage *pickedImage = info[UIImagePickerControllerOriginalImage];
    self.imageView.image = pickedImage;
    self.imageView.transform = self.imageInitialTransform;
    [self addBorderToCroppingView];
    [picker dismissViewControllerAnimated:YES completion:NULL];
}

#pragma mark - UIGestureRecognizerDelegate

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}

#pragma mark - UIGestureRecognizerHandlers

- (IBAction)rotateImage:(UIRotationGestureRecognizer *)sender {
    if (sender.state == UIGestureRecognizerStateBegan || sender.state == UIGestureRecognizerStateChanged) {
        sender.view.transform = CGAffineTransformRotate(sender.view.transform, sender.rotation);
        sender.rotation = 0.f;
    }
}

- (IBAction)moveImage:(UIPanGestureRecognizer *)sender {
    if (sender.state == UIGestureRecognizerStateBegan || sender.state == UIGestureRecognizerStateChanged) {
        CGPoint translation = [sender translationInView:self.view];
        sender.view.center = CGPointMake(sender.view.center.x + translation.x,
                                         sender.view.center.y + translation.y);
        [sender setTranslation:CGPointMake(0, 0) inView:self.view];
    }
}

- (IBAction)zoomImage:(UIPinchGestureRecognizer *)sender {
    if (sender.state == UIGestureRecognizerStateBegan || sender.state == UIGestureRecognizerStateChanged) {
        sender.view.transform = CGAffineTransformScale(sender.view.transform, sender.scale, sender.scale);
        sender.scale = 1.f;
    }
}


@end
