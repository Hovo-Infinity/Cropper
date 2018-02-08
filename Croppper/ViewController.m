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
    __weak ViewController *weakSelf = self;
    [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
        switch (status) {
            case PHAuthorizationStatusDenied: {
                [weakSelf askToOpenSettings];
            }
                break;
            case PHAuthorizationStatusAuthorized: {
                UIImage *croppedImage = [weakSelf cropImage];
                UIImageWriteToSavedPhotosAlbum(croppedImage, weakSelf, @selector(image:didFinishSavingWithError:contextInfo:), NULL);
            }
                break;
                
            default:
                break;
        }
    }];
}

#pragma mark - private methods

- (void)askToOpenSettings {
    UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:@"Access Denied"
                                                                     message:@"Go to setting page and allow access"
                                                              preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *settings = [UIAlertAction actionWithTitle:@"Settings"
                                                 style:UIAlertActionStyleDefault
                                                     handler:^(UIAlertAction * _Nonnull action) {
                                                         dispatch_async(dispatch_get_main_queue(), ^{
                                                             if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]]) {
                                                                 [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
                                                             }
                                                         });
                                                     }];
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel"
                                                 style:UIAlertActionStyleCancel
                                               handler:NULL];
    [alertVC addAction:settings];
    [alertVC addAction:cancel];
    [self presentViewController:alertVC animated:YES completion:NULL];
}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo {
    NSString *message = nil;
    NSString *title = nil;
    if (error == nil) {
        title = @"Done!";
        message = @"successfully saved";
    } else {
        message = @"Error!";
        message = error.localizedDescription;
    }
    UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:title
                                                                     message:message
                                                              preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *ok = [UIAlertAction actionWithTitle:@"OK"
                                                 style:UIAlertActionStyleDefault
                                               handler:NULL];
    [alertVC addAction:ok];
    [self presentViewController:alertVC animated:YES completion:NULL];
}

- (UIImage *)cropImage {
    self.croppingView.hidden = YES;
    //first we will make an UIImage from your view
    UIGraphicsBeginImageContext(self.view.bounds.size);
    [self.view.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *sourceImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    CGImageRef imageRef = CGImageCreateWithImageInRect(sourceImage.CGImage, self.croppingView.frame);
    UIImage *newImage   = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
    self.croppingView.hidden = NO;
    return newImage;
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
