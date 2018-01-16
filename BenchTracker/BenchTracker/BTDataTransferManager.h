//
//  BTDataTransferManager.h
//  BenchTracker
//
//  Created by Chappy Asel on 8/2/17.
//  Copyright © 2017 CD. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface BTDataTransferManager : NSObject

+ (NSString *)pathForJSONDataExport;

+ (BOOL)loadJSONDataWithURL:(NSURL *)url;

@end
