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
    [self drawLabel:page.nameLabel];
    [self drawLabel:page.titleLabel];
    [self drawLabel:page.imageLabel1];
    [self drawLabel:page.imageLabel2];
    [self drawLabel:page.metadataLabel1];
    [self drawLabel:page.metadataLabel2];
    int i = 0;
    UILabel *label = [[UILabel alloc] init];
    label.font = [UIFont fontWithName:@"Helvetica" size:15];
    label.textColor = [UIColor blackColor];
    label.numberOfLines = 2;
    NSMutableArray <NSNumber *> *labelTops = [NSMutableArray array];
    NSMutableArray <NSNumber *> *labelBottoms = [NSMutableArray array];
    for (BTExercise *exercise in workout.exercises) {
        NSString *str = [self formattedArray:[NSKeyedUnarchiver unarchiveObjectWithData:exercise.sets]];
        if (exercise.iteration) label.text = [NSString stringWithFormat:@"%@ %@:  %@",exercise.iteration,exercise.name, str];
        else label.text = [NSString stringWithFormat:@"%@:  %@",exercise.name, str];
        label.frame = CGRectMake(page.tableView.frame.origin.x, page.tableView.frame.origin.y+i, page.tableView.frame.size.width, 40);
        [self drawLabel:label];
        int increment = ([self lineCountForLabel:label] == 2) ? 40 : 25;
        [labelTops addObject:[NSNumber numberWithFloat:label.frame.origin.y]];
        [labelBottoms addObject:[NSNumber numberWithFloat:label.frame.origin.y+increment]];
        i += increment;
    }
    for (NSArray *superset in [NSKeyedUnarchiver unarchiveObjectWithData:workout.supersets]) {
        float yTop = labelTops[[superset.firstObject intValue]].floatValue+5;
        float yBottom = labelBottoms[[superset.lastObject intValue]].floatValue-8;
        [self drawLineFromPoint:CGPointMake(39, yTop)
                        toPoint:CGPointMake(45, yTop)];
        
        [self drawLineFromPoint:CGPointMake(40, yTop)
                        toPoint:CGPointMake(40, yBottom)];
        
        [self drawLineFromPoint:CGPointMake(39, yBottom)
                        toPoint:CGPointMake(45, yBottom)];
    }
    //[self drawTableView:page.tableView];
    [self drawImageView:page.imageView1];
    [self drawImageView:page.imageView2];
}

+ (int)lineCountForLabel:(UILabel *)label {
    CGRect rect = [label.text boundingRectWithSize: CGSizeMake(label.frame.size.width, CGFLOAT_MAX)
        options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName: label.font} context:nil];
    return ceil(rect.size.height / label.font.lineHeight);
}

+ (NSString *)formattedArray:(NSArray *)array {
    if (!array.count) return @"";
    NSString *s = @"";
    for (NSString *x in array) {
        NSArray *a = [x componentsSeparatedByString:@" "];
        if ([x containsString:@"~"]) s = [NSString stringWithFormat:@"%@, %@",s,[x substringFromIndex:2]];
        if ([x containsString:@"s"])
             s = (a.count == 3) ? [NSString stringWithFormat:@"%@, %@ secs (%@)",s,a[1],a[2]] : [NSString stringWithFormat:@"%@, %@ secs",s,a[1]];
        else s = (a.count == 2) ? [NSString stringWithFormat:@"%@, %@x%@",s,a[0],a[1]] : [NSString stringWithFormat:@"%@, %@",s,a[0]];
    }
    return [s substringFromIndex:2];
}

+ (void)drawLabel:(UILabel *)label {
    [self drawText:label.text inFrame:label.frame fontName:label.font.fontName size:label.font.pointSize color:label.textColor centerAlign:(label.textAlignment == NSTextAlignmentCenter)];
}

+ (void)drawText:(NSString*)textToDraw inFrame:(CGRect)frameRect fontName:(NSString *)fontName size:(int)fontSize color:(UIColor *)color centerAlign:(BOOL)centerAlign {
    CFStringRef stringRef = (__bridge CFStringRef)textToDraw;
    CTFontRef font = CTFontCreateWithName((CFStringRef)fontName, fontSize, NULL);
    
    // Prepare the text using a Core Text Framesetter.
    CGFloat lineSpacing = 0;
    CTTextAlignment theAlignment = (centerAlign) ? kCTTextAlignmentCenter : kCTTextAlignmentLeft;
    CTParagraphStyleSetting theSettings[2] = {{ kCTParagraphStyleSpecifierAlignment, sizeof(CTTextAlignment), &theAlignment},
                                              {kCTParagraphStyleSpecifierMaximumLineSpacing, sizeof(CGFloat), &lineSpacing}};
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

+ (void)drawLineFromPoint:(CGPoint)from toPoint:(CGPoint)to {
    NSLog(@"%f %f",from.y,to.y);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetLineWidth(context, 2.0);
    CGColorSpaceRef colorspace = CGColorSpaceCreateDeviceRGB();
    CGFloat components[] = {0.75, 0.75, 0.75, 1};
    CGColorRef color = CGColorCreate(colorspace, components);
    CGContextSetStrokeColorWithColor(context, color);
    CGContextMoveToPoint(context, from.x, from.y);
    CGContextAddLineToPoint(context, to.x, to.y);
    CGContextStrokePath(context);
    CGColorSpaceRelease(colorspace);
    CGColorRelease(color);
}

+ (void)drawImageView:(UIImageView *)imageView {
    [imageView.image drawInRect:imageView.frame];
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
