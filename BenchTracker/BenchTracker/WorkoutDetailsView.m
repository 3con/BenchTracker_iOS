//
//  WorkoutDetailsView.m
//  BenchTracker
//
//  Created by Chappy Asel on 9/3/17.
//  Copyright © 2017 CD. All rights reserved.
//

#import "WorkoutDetailsView.h"
#import "BTWorkout+CoreDataClass.h"
#import "BTSettings+CoreDataClass.h"

@interface WorkoutDetailsView ()
@property (weak, nonatomic) IBOutlet UILabel *label1;
@property (weak, nonatomic) IBOutlet UILabel *label2;
@property (weak, nonatomic) IBOutlet UILabel *label3;
@end

@implementation WorkoutDetailsView

- (void)loadWithWorkout:(BTWorkout *)workout {
    self.label1.text = [NSString stringWithFormat:@"%lld sets",workout.numSets];
    self.label2.text = [NSString stringWithFormat:@"%lldk %@",workout.volume/1000,[BTSettings sharedInstance].weightSuffix];
    self.label3.text = [NSString stringWithFormat:@"%lld min",workout.duration/60];
}

@end
