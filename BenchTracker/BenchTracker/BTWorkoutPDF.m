//
//  BTWorkoutPDF.m
//  BenchTracker
//
//  Created by Chappy Asel on 7/5/17.
//  Copyright © 2017 CD. All rights reserved.
//

#import "BTWorkoutPDF.h"
#import "BTWorkout+CoreDataClass.h"
#import "BTExercise+CoreDataClass.h"
#import "BTUserManager.h"

@interface BTWorkoutPDF ()

@property (nonatomic) BTWorkout *workout;

@end

@implementation BTWorkoutPDF

- (void)loadWorkout:(BTWorkout *)workout {
    self.workout = workout;
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"EEEE, MMMM d yyyy";
    self.titleLabel.text = [formatter stringFromDate:workout.date];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"Cell"];
    formatter.dateFormat = @"h:mma";
    self.metadataLabel1.text = [NSString stringWithFormat:@"Start time: %@, Duration: %lld minutes, Types: %@",
                                [formatter stringFromDate:workout.date].lowercaseString, workout.duration/60,
                                [workout.summary stringByReplacingOccurrencesOfString:@"#" withString:@"; "]];
    self.metadataLabel2.text = [NSString stringWithFormat:@"User: %@, UUID: %@",
                                [(BTUserManager *)[BTUserManager sharedInstance] user].username, workout.uuid];
}

#pragma mark - tableView datasource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.workout.exercises.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    BTExercise *exercise = self.workout.exercises[indexPath.row];
    NSArray <NSString *> *tempSets = [NSKeyedUnarchiver unarchiveObjectWithData:exercise.sets];
    NSString *str = [self formattedArray:tempSets];
    if (exercise.iteration) cell.textLabel.text = [NSString stringWithFormat:@"%@ %@: %@",exercise.iteration,exercise.name, str];
    else cell.textLabel.text = [NSString stringWithFormat:@"%@: %@",exercise.name, str];
    return cell;
}

- (NSString *)formattedArray:(NSArray *)array {
    NSString *s = @"";
    for (NSString *x in array) s = [NSString stringWithFormat:@"%@, %@",s,x];
    return [NSString stringWithFormat:@"[ %@ ]",[s substringFromIndex:2]];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
