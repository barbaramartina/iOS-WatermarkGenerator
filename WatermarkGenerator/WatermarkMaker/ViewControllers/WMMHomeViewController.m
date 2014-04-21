//
//  WMMHomeViewController.m
//  WatermarkMaker
//
//  Created by Barbara Rodeker on 2/17/14.
//
//  Licensed to the Apache Software Foundation (ASF) under one
//  or more contributor license agreements.  See the NOTICE file
//  distributed with this work for additional information
//  regarding copyright ownership.  The ASF licenses this file
//  to you under the Apache License, Version 2.0 (the "License"); you may not use this file except in compliance
//  with the License.  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing,
//  software distributed under the License is distributed on an
//  "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
//  KIND, either express or implied.  See the License for the
//  specific language governing permissions and limitations
//  under the License.
//
#import "WMMHomeViewController.h"

#import <AssetsLibrary/AssetsLibrary.h>
#import <CLSideMenuViewController.h>
#import <HMSideMenu.h>
#import <GPUImage.h>
#import <UIButton+tintImage.h>
#import <MBProgressHUD.h>
#import <DLAVAlertView.h>
#import <DLAVAlertViewTheme.h>
#import <DLAVAlertViewButtonTheme.h>

#import "GPUImageOutput+GPUImageOutput_WMM.h"
#import "WMMGPUImageAlphaBlendFilter.h"
#import "WMMUser.h"


/**********************************************************************/
#pragma mark static variables
static CGFloat kPhotoMenuIconSizeX = 64.0f;
static CGFloat kPhotoMenuIconSizeY = 64.0f;

/**********************************************************************/
#pragma mark Private Interface
@interface WMMHomeViewController ()

@property (nonatomic, strong) HMSideMenu *photoMenu;

@property (nonatomic, weak) IBOutlet UIImageView *photo;
@property (nonatomic, weak) IBOutlet UIButton *openPhotoMenuButton;
@property (nonatomic, weak) IBOutlet UIView *photoMenuBackground;
@property (nonatomic, weak) IBOutlet UILabel *introText;


@property (nonatomic, strong)   GPUImageUIElement * text;
@property (nonatomic, strong)   UIImage *imagePhotoMenuOpen;
@property (nonatomic, strong)   UIImage *imagePhotoMenuClose;
@property (nonatomic, strong)   MBProgressHUD *progressHUD;
@property (nonatomic, strong)   DLAVAlertView *compressionAlertView;

@property (nonatomic, strong)   UIDynamicAnimator *animator;
@property (nonatomic, strong)   UISnapBehavior *snapToCenterBehaviour;
@property (nonatomic, strong)   UISnapBehavior *snapToDissapearBehaviour;

@end

/**********************************************************************/

@implementation WMMHomeViewController

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIContentSizeCategoryDidChangeNotification object:nil];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self displayIntroText];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [self hideIntroText];
    [super viewWillDisappear:animated];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.animator = [[UIDynamicAnimator alloc] initWithReferenceView:self.view];
    self.snapToCenterBehaviour = [[UISnapBehavior alloc] initWithItem:self.introText snapToPoint:self.view.center];
    self.snapToCenterBehaviour.damping = 0.1f;
    self.snapToDissapearBehaviour = [[UISnapBehavior alloc] initWithItem:self.introText snapToPoint:CGPointMake(-self.introText.frame.size.width, -self.introText.frame.size.height)];

    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(contentSizeDidChange:) name:UIContentSizeCategoryDidChangeNotification object:nil];

    [self createMenu];
    [self configureGestures];
    [self createProgressHUD];
    [self createCompressionAlertView];
    
    self.openPhotoMenuButton.hidden = YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    //adjust image content mode
    [self adjustPhotoContentModeForImage:self.photo.image orientation:toInterfaceOrientation];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    //adjust intro text position
    self.snapToCenterBehaviour = [[UISnapBehavior alloc] initWithItem:self.introText snapToPoint:self.view.center];
    [self displayIntroText];
}

