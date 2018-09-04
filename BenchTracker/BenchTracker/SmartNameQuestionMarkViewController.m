//
//  SmartNameQuestionMarkViewController.m
//  BenchTracker
//
//  Created by Chappy Asel on 9/3/18.
//  Copyright © 2018 CD. All rights reserved.
//

#import "SmartNameQuestionMarkViewController.h"

@interface SmartNameQuestionMarkViewController()

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIButton *gotItButton;

@end

@implementation SmartNameQuestionMarkViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = UIColor.BTTableViewBackgroundColor;
    self.titleLabel.textColor = UIColor.BTLightGrayColor;
    self.descriptionLabel.textColor = UIColor.BTLightGrayColor;
    self.gotItButton.backgroundColor = UIColor.BTButtonSecondaryColor;
    self.gotItButton.layer.cornerRadius = 12;
}

- (IBAction)doneButtonPressed:(UIButton *)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIColor.altStatusBarStyle;
}

@end
