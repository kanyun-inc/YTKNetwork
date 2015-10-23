//
//  UploadImageApi.m
//  Solar
//
//  Created by tangqiao on 8/7/14.
//  Copyright (c) 2014 fenbi. All rights reserved.
//

#import "UploadImageApi.h"

@implementation UploadImageApi {
    UIImage *_image;
}

- (id)initWithImage:(UIImage *)image {
    self = [super init];
    if (self) {
        _image = image;
    }
    return self;
}

- (YTKRequestMethod)requestMethod {
    return YTKRequestMethodPost;
}

//- (id)requestArgument {
//    return @{ @"token": @"123123" };
//}

- (NSString *)requestUrl {
    return @"http://10.0.12.221:8080/Api/Users/avatar";
}

- (AFConstructingBlock)constructingBodyBlock {
    return ^(id<AFMultipartFormData> formData) {
        NSData *data = UIImageJPEGRepresentation(_image, 0.9);
        NSString *name = @"nameOfFile";
        NSString *formKey = @"avatar";
        NSString *type = @"image/jpeg";
        [formData appendPartWithFileData:data name:formKey fileName:name mimeType:type];
    };
}

- (AFUploadProgressBlock)uploadProgressBlock{
    return ^(NSUInteger bytesWritten, long long totalBytesWritten, long long totalBytesExpectedToWrite){
        NSLog(@"==============\nbytesWritten: %ld \ntotalBytesWritten: %lld \ntotalBytesExpectedToWrite: %lld",bytesWritten,totalBytesWritten, totalBytesExpectedToWrite);
    };
}

- (id)jsonValidator {
    return @{ @"imageId": [NSString class] };
}

- (NSString *)responseImageId {
    NSDictionary *dict = self.responseJSONObject;
    return dict[@"imageId"];
}

@end
