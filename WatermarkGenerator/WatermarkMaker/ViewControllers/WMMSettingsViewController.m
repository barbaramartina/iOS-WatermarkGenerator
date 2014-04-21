//
//  WMMSettingsViewController.m
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
#import "WMMSettingsViewController.h"
#import "WMMUser.h"
#import "HRColorUtil.h"

/**********************************************************************/
#pragma mark Private category
@interface WMMSettingsViewController ()

@property (nonatomic, strong) NSArray *allSystemFonts;
@property (nonatomic, assign) BOOL isShowingLandscapeView;

@property (nonatomic, weak) IBOutlet UITextField *watermarkText;
@property (nonatomic, weak) IBOutlet UIPickerView *fontFamilyPicker;
@property (nonatomic, weak) IBOutlet UISlider *fontSizeSlider;
@property (nonatomic, weak) IBOutlet UILabel *previewLabel;
@property (nonatomic, weak) IBOutlet UILabel *previewLabelTitle;
@property (nonatomic, weak) IBOutlet UILabel *headingTitle;
@property (nonatomic, weak) IBOutlet UILabel *fontTitle;
@property (nonatomic, weak) IBOutlet UILabel *colorTitle;
@property (nonatomic, weak) IBOutlet UILabel *sizeTitle;
@property (nonatomic, weak) IBOutlet UILabel *textTitle;


@end
/**********************************************************************/
#pragma mark Private category


@implementation WMMSettingsViewController

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self updateUIElements];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(preferredContentSizeChanged:)
                                                 name:UIContentSizeCategoryDidChangeNotification
                                               object:nil];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

    [self updateUIElements];
    
    @weakify(self);
    dispatch_async(dispatch_get_main_queue(), ^{
        @strongify(self);
        [self loadSystemFonts];
        [self.fontFamilyPicker reloadAllComponents];
    });
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    if (self.isMovingFromParentViewController) {
        [self saveWatermark];
    }
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [self saveWatermark];

    [super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];

    [self updateUIElements];
}

#pragma mark IBActions


- (IBAction)colorPickerPressed:(id)sender
{
    HRColorPickerViewController *pickerController = [[HRColorPickerViewController alloc] initWithColor:[[WMMUser sharedInstance] preferedColor] fullColor:YES saveStyle:HCPCSaveStyleSaveAndCancel];
    pickerController.delegate = self;
    pickerController.edgesForExtendedLayout = UIRectEdgeNone;
    pickerController.view.backgroundColor = [UIColor whiteColor];
    
    [self.navigationController pushViewController:pickerController animated:YES];
}

- (IBAction)fontPickerPressed:(id)sender
{
    self.fontFamilyPicker.hidden = NO;
}

#pragma mark - Hayashi311ColorPickerDelegate

- (void)setSelectedColor:(UIColor*)color
{
    [[WMMUser sharedInstance] setPreferedColor:color];
    [self updatePreviewLabel];
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark UIPickerViewDataSource

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return [self.allSystemFonts count];
}

#pragma mark UIPickerViewDelegate

- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view{
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, pickerView.frame.size.width, 40)];
    label.backgroundColor = pickerView.backgroundColor;
    label.textColor = [UIColor blackColor];

    NSString *fontName = self.allSystemFonts[row];

    label.font = [UIFont fontWithName:fontName size:14.0f];
    label.text = fontName;
    label.textAlignment = NSTextAlignmentCenter;
    
    return label;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    NSString *selectedFont = self.allSystemFonts[row];
    [[WMMUser sharedInstance] setPreferedFontFamily:selectedFont];
    [self updatePreviewLabel];
}

#pragma mark Private

-(void)preferredContentSizeChanged:(NSNotification* )notification
{
    self.headingTitle.font = [UIFont preferredFontForTextStyle:UIFontTextStyleHeadline];
    self.previewLabelTitle.font = [UIFont preferredFontForTextStyle:UIFontTextStyleHeadline];
    self.fontTitle.font = [UIFont preferredFontForTextStyle:UIFontTextStyleCaption1];
    self.textTitle.font = [UIFont preferredFontForTextStyle:UIFontTextStyleCaption1];
    self.sizeTitle.font = [UIFont preferredFontForTextStyle:UIFontTextStyleCaption1];
    self.colorTitle.font = [UIFont preferredFontForTextStyle:UIFontTextStyleCaption1];
}

- (void)loadSystemFonts
{
    NSArray *fontFamilies = [[UIFont familyNames] sortedArrayUsingSelector:@selector(compare:)];
    NSMutableArray *allFonts = [NSMutableArray array];
    
    for (NSString *familyName in fontFamilies)
    {
        NSArray *names = [UIFont fontNamesForFamilyName:familyName];
        [allFonts addObjectsFromArray:names];
    }
    
    self.allSystemFonts = [allFonts sortedArrayUsingSelector:@selector(compare:)];
}

- (void)saveWatermark
{
    [[WMMUser sharedInstance] setWatermarkText:self.watermarkText.text];
}

- (void)updatePreviewLabel
{
    self.previewLabel.text = [[WMMUser sharedInstance] watermarkText];
    
    NSString *preferedFont = [[WMMUser sharedInstance] preferedFontFamily];
    CGFloat preferedSize = [[WMMUser sharedInstance] preferedFontSize];
    
    self.previewLabel.font = [UIFont fontWithName:preferedFont size:preferedSize];
    
    self.previewLabel.textColor = [[WMMUser sharedInstance] preferedColor];
}

- (void)updateUIElements
{
    self.watermarkText.text = [[WMMUser sharedInstance] watermarkText];
    [self updatePreviewLabel];
    [self.fontSizeSlider setValue:[[WMMUser sharedInstance] preferedFontSize]];
    
    [self.fontSizeSlider addTarget:self action:@selector(sliderValueChanged:) forControlEvents:UIControlEventValueChanged];
    
    [self.view addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(viewTapped:)]];
}

- (IBAction)viewTapped:(id)recognizer
{
    self.fontFamilyPicker.hidden = YES;
    [self.watermarkText resignFirstResponder];
    [self saveWatermark];
    [self updatePreviewLabel];
}

- (void)sliderValueChanged:(id)sender
{
    CGFloat preferedSize = self.fontSizeSlider.value;
    [[WMMUser sharedInstance] setPreferedFontSize:preferedSize];
    [self updatePreviewLabel];
}

#pragma mark UITextFieldDelegate



@end
