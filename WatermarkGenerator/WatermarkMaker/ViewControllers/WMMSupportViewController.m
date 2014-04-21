//
//  WMMSupportViewController.m
//  WatermarkMaker
//
//  Created by Barbara Rodeker on 3/5/14.
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

#import "WMMSupportViewController.h"

#import <MBProgressHUD.h>

/**********************************************************************/
@interface WMMSupportViewController ()

@property (nonatomic, weak) IBOutlet UILabel *contactTitle;
@property (nonatomic, weak) IBOutlet UIButton *contactButton;
@property (nonatomic, weak) IBOutlet UILabel *suggestionTitle;
@property (nonatomic, weak) IBOutlet UIButton *suggestionButton;

@end
/**********************************************************************/

@implementation WMMSupportViewController


-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(preferredContentSizeChanged:)
                                                 name:UIContentSizeCategoryDidChangeNotification
                                               object:nil];
}

#pragma mark IBActions

- (IBAction)helpButtonPressed:(id)sender
{
    [self sendEmailWithTitle:$localise(@"WMMSupportTitle") body:$localise(@"WMMSupportBody")];
}

- (IBAction)suggestionButtonPressed:(id)sender
{
    [self sendEmailWithTitle:$localise(@"WMMSuggestionTitle") body:$localise(@"WMMSuggestionBody")];
}

#pragma mark Private

-(void)preferredContentSizeChanged:(NSNotification* )notification
{
    self.contactTitle.font = [UIFont preferredFontForTextStyle:UIFontTextStyleCaption1];
    self.contactButton.titleLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleCaption2];
    self.suggestionTitle.font = [UIFont preferredFontForTextStyle:UIFontTextStyleCaption1];
    self.suggestionButton.titleLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleCaption2];
}

- (void)sendEmailWithTitle:(NSString *)title body:(NSString *)body
{
    if ([MFMailComposeViewController canSendMail]) {
        MFMailComposeViewController *mailComposer = [[MFMailComposeViewController alloc] init];
        mailComposer.mailComposeDelegate = self;
        
        [mailComposer setSubject:title];
        [mailComposer setMessageBody:body isHTML:YES];
        [mailComposer setToRecipients:@[kSupportEmail]];
        
        [self presentViewController:mailComposer animated:YES completion:nil];
    }
}

#pragma mark MFMailComposeViewControllerDelegate

- (void)mailComposeController:(MFMailComposeViewController *)controller
          didFinishWithResult:(MFMailComposeResult)result
                        error:(NSError *)error {
    [self dismissViewControllerAnimated:YES completion:nil];
    
    if (error) {
        MBProgressHUD *errorHUD = [[MBProgressHUD alloc] init];
        errorHUD.mode = MBProgressHUDModeText;
        errorHUD.labelText = $localise(@"Oops!");
        errorHUD.detailsLabelText = $localise(@"There has been an error trying to send your email, please try again or contact us for support.");
        [errorHUD show:YES];
        [errorHUD hide:YES afterDelay:3];
    }
}


@end
