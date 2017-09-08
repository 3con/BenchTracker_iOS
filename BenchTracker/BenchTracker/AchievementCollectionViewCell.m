//
//  AchievementCollectionViewCell.m
//  BenchTracker
//
//  Created by Chappy Asel on 9/7/17.
//  Copyright © 2017 CD. All rights reserved.
//

#import "AchievementCollectionViewCell.h"
#import "BTAchievement+CoreDataClass.h"

@interface AchievementCollectionViewCell ()
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *detailLabel;
@end

@implementation AchievementCollectionViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.layer.cornerRadius = 12;
    self.clipsToBounds = YES;
}

- (void)loadWithAchievement:(BTAchievement *)achievement {
    NSLog(@"%@",achievement.key);
    self.backgroundColor = (achievement.color) ? achievement.color : [UIColor BTVibrantColors][0];
    self.imageView.image = achievement.image;
    NSLog(@"%@",self.imageView.image);
    if (achievement.hidden) {
        self.alpha = .4;
        self.nameLabel.text = @"???";
        self.detailLabel.text = @"";
    }
    else {
        self.alpha = 1;
        self.nameLabel.text = achievement.name;
        self.detailLabel.text = [NSString stringWithFormat:@"%d xp",achievement.xp];
    }
}

@end
