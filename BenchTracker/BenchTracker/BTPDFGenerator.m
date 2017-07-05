//
//  BTPDFGenerator.m
//  BenchTracker
//
//  Created by Chappy Asel on 7/5/17.
//  Copyright © 2017 CD. All rights reserved.
//

#import "BTPDFGenerator.h"
#import <UIKit/UIKit.h>
#import "BTWorkout+CoreDataClass.h"
#import "BTExercise+CoreDataClass.h"
#import "BTWorkoutPDF.h"
#import <CoreText/CoreText.h>

@interface BTPDFGenerator ()

@end

@implementation BTPDFGenerator

+ (NSString *)generatePDFWithWorkouts:(NSArray <BTWorkout *> *)workouts {
    NSString *filepath = [[NSTemporaryDirectory() stringByAppendingPathComponent:@"temp"] stringByAppendingPathExtension:@"pdf"];
    UIGraphicsBeginPDFContextToFile(filepath, CGRectZero, nil);
    CGContextRef context = UIGraphicsGetCurrentContext();
    for (BTWorkout *workout in workouts) {
        [self drawPageForWorkout:workout withContext:context];
    }
    UIGraphicsEndPDFContext();
    return filepath;
}

+ (void)drawPageForWorkout:(BTWorkout *)workout withContext:(CGContextRef)context {
    UIGraphicsBeginPDFPageWithInfo(CGRectMake(0, 0, 612, 792), nil);
    BTWorkoutPDF *page = [[NSBundle mainBundle] loadNibNamed:@"BTWorkoutPDF" owner:self options:nil].firstObject;
    [page loadWorkout:workout];
    NSLog(@"%@",page.titleLabel);
    NSLog(@"%@",page.tableView);
    NSLog(@"%@",page.metadataLabel1);
    NSLog(@"%@",page.metadataLabel2);
    [self drawLabel:page.titleLabel];
    [self drawLabel:page.metadataLabel1];
    [self drawLabel:page.metadataLabel2];
    int i = 0;
    for (BTExercise *exercise in workout.exercises) {
        NSString *fStr;
        NSArray <NSString *> *tempSets = [NSKeyedUnarchiver unarchiveObjectWithData:exercise.sets];
        NSString *str = [self formattedArray:tempSets];
        if (exercise.iteration) fStr = [NSString stringWithFormat:@"%@ %@: %@",exercise.iteration,exercise.name, str];
        else fStr = [NSString stringWithFormat:@"%@: %@",exercise.name, str];
        [self drawText:fStr inFrame:CGRectMake(page.tableView.frame.origin.x, page.tableView.frame.origin.y+30*i,
                                              page.tableView.frame.size.width, 30)
              fontName:@"Helvetica" size:15 color:[UIColor blackColor] centerAlign:NO];
        i++;
    }
    //[self drawTableView:page.tableView];
}

+ (NSString *)formattedArray:(NSArray *)array {
    if (!array.count) return @"";
    NSString *s = @"";
    for (NSString *x in array) s = [NSString stringWithFormat:@"%@, %@",s,x];
    return [s substringFromIndex:2];
}

+ (void)drawLabel:(UILabel *)label {
    [self drawText:label.text inFrame:label.frame fontName:label.font.fontName size:label.font.pointSize color:label.textColor centerAlign:(label.textAlignment == NSTextAlignmentCenter)];
}

+ (void)drawText:(NSString*)textToDraw inFrame:(CGRect)frameRect fontName:(NSString *)fontName size:(int)fontSize color:(UIColor *)color centerAlign:(BOOL)centerAlign {
    CFStringRef stringRef = (__bridge CFStringRef)textToDraw;
    CTFontRef font = CTFontCreateWithName((CFStringRef)fontName, fontSize, NULL);
    
    // Prepare the text using a Core Text Framesetter.
    CTTextAlignment theAlignment = (centerAlign) ? kCTTextAlignmentCenter : kCTTextAlignmentLeft;
    CTParagraphStyleSetting theSettings[1] = {{ kCTParagraphStyleSpecifierAlignment, sizeof(CTTextAlignment), &theAlignment }};
    CFStringRef keys[] = { kCTFontAttributeName, kCTForegroundColorAttributeName, kCTParagraphStyleAttributeName };
    CFTypeRef values[] = { font, color.CGColor, CTParagraphStyleCreate(theSettings, 1)};
    CFDictionaryRef attr = CFDictionaryCreate(NULL, (const void **)&keys, (const void **)&values,
                                              sizeof(keys) / sizeof(keys[0]), &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
    CFAttributedStringRef currentText = CFAttributedStringCreate(NULL, stringRef, attr);
    CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString(currentText);
    
    CGMutablePathRef framePath = CGPathCreateMutable();
    CGPathAddRect(framePath, NULL, frameRect);
    
    // Get the frame that will do the rendering.
    CFRange currentRange = CFRangeMake(0, 0);
    CTFrameRef frameRef = CTFramesetterCreateFrame(framesetter, currentRange, framePath, NULL);
    CGPathRelease(framePath);
    
    // Get the graphics context.
    CGContextRef currentContext = UIGraphicsGetCurrentContext();
    
    // Put the text matrix into a known state. This ensures
    // that no old scaling factors are left in place.
    CGContextSetTextMatrix(currentContext, CGAffineTransformIdentity);
    
    // Core Text draws from the bottom-left corner up, so flip
    // the current transform prior to drawing.
    CGContextTranslateCTM(currentContext, 0, frameRect.origin.y*2+frameRect.size.height);
    CGContextScaleCTM(currentContext, 1.0, -1.0);
    
    // Draw the frame.
    CTFrameDraw(frameRef, currentContext);
    
    //Flip back
    CGContextScaleCTM(currentContext, 1.0, -1.0);
    CGContextTranslateCTM(currentContext, 0, -1*(frameRect.origin.y*2+frameRect.size.height));
    
    CFRelease(frameRef);
    CFRelease(stringRef);
    CFRelease(framesetter);
}

+ (void)drawTableView:(UITableView *)tableView {
    CGContextRef currentContext = UIGraphicsGetCurrentContext();
    [tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:NO];
    CGContextTranslateCTM(currentContext, tableView.frame.origin.x, tableView.frame.origin.y);
    [tableView.layer renderInContext:currentContext];
    int rows = (int)[tableView numberOfRowsInSection:0];
    int numberofRowsInView = 4;
    for (int i =0; i < rows/numberofRowsInView; i++) {
        [tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:(i+1)*numberofRowsInView inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:NO];
        [tableView.layer renderInContext:currentContext];
    }
}

@end
