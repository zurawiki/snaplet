//
//  CameraViewController.m
//  Ribbit
//
//  Copyright (c) 2013 Treehouse. All rights reserved.
//

#import "CameraViewController.h"
#import <MobileCoreServices/UTCoreTypes.h>
#import <MediaPlayer/MediaPlayer.h>

@interface CameraViewController ()<UIActionSheetDelegate, ACEDrawingViewDelegate>

@end

@implementation CameraViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    // set the delegate
    self.drawingView.delegate = self;
    
    // Build a random color to show off setting the color on the pickers
    
    UIColor *c = [UIColor redColor];

    self.drawingView.lineColor = c;
    self.drawingView.lineWidth = 4.0f;

    self.recipients = [[NSMutableArray alloc] init];
    
    [self.topToolbar setBackgroundImage:[UIImage new]
                  forToolbarPosition:UIBarPositionAny
                          barMetrics:UIBarMetricsDefault];
    [self.topToolbar setShadowImage:[UIImage new]
              forToolbarPosition:UIToolbarPositionAny];
    
    [self.bottomToolbar setBackgroundImage:[UIImage new]
                  forToolbarPosition:UIBarPositionAny
                          barMetrics:UIBarMetricsDefault];
    [self.bottomToolbar setShadowImage:[UIImage new]
              forToolbarPosition:UIToolbarPositionAny];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.bottomToolbar setClipsToBounds:YES];
    
    if (self.image == nil && [self.videoFilePath length] == 0) {
        self.imagePicker = [[UIImagePickerController alloc] init];
        self.imagePicker.delegate = self;
        self.imagePicker.allowsEditing = NO;
        self.imagePicker.videoMaximumDuration = 10;
        
        if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
            self.imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
        }
        else {
            self.imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        }
        
        self.imagePicker.mediaTypes = [UIImagePickerController availableMediaTypesForSourceType:self.imagePicker.sourceType];
        
        [self presentViewController:self.imagePicker animated:NO completion:nil];
    }    
}

#pragma mark - Image Picker Controller delegate

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [self dismissViewControllerAnimated:NO completion:nil];
    [self.tabBarController setSelectedIndex:0];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    NSString *mediaType = [info objectForKey:UIImagePickerControllerMediaType];
    
    if ([mediaType isEqualToString:(NSString *)kUTTypeImage]) {
        // A photo was taken/selected!
        self.image = [info objectForKey:UIImagePickerControllerOriginalImage];
//        if (self.imagePicker.sourceType == UIImagePickerControllerSourceTypeCamera) {
//            // Save the image!
//            UIImageWriteToSavedPhotosAlbum(self.image, nil, nil, nil);
//        }
        self.imageView.image = self.image;
    }
    else {
        // A video was taken/selected!
        self.videoFilePath = (__bridge NSString *)([[info objectForKey:UIImagePickerControllerMediaURL] path]);
        if (self.imagePicker.sourceType == UIImagePickerControllerSourceTypeCamera) {
            // Save the video!
//            if (UIVideoAtPathIsCompatibleWithSavedPhotosAlbum(self.videoFilePath)) {
//                UISaveVideoAtPathToSavedPhotosAlbum(self.videoFilePath, nil, nil, nil);
//            }
        }
        
        MPMoviePlayerController *theMovie = [[MPMoviePlayerController alloc] initWithContentURL:[info objectForKey:UIImagePickerControllerMediaURL]];
        theMovie.view.frame = self.view.bounds;
        theMovie.controlStyle = MPMovieControlStyleNone;
        theMovie.shouldAutoplay = NO;
        UIImage *imgTemp = [theMovie thumbnailImageAtTime:0 timeOption:MPMovieTimeOptionExact];

        self.imageView.image = imgTemp;
    }
    [self.drawingView clear];
    [self updateButtonStatus];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)updateButtonStatus
{
    // Get the reference to the current toolbar buttons
    NSMutableArray *toolbarButtons = [[self.topToolbar items] mutableCopy];

    if ([self.drawingView canUndo]) {
        // This is how you add the button to the toolbar and animate it
        if (![toolbarButtons containsObject:self.undoButton]) {
            // The following line adds the object to the end of the array.
            // If you want to add the button somewhere else, use the `insertObject:atIndex:`
            // method instead of the `addObject` method.
            [toolbarButtons insertObject:self.undoButton atIndex:2 ];
            [self.topToolbar setItems:toolbarButtons animated:YES];
        }
    }
    else {
        // This is how you remove the button from the toolbar and animate it
        [toolbarButtons removeObject:self.undoButton];
        [self.topToolbar setItems:toolbarButtons animated:YES];
    }

}