#pragma mark IBActions

- (IBAction)openSideMenuButtonPressed:(id)sender
{
    [self.sideMenuViewController openMenuAnimated:YES completion:nil];
}

- (IBAction)selectPhotoButtonPressed:(id)sender
{
    [self.photoMenu removeFromSuperview];

    QBImagePickerController *imagePickerController = [[QBImagePickerController alloc] init];
    imagePickerController.delegate = self;
    imagePickerController.filterType = QBImagePickerControllerFilterTypePhotos;
    imagePickerController.allowsMultipleSelection = NO;
    imagePickerController.navigationItem.title = $localise(@"Select your photo");
    
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:imagePickerController];
    [self presentViewController:navigationController animated:YES completion:nil];
}

- (IBAction)openCloseMenu:(id)sender
{
    if (self.photoMenu.isOpen) {
        [self.photoMenu close];
        
        @weakify(self);
        [UIView animateWithDuration:0.3f
                         animations:^{
                             @strongify(self);
                             self.openPhotoMenuButton.center = CGPointMake(self.view.frame.size.width - self.openPhotoMenuButton .frame.size.width / 2, self.openPhotoMenuButton.center.y);
                             [self.openPhotoMenuButton setImage:self.imagePhotoMenuOpen forState:UIControlStateNormal];
                             [self.openPhotoMenuButton setImageTintColor:self.navigationController.navigationBar.tintColor];
                         }];
        
    } else {
        [self.photoMenu open];

        @weakify(self);
        [UIView animateWithDuration:0.3f
                         animations:^{
                             @strongify(self);
                             self.openPhotoMenuButton.center = CGPointMake(0, self.openPhotoMenuButton.center.y);
                             [self.openPhotoMenuButton setImage:self.imagePhotoMenuClose forState:UIControlStateNormal];
                             [self.openPhotoMenuButton setImageTintColor:self.navigationController.navigationBar.tintColor];
                         }];
    }
}

#pragma mark QBImagePickerControllerDelegate

