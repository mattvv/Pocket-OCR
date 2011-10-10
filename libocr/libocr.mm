//
//  libocr.m
//  libocr
//
//  Created by Nachiketa Mishra on 10/7/11.
//  Copyright 2011 Symora. All rights reserved.
//

#import "libocr.h"
#import "baseapi.h"

#import "UIImage+Resize.h"
#import <math.h>

@implementation libocr

- (id)init
{
    self = [super init];
    if (self) {
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *basePath = ([paths count] > 0) ? [paths objectAtIndex:0] : nil;
        // Set up the tessdata path. This is included in the application bundle
        // but is copied to the Documents directory on the first run.
        NSString *dataPath = [basePath stringByAppendingPathComponent:@"tessdata"];
        NSFileManager *fileManager = [NSFileManager defaultManager];
        // If the expected store doesn't exist, copy the default store.
        if (![fileManager fileExistsAtPath:dataPath]) {
            // get the path to the app bundle (with the tessdata dir)
            NSString *bundlePath = [[NSBundle mainBundle] bundlePath];
            NSString *tessdataPath = [bundlePath stringByAppendingPathComponent:@"tessdata-svn"];
            if (tessdataPath) {
                [fileManager copyItemAtPath:tessdataPath toPath:dataPath error:NULL];
            }
        }
        
        NSString *dataPathWithSlash = [basePath stringByAppendingString:@"/"];
        setenv("TESSDATA_PREFIX", [dataPathWithSlash UTF8String], 1);
        // init the tesseract engine.
        tess = new TessBaseAPI();
        tess->Init([dataPath cStringUsingEncoding:NSUTF8StringEncoding],    // Path to tessdata-no ending /.
                   "eng");        
    }
    
    return self;
}

// preferred, threaded method:
- (NSString*)readAndProcessImage:(UIImage *)uiImage 
{
    NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
    
    CGSize imageSize = [uiImage size];
    int bytes_per_line  = (int)CGImageGetBytesPerRow([uiImage CGImage]);
    int bytes_per_pixel = (int)CGImageGetBitsPerPixel([uiImage CGImage]) / 8.0;
    
    CFDataRef data = CGDataProviderCopyData(CGImageGetDataProvider([uiImage CGImage]));
    const UInt8 *imageData = CFDataGetBytePtr(data);
    
    // this could take a while.
    char *text = tess->TesseractRect(imageData,
                                     bytes_per_pixel,
                                     bytes_per_line,
                                     0, 0,
                                     imageSize.width, imageSize.height);
    char* boxText = tess->GetBoxText(0);
    
    //match the text with the position and return the position of the first letter in a line
    NSString *ocrText = [NSString stringWithCString:text encoding:NSUTF8StringEncoding];
    NSString *ocrTextPosition = [NSString stringWithCString:boxText encoding:NSUTF8StringEncoding];
    NSMutableArray *returnArray = [NSMutableArray arrayWithCapacity:[ocrText length]];
    NSMutableArray *linesWithPositionData = [NSMutableArray arrayWithArray:[ocrTextPosition componentsSeparatedByString:@"\n"]];
    NSLog(@"linesWithPositionData => %@", linesWithPositionData);
    [ocrText enumerateLinesUsingBlock:^(NSString *line, BOOL *stop) {
        NSLog(@"line =>%@",line);
        if ([line length] != 0) {
            NSArray *tokens = [[linesWithPositionData objectAtIndex:0] componentsSeparatedByString:@" "];
            NSArray *coordsArray = [NSArray arrayWithObjects:[tokens objectAtIndex:1], [tokens objectAtIndex:2],nil];
            NSMutableArray *data = [NSMutableArray arrayWithObjects:line,coordsArray,nil];
            [returnArray addObject:data];
            NSString *strippedString = [line stringByReplacingOccurrencesOfString:@ " " withString:@""];
            [linesWithPositionData removeObjectsInRange:NSMakeRange(0,[strippedString length])];
        }
    }];
    NSLog(@"returnArray => %@", returnArray);
     
    CFRelease(data);
    [pool release];
    return [NSString stringWithCString:text encoding:NSUTF8StringEncoding];
    
}
@end
