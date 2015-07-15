//
//  StepDetailViewController.m
//  BenchTracker
//
//  Created by Chappy Asel on 6/7/14.
//  Copyright (c) 2014 CD. All rights reserved.
//

#import "StepDetailViewController.h"
#import "StepViewController.h"

@interface StepDetailViewController ()

@end

@implementation StepDetailViewController

NSString *name;

- (void)viewDidLoad {
    [super viewDidLoad];
    UINavigationBar *navBar = [[UINavigationBar alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 64)];
    navBar.backgroundColor = [UIColor whiteColor];
    UINavigationItem *navItem = [[UINavigationItem alloc] init];
    navItem.title = choices[path.section][path.row];
    UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStylePlain target:self action:@selector(doneButtonPressed:)];
    navItem.rightBarButtonItem = rightButton;
    navBar.items = @[ navItem ];
    [self.view addSubview:navBar];
    NSString *file = [NSString stringWithFormat:@ "StepImages/%@.png",choices[path.section][path.row]];
    NSLog(@"%@",file);
    _ImageDisplay.image = [UIImage imageNamed:file];
}

- (void)doneButtonPressed: (id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
