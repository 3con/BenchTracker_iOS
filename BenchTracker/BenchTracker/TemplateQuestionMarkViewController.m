//
//  TemplateQuestionMarkViewController.m
//  BenchTracker
//
//  Created by Chappy Asel on 9/3/18.
//  Copyright © 2018 CD. All rights reserved.
//

#import "TemplateQuestionMarkViewController.h"

@interface TemplateQuestionMarkViewController()

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIButton *gotItButton;

@end

@implementation TemplateQuestionMarkViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = UIColor.BTTableViewBackgroundColor;
    self.titleLabel.textColor = UIColor.BTLightGrayColor;
    self.descriptionLabel.textColor = UIColor.BTLightGrayColor;
    self.gotItButton.backgroundColor = UIColor.BTButtonSecondaryColor;
    self.gotItButton.layer.cornerRadius = 12;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.frame = self.imageView.bounds;
    gradient.colors = @[(id)[UIColor whiteColor].CGColor,
                        (id)[UIColor clearColor].CGColor];
    gradient.startPoint = CGPointMake(1.0, 1 - (150 / self.imageView.bounds.size.height));
    gradient.endPoint = CGPointMake(1.0, 1 - (100 / self.imageView.bounds.size.height));
    self.imageView.layer.mask = gradient;
}

- (IBAction)doneButtonPressed:(UIButton *)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIColor.altStatusBarStyle;
}

@end
