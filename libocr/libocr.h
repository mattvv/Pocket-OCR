//    liborc.h
//    OCR
//
//    Created by Nachiketa Mishrs on 10.07.2011.
//
//    Copyright (C) 2011, Nachiketa Mishra | symora.com
//
//    This program is free software: you can redistribute it and/or modify
//    it under the terms of the GNU General Public License as published by
//    the Free Software Foundation, either version 3 of the License, or
//    (at your option) any later version.
//
//    This program is distributed in the hope that it will be useful,
//    but WITHOUT ANY WARRANTY; without even the implied warranty of
//    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//    GNU General Public License for more details.
//
//    You should have received a copy of the GNU General Public License
//    along with this program.  If not, see <http://www.gnu.org/licenses/>.

#import <Foundation/Foundation.h>
#import <math.h>
#import <UIKit/UIKit.h>


// conditionally import or forward declare to contain objective-c++ code to here.
#ifdef __cplusplus
#import "baseapi.h"
using namespace tesseract;
#else
@class TessBaseAPI;
#endif

@interface libocr : NSObject {
    TessBaseAPI *tess;
}
- (NSString*)readAndProcessImage:(UIImage *)uiImage;
@end
