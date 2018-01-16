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

@property (strong, nonatomic) IBOutletCollection(UIImageView) NSArray <UIImageView *> *images;
@property (strong, nonatomic) IBOutletCollection(UILabel) NSArray <UILabel *> *labels;

@end

@implementation WorkoutDetailsView

- (void)awakeFromNib {
    [super awakeFromNib];
    for (UIImageView *v in self.images) {
        v.image = [v.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        v.tintColor = [UIColor BTLightGrayColor];
    }
    for (UILabel *l in self.labels)
        l.textColor = [UIColor BTLightGrayColor];
}

- (void)loadWithWorkout:(BTWorkout *)workout {
    self.labels[0].text = [NSString stringWithFormat:@"%lld sets",workout.numSets];
    self.labels[1].text = [NSString stringWithFormat:@"%lldk %@",workout.volume/1000,[BTSettings sharedInstance].weightSuffix];
    self.labels[2].text = [NSString stringWithFormat:@"%lld min",workout.duration/60];
}

@end