- (IBAction)undo:(id)sender
{
    [self.drawingView undoLatestStep];
    [self updateButtonStatus];
}

#pragma mark - ACEDrawing View Delegate

- (void)drawingView:(ACEDrawingView *)view didEndDrawUsingTool:(id<ACEDrawingTool>)tool;
{
    [self updateButtonStatus];
}

#pragma mark - IBActions

- (IBAction)cancel:(id)sender {
    [self reset];
    [self.tabBarController setSelectedIndex:0];
}


- (IBAction)send:(id)sender {
    [self uploadMessage];
    [self.tabBarController setSelectedIndex:0];

}

#pragma mark - Helper methods

- (void)uploadMessage {
    NSData *fileData;
    NSString *fileName;
    NSString *fileType;
    
    // get image from drawing
    // TODO overlay
   
    
    if (self.image != nil) {
        UIImage *newImage = [self blendImage];
        fileData = UIImagePNGRepresentation(newImage);
        fileName = @"image.png";
        fileType = @"image";
    }
    else {
        fileData = [NSData dataWithContentsOfFile:self.videoFilePath];
        fileName = @"video.mov";
        fileType = @"video";
    }
    
    // get pairings
    
    // if null or new user
    // get rando user
    
    //set pairing and recipient
//    PFObject *recipient = nil;
//    if (!([[PFUser currentUser] objectForKey:@"pairing"]) ) {
//        // get random person
//        // Get the max index of any user (+1).
//        PFQuery* users = [PFUser query];
//        int maxIndex = (int)[users countObjects];
//        
//        // Randomly pick an index in the range of all indices.
//        int randomIndex = arc4random() % maxIndex;
//        
//        // Get the users with that particular index.
//        PFObject *pairing = [users findObjects][randomIndex] ;
//        
//        // update pairing
//        [[PFUser currentUser] setObject:pairing forKey:@"pairing"] ;
//        recipient = pairing;
//        NSLog(@"Sending to %@", recipient);
//    }
//    else {
//        // use current person
//        PFObject *pairing = [[PFUser currentUser] objectForKey:@"pairing"];
//        recipient = pairing;
//    }
    
    PFFile *file = [PFFile fileWithName:fileName data:fileData];
    [file saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (error) {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"An error occurred!" message:@"Please try sending your message again." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alertView show];
        }
        else {
            PFObject *message = [PFObject objectWithClassName:@"Messages"];
            [message setObject:file forKey:@"file"];
            [message setObject:fileType forKey:@"fileType"];
            
            
            [message setObject:@[[[PFUser currentUser] objectId]] forKey:@"recipientIds"];
            
            
            [message setObject:[[PFUser currentUser] objectId] forKey:@"senderId"];
            [message setObject:[[PFUser currentUser] username] forKey:@"senderName"];
            [message saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                if (error) {
                    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"An error occurred!"
                                                                        message:@"Please try sending your message again."
                                                                       delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                    [alertView show];
                }
                else {
                    // Everything was successful!
                    [self reset];
                }
            }];
        }
    }];
}

- (void)reset {
    self.image = nil;
    self.videoFilePath = nil;
    [self.recipients removeAllObjects];
}

- (UIImage *)resizeImage:(UIImage *)image toWidth:(float)width andHeight:(float)height {
    CGSize newSize = CGSizeMake(width, height);
    CGRect newRectangle = CGRectMake(0, 0, width, height);
    UIGraphicsBeginImageContext(newSize);
    [image drawInRect:newRectangle];
    UIImage *resizedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return resizedImage;
}

- (UIImage *)blendImage {
//    UIImage *bottomImage = [self resizeImage:self.image toWidth:320.f andHeight:480.f];
//    UIImage *image = [self resizeImage:[self.drawingView image] toWidth:320.f andHeight:480.f];
    UIGraphicsBeginImageContextWithOptions(self.imageView.bounds.size, NO, 0.0);
    [self.imageView.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *bottomImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    UIImage *image = [self.drawingView image];
    
    CGSize newSize = CGSizeMake(320, 480);
    UIGraphicsBeginImageContext( newSize );
    
    // Use existing opacity as is
    [bottomImage drawInRect:CGRectMake(0,0,newSize.width,newSize.height)];

    // Apply supplied opacity if applicable
    [image drawInRect:CGRectMake(0,0,newSize.width,newSize.height) blendMode:kCGBlendModeNormal alpha:0.8];
    
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    
    return newImage;
}

@end
