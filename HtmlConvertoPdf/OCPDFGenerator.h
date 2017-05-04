//
//  OCPDFGenerator.h
//  OCPDFGen
//
//  Created by Oliver Rickard on 3/18/12.
//  Copyright (c) 2012 UC Berkeley. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OCPDFGenerator : NSObject

+(NSString *)generatePDFFromAttributedString:(NSAttributedString *)str;
+(NSString *)generatePDFFromHTMLString:(NSString *)str;

@end
