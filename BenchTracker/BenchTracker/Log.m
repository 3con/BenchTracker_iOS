//
//  Log.m
//  BenchTracker
//
//  Created by Chappy Asel on 7/30/18.
//  Copyright © 2018 CD. All rights reserved.
//

#import "Log.h"
#import "Amplitude.h"
#import "BTSettings+CoreDataClass.h"
#import "BTUser+CoreDataClass.h"

@implementation Log

+ (void)sendIdentity {
    BTUser *user = BTUser.sharedInstance;
    BTSettings *settings = BTSettings.sharedInstance;
    NSDictionary *properties = @{@"User":     @{@"Dark mode": @(UIColor.colorScheme),
                                                @"Shift dates": settings.shiftDates,
                                                @"Default reminder time": settings.defaultReminderTime,
                                                @"Date types": settings.dateTypes},
                                 @"Settings": @{@"Dark mode": @(UIColor.colorScheme),
                                                @"Shift dates": settings.shiftDates,
                                                @"Default reminder time": settings.defaultReminderTime,
                                                @"Date types": settings.dateTypes,
                                                @"Show image": settings.showImage,
                                                @"Show notes": settings.showNotes,
                                                @"Manual date assigned": settings.manualDateAssinged,
                                                @"Split weekend": settings.spitWeekend,
                                                @"Alphabetical periods": settings.letterPeriods,
                                                @"Abbrev is period": settings.abbrevIsPeriod}};
    [Amplitude.instance setUserProperties:properties];
}

+ (void)event:(NSString *)event properties:(NSDictionary *)properties {
    [Amplitude.instance logEvent:event withEventProperties:properties];
}

@end
