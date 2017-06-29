//
//  ExerciseViewController.m
//  BenchTracker
//
//  Created by Chappy Asel on 6/28/17.
//  Copyright © 2017 CD. All rights reserved.
//

#import "ExerciseViewController.h"
#import "ExerciseView.h"
#import "BTExercise+CoreDataClass.h"

@interface ExerciseViewController ()

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIView *contentView;

@property (weak, nonatomic) IBOutlet UIButton *doneButton;

@property (nonatomic) NSMutableArray<ExerciseView *> *exerciseViews;

@end

@implementation ExerciseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.doneButton.layer.cornerRadius = 12;
    self.doneButton.clipsToBounds = YES;
    self.exerciseViews = [[NSMutableArray alloc] init];
    for (BTExercise *exercise in self.exercises) {
        ExerciseView *view = [[NSBundle mainBundle] loadNibNamed:@"ExerciseView" owner:self options:nil].firstObject;
        [view loadExercise:exercise];
        [self.exerciseViews addObject:view];
        [self.contentView addSubview:view];
    }
    if (self.exerciseViews.count == 1) self.exerciseViews[0].center =
                                       CGPointMake(self.contentView.frame.size.width*.5, self.contentView.frame.size.height*.5);
    else {
        self.exerciseViews[0].center = CGPointMake(self.contentView.frame.size.width*.5, self.contentView.frame.size.height*.25);
        self.exerciseViews[1].center = CGPointMake(self.contentView.frame.size.width*.5, self.contentView.frame.size.height*.75);
    }
    
}

- (IBAction)doneButtonPressed:(UIButton *)sender {
    [self dismissViewControllerAnimated:YES completion:^{
                                 
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
