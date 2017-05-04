//
//  OCPDFGenerator.m
//  OCPDFGen
//
//  Created by Oliver Rickard on 3/18/12.
//  Copyright (c) 2012 UC Berkeley. All rights reserved.
//

#import "OCPDFGenerator.h"
#import <CoreText/CoreText.h>
#import "DTCoreText/DTCoreText.h"

@implementation OCPDFGenerator

+(NSString *)generatePDFFromAttributedString:(NSAttributedString *)str {
   
    NSString *fileName = @"testFile.pdf";
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *newFilePath = [[paths objectAtIndex:0] stringByAppendingPathComponent:fileName];
    
    int fontSize = 12;
    NSString *font = @"Verdana";
    UIColor *color = [UIColor blackColor];
    
    int DOC_WIDTH = 612;
    int DOC_HEIGHT = 792;
    int LEFT_MARGIN = 50;
    int RIGHT_MARGIN = 50;
    int TOP_MARGIN = 50;
    int BOTTOM_MARGIN = 50;
    
    int CURRENT_TOP_MARGIN = TOP_MARGIN;
    
    //You can make the first page have a different top margin to place headers, etc.
    int FIRST_PAGE_TOP_MARGIN = TOP_MARGIN;
    
    CGRect a4Page = CGRectMake(0, 0, DOC_WIDTH, DOC_HEIGHT);
    
    NSDictionary *fileMetaData = [[NSDictionary alloc] init];
    
    if (!UIGraphicsBeginPDFContextToFile(newFilePath, a4Page, fileMetaData )) {
        NSLog(@"error creating PDF context");
        return nil;
    }
    
    BOOL done = NO;
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CFRange currentRange = CFRangeMake(0, 0);
    
    CGContextSetTextDrawingMode (context, kCGTextFill);
    CGContextSelectFont (context, [font cStringUsingEncoding:NSUTF8StringEncoding], fontSize, kCGEncodingMacRoman);                                                 
    CGContextSetFillColorWithColor(context, [color CGColor]);
    // Initialize an attributed string.
    CFAttributedStringRef attrString = (__bridge CFAttributedStringRef)str;
    
    // Create the framesetter with the attributed string.
    CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString(attrString);
    
    int pageCount = 1;
    
    do {
        UIGraphicsBeginPDFPage();
        CGMutablePathRef path = CGPathCreateMutable();
        
        if(pageCount == 1) {
            CURRENT_TOP_MARGIN = FIRST_PAGE_TOP_MARGIN;
        } else {
            CURRENT_TOP_MARGIN = TOP_MARGIN;
        }
        
        CGRect bounds = CGRectMake(LEFT_MARGIN, 
                                   CURRENT_TOP_MARGIN, 
                                   DOC_WIDTH - RIGHT_MARGIN - LEFT_MARGIN, 
                                   DOC_HEIGHT - CURRENT_TOP_MARGIN - BOTTOM_MARGIN);
        
        CGPathAddRect(path, NULL, bounds);
        
        // Create the frame and draw it into the graphics context
        CTFrameRef frame = CTFramesetterCreateFrame(framesetter, currentRange, path, NULL);
        
        if(frame) {
            CGContextSaveGState(context);
            CGContextTranslateCTM(context, 0, bounds.origin.y); 
            CGContextScaleCTM(context, 1, -1); 
            CGContextTranslateCTM(context, 0, -(bounds.origin.y + bounds.size.height)); 
            CTFrameDraw(frame, context);
            CGContextRestoreGState(context); 
            
            // Update the current range based on what was drawn.
            currentRange = CTFrameGetVisibleStringRange(frame);
            currentRange.location += currentRange.length;
            currentRange.length = 0;
            
        }
        
        // If we're at the end of the text, exit the loop.
        if (currentRange.location == CFAttributedStringGetLength((CFAttributedStringRef)attrString))
            done = YES;
        
        pageCount++;
    } while(!done);
    
    UIGraphicsEndPDFContext();
    
    return newFilePath;
}

+(NSString *)generatePDFFromHTMLString:(NSString *)html {
    NSData *data = [html dataUsingEncoding:NSUTF8StringEncoding];
	
	// Create attributed string from HTML
	CGSize maxImageSize = CGSizeMake(500, 500);
	
	NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithFloat:1.0], NSTextSizeMultiplierDocumentOption, [NSValue valueWithCGSize:maxImageSize], DTMaxImageSize,
                             @"Arial", DTDefaultFontFamily,  @"blue", DTDefaultLinkColor, nil];
    
    NSAttributedString *str = [[NSAttributedString alloc]initWithHTMLData:data options:options documentAttributes:NULL];
    return [self generatePDFFromAttributedString:str];
}

@end
