//
//  ExerciseSummaryView.m
//  BenchTracker
//
//  Created by Chappy Asel on 2/24/18.
//  Copyright © 2018 CD. All rights reserved.
//

#import "ExerciseSummaryView.h"
#import "BTExerciseType+CoreDataClass.h"
#import "BTExercise+CoreDataClass.h"
#import "BTSettings+CoreDataClass.h"

@interface ExerciseSummaryView()

@property (strong, nonatomic) IBOutletCollection(UILabel) NSArray<UILabel *> *titleLabels;
@property (strong, nonatomic) IBOutletCollection(UILabel) NSArray<UILabel *> *subtitleLabels;

@property (nonatomic) BTSettings *settings;

@property (nonatomic) int64_t totalVolume;
@property (nonatomic) int64_t totalSets;
@property (nonatomic) float average1RM;

@end

@implementation ExerciseSummaryView

- (void)awakeFromNib {
    [super awakeFromNib];
    self.settings = [BTSettings sharedInstance];
}

- (void)loadWithExerciseType:(BTExerciseType *)exerciseType iteration:(NSString *)iteration {
    bool all = [exerciseType.style isEqualToString:STYLE_REPSWEIGHT];
    for (UIView *view in @[self.titleLabels[0], self.titleLabels[2], self.subtitleLabels[0], self.subtitleLabels[2]])
        view.alpha = all;
    __block NSArray *exercises = [exerciseType allInstancesOfIteration:iteration];
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        float total1RM = 0;
        int total = 0;
        self.totalVolume = 0;
        self.totalSets = 0;
        for (BTExercise *exercise in exercises) {
            self.totalVolume += exercise.volume;
            self.totalSets += exercise.numberOfSets;
            total1RM += exercise.oneRM;
            total ++;
        }
        self.average1RM = (total > 0) ? total1RM/total : 0;
        dispatch_async(dispatch_get_main_queue(), ^{
            [self loadHeaderLabelsWithRatio:@1];
        });
    });
 }

- (void)animateIn {
    for (int i = 1; i <= 12; i++)
        [self performSelector:@selector(loadHeaderLabelsWithRatio:) withObject:[NSNumber numberWithFloat:i/12.0] afterDelay:
         [@[@0, @.04, @.1, @.17, @.25, @.34, @.44, @.55, @.67, @.81, @.98, @1.18, @1.48][i] floatValue]];
}

- (void)loadHeaderLabelsWithRatio:(NSNumber *)ratio { //0-1
    NSMutableAttributedString *s = [[NSMutableAttributedString alloc] initWithString:
                                    [NSString stringWithFormat:@"%.0f", self.totalVolume/1000*ratio.floatValue]];
    [s appendAttributedString:[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"k %@", self.settings.weightSuffix]
                                                              attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:17 weight:UIFontWeightMedium]}]];
    self.titleLabels[0].attributedText = s;
    self.titleLabels[1].text = [NSString stringWithFormat:@"%.0f", self.totalSets*ratio.floatValue];
    s = [[NSMutableAttributedString alloc] initWithString: [NSString stringWithFormat:@"%.0f", self.average1RM*ratio.floatValue]];
    [s appendAttributedString:[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@" %@", self.settings.weightSuffix]
                                                              attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:17 weight:UIFontWeightMedium]}]];
    self.titleLabels[2].attributedText = s;
}

@end