- (void)imagePickerController:(QBImagePickerController *)imagePickerController didSelectAsset:(ALAsset *)asset
{
    [self.animator removeBehavior:self.snapToCenterBehaviour];
    [self.animator addBehavior:self.snapToDissapearBehaviour];
    
    self.photo.image = [self imageFromAsset:asset];
    [self adjustPhotoContentModeForImage:self.photo.image orientation:self.interfaceOrientation];
    [self addMenuToPhoto];
    [self hideIntroText];
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerController:(QBImagePickerController *)imagePickerController didSelectAssets:(NSArray *)assets
{
    //TODO multiple assets selection not yet implemented
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerControllerDidCancel:(QBImagePickerController *)imagePickerController
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark Private

- (void)adjustPhotoContentModeForImage:(UIImage *)image orientation:(UIInterfaceOrientation)orientation
{
    if (UIInterfaceOrientationIsLandscape(orientation)) {
        if (image.size.height > image.size.width) {
            self.photo.contentMode = UIViewContentModeScaleAspectFit;
        } else {
            self.photo.contentMode = UIViewContentModeScaleAspectFill;
        }
    } else {
        if (image.size.height > image.size.width) {
            self.photo.contentMode = UIViewContentModeScaleAspectFill;
        } else {
            self.photo.contentMode = UIViewContentModeScaleAspectFit;
        }
    }
}

- (void)displayIntroText
{
    if (self.photo.image == nil) {
        [self.animator removeAllBehaviors];
        [self.animator addBehavior:self.snapToCenterBehaviour];
    }
}

- (void)hideIntroText
{
    if (self.photo.image == nil) {
        [self.animator removeAllBehaviors];
        [self.animator addBehavior:self.snapToDissapearBehaviour];
    }
}

- (void)contentSizeDidChange:(NSNotification *)notification
{
    self.introText.font = [UIFont preferredFontForTextStyle:UIFontTextStyleHeadline];
}

- (UIImage *)imageFromAsset:(ALAsset *)asset
{
    ALAssetRepresentation* representation = [asset defaultRepresentation];
    
    UIImageOrientation orientation = UIImageOrientationUp;
    NSNumber* orientationValue = [asset valueForProperty:@"ALAssetPropertyOrientation"];
    if (orientationValue != nil) {
        orientation = [orientationValue intValue];
    }
    
    CGFloat scale  = 1;
    UIImage* image = [UIImage imageWithCGImage:[representation fullResolutionImage]
                                         scale:scale orientation:orientation];
    return image;
}

- (void)addMenuToPhoto
{
    self.openPhotoMenuButton.hidden = NO;
    [self.openPhotoMenuButton setImageTintColor:self.navigationController.navigationBar.tintColor];
    [self.photoMenuBackground addSubview:self.photoMenu];
}

- (void)generateWatermarkedImage
{
    if ([WMMUser sharedInstance].watermarkText && [[WMMUser sharedInstance].watermarkText length] > 0) {
        self.progressHUD.mode = MBProgressHUDModeIndeterminate;
        self.progressHUD.labelText = $localise(@"Stamping your photo...");
        [self.progressHUD show:YES];
        
        GPUImagePicture *bgimage = [[GPUImagePicture alloc] initWithImage:self.photo.image];
        UILabel *waterLabel = [[UILabel alloc] initWithFrame:self.photo.frame];
        waterLabel.text = [WMMUser sharedInstance].watermarkText;
        waterLabel.textAlignment = NSTextAlignmentCenter;
        waterLabel.textColor = [[WMMUser sharedInstance] preferedColor];
        waterLabel.font = [UIFont fontWithName:[[WMMUser sharedInstance] preferedFontFamily]
                                          size:[[WMMUser sharedInstance] preferedFontSize]];
        self.text = [[GPUImageUIElement alloc] initWithView:waterLabel];
        
        WMMGPUImageAlphaBlendFilter *blendFilter = [[WMMGPUImageAlphaBlendFilter alloc] init];
        [blendFilter presetSecondTargetOrientation:[self.photo.image imageOrientation]];
        
        [bgimage addTarget:blendFilter];
        [bgimage processImage];
        
        [self.text addTarget:blendFilter];
        [self.text update];
        
        UIImage *watermarkedImage = [blendFilter customImageFromCurrentlyProcessedOutputWithOrientation:[self.photo.image imageOrientation]];
        
        self.photo.image = watermarkedImage;
        
        [self.progressHUD hide:YES];
    } else {
        [self showProgressHUDWithTitle:@"" detail:$localise(@"Please go to Menu->Settings and choose a text for watermarking this picture")];
    }
}

- (void)saveImageToCameraRoll
{
    self.progressHUD.mode = MBProgressHUDModeIndeterminate;
    self.progressHUD.labelText = $localise(@"Saving photo...");
    @weakify(self);
    [self.progressHUD showAnimated:YES whileExecutingBlock:^{
        @strongify(self);
        UIImageWriteToSavedPhotosAlbum(self.photo.image, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
    }];
    
}

- (void)image:(UIImage *)image
didFinishSavingWithError:(NSError *)error
  contextInfo:(void *)contextInfo
{
    if (error) {
        [self showProgressHUDWithTitle:$localise(@"Oops!") detail:$localise(@"There was an error trying to save you photo. Please try again.")];
    } else {
        [self showProgressHUDWithTitle:$localise(@"Congrats!") detail:$localise(@"Your photo was saved sucessfully")];
    }
}

- (void)createMenu
{
    self.imagePhotoMenuOpen = [UIImage imageNamed:@"btn-arrow-down"];
    self.imagePhotoMenuClose = [UIImage imageNamed:@"btn-arrow-up"];
    
    // STAMP item
    @weakify(self);
    HMSideMenuItem *stampItem = [[HMSideMenuItem alloc] initWithSize:CGSizeMake(kPhotoMenuIconSizeX, kPhotoMenuIconSizeY) action:^{
        @strongify(self);
        [self generateWatermarkedImage];
    }];
    UIImageView *stampIcon = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, kPhotoMenuIconSizeX , kPhotoMenuIconSizeY)];
    UIImage *stampImage = [[UIImage imageNamed:@"btn-stamp"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [stampIcon setImage:stampImage];
    stampIcon.tintColor = self.navigationController.navigationBar.tintColor;
    [stampItem addSubview:stampIcon];

    // SAVE item
    HMSideMenuItem *saveItem = [[HMSideMenuItem alloc] initWithSize:CGSizeMake(kPhotoMenuIconSizeX, kPhotoMenuIconSizeY) action:^{
        @strongify(self);
        [self saveImageToCameraRoll];
    }];
    UIImageView *saveIcon = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, kPhotoMenuIconSizeX , kPhotoMenuIconSizeY)];
    UIImage *saveImage = [[UIImage imageNamed:@"btn-backup"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [saveIcon setImage:saveImage];
    saveIcon.tintColor = self.navigationController.navigationBar.tintColor;
    [saveItem addSubview:saveIcon];

    // SHARE item
    HMSideMenuItem *shareItem = [[HMSideMenuItem alloc] initWithSize:CGSizeMake(kPhotoMenuIconSizeX, kPhotoMenuIconSizeY) action:^{
        @strongify(self);
        [self.compressionAlertView showWithCompletion:^(DLAVAlertView *alertView, NSInteger buttonIndex){
            switch (buttonIndex) {
                case 0:
                    [self sharePhotoWithCompressionRate:1];
                    break;
                case 1:
                    [self sharePhotoWithCompressionRate:0.5];
                    break;
                case 2:
                    [self sharePhotoWithCompressionRate:0.25];
                    break;
                default:
                    break;
            }
        }];
    }];
    UIImageView *shareIcon = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, kPhotoMenuIconSizeX , kPhotoMenuIconSizeY)];
    UIImage *shareImage = [[UIImage imageNamed:@"btn-upload"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [shareIcon setImage:shareImage];
    shareIcon.tintColor = self.navigationController.navigationBar.tintColor;
    [shareItem addSubview:shareIcon];

    self.photoMenu = [[HMSideMenu alloc] initWithItems:@[stampItem, shareItem, saveItem]];
    self.photoMenu.animationDuration = 1.0f;
    self.photoMenu.menuPosition = HMSideMenuPositionTop;
    [self.photoMenu setItemSpacing:5.0f];
    
}

- (void)createProgressHUD
{
    self.progressHUD = [[MBProgressHUD alloc] init];
    self.progressHUD.animationType = MBProgressHUDAnimationZoomIn;
    NSString *fontName = self.navigationController.navigationBar.titleTextAttributes[@"NSFontAttributeName"];
    self.progressHUD.labelFont = [UIFont fontWithName:fontName size:12];
    self.progressHUD.detailsLabelFont = [UIFont fontWithName:fontName size:10];
    self.progressHUD.removeFromSuperViewOnHide = NO;
    
    [self.view addSubview:self.progressHUD];
}

-(void)createCompressionAlertView
{
    self.compressionAlertView = [[DLAVAlertView alloc] initWithTitle:$localise(@"Select size")
                                                           message:$localise(@"Would you like to compress the image?")
                                                            delegate:nil
                                                   cancelButtonTitle:nil
                                                   otherButtonTitles:$localise(@"Keep 100%"),$localise(@"Reduce to 50%"),$localise(@"Reduce to 25%"),nil];
    
    // Alert view themes
    DLAVAlertViewTheme *customTheme = [[DLAVAlertViewTheme alloc] init];
    customTheme.backgroundColor = [UIColor whiteColor];
    customTheme.cornerRadius = 10.0f;
    customTheme.borderColor = self.navigationController.navigationBar.tintColor;
    customTheme.borderWidth = 0.5f;
    customTheme.titleColor = self.navigationController.navigationBar.tintColor;
    customTheme.messageColor = customTheme.titleColor;
    customTheme.messageFont = customTheme.titleFont;
    NSString *fontName = self.navigationController.navigationBar.titleTextAttributes[@"NSFontAttributeName"];
    customTheme.titleFont = [UIFont fontWithName:fontName size:16.0f];
    
    [self.compressionAlertView applyTheme:customTheme];
    
    // Buttons themes
    DLAVAlertViewButtonTheme *buttonTheme = [[DLAVAlertViewButtonTheme alloc] init];
    buttonTheme.textColor = self.navigationController.navigationBar.tintColor;
    buttonTheme.font = [UIFont fontWithName:fontName size:12.0f];
    buttonTheme.highlightBackgroundColor = [UIColor whiteColor];
    
    [self.compressionAlertView setCustomButtonTheme:buttonTheme forButtonAtIndex:0];
    [self.compressionAlertView setCustomButtonTheme:buttonTheme forButtonAtIndex:1];
    [self.compressionAlertView setCustomButtonTheme:buttonTheme forButtonAtIndex:2];
}

- (void)configureGestures
{
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapPhoto)];
    self.photo.userInteractionEnabled = YES;
    [self.photo addGestureRecognizer:tapGesture];
}

- (void)didTapPhoto
{
    if (self.photo.image == nil) {
        return;
    }
    
    if (self.navigationController.navigationBarHidden) {
        [self.navigationController setNavigationBarHidden:NO animated:YES];
        @weakify(self);
        [UIView animateWithDuration:0.3f animations:^{
            @strongify(self);
            self.photoMenuBackground.alpha = 0.5f;
            self.openPhotoMenuButton.alpha = 1.0f;
            
        }];
    } else {
        @weakify(self);
        [self.navigationController setNavigationBarHidden:YES animated:YES];
        [UIView animateWithDuration:0.3f animations:^{
            @strongify(self);
            self.photoMenuBackground.alpha = 0.0f;
            self.openPhotoMenuButton.alpha = 0.0f;
            
        }];
    }
}

- (void)sharePhotoWithCompressionRate:(CGFloat)compression
{
    if ([MFMailComposeViewController canSendMail]) {
        self.progressHUD.mode = MBProgressHUDModeIndeterminate;
        self.progressHUD.labelText = $localise(@"Generating image to attach...");
        [self.progressHUD show:YES];
        
        MFMailComposeViewController *mailComposer = [[MFMailComposeViewController alloc] init];
        mailComposer.mailComposeDelegate = self;
        
        [mailComposer setSubject:$localise(@"Here is a photo for you")];
        [mailComposer setMessageBody:$localise(@"WMMShareBodyText") isHTML:YES];
        
        NSData *attachmentData = UIImageJPEGRepresentation(self.photo.image,compression);
        [mailComposer addAttachmentData:attachmentData mimeType:@"mime/jpg" fileName:@"watermarkedphoto.jpg"];
        
        @weakify(self);
        [self presentViewController:mailComposer animated:YES completion:^{
            @strongify(self);
            [self.progressHUD hide:YES];
        }];
    } else {
        [self showProgressHUDWithTitle:$localise(@"Error") detail:$localise(@"It seems your device is not able to send emails right now, please review your settings and internet connection")];
    }
}

- (void)showProgressHUDWithTitle:(NSString *)title detail:(NSString *)detail
{
    self.progressHUD.mode = MBProgressHUDModeText;
    self.progressHUD.labelText = title;
    self.progressHUD.detailsLabelText = detail;
    [self.progressHUD show:YES];
    [self.progressHUD hide:YES afterDelay:3];
    
}

#pragma mark MFMailComposeViewControllerDelegate

- (void)mailComposeController:(MFMailComposeViewController *)controller
          didFinishWithResult:(MFMailComposeResult)result
                        error:(NSError *)error {
    [self dismissViewControllerAnimated:YES completion:nil];
    
    if (error) {
        [self showProgressHUDWithTitle:$localise(@"Oops!") detail:$localise(@"There has been an error trying to send your email, please try again or contact us for support.")];
    }
}


@end
