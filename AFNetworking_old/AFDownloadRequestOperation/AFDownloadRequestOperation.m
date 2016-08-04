// AFDownloadRequestOperation.m
//
// Copyright (c) 2012 Peter Steinberger (http://petersteinberger.com)
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import "AFDownloadRequestOperation.h"
#import "AFURLConnectionOperation.h"
#import <CommonCrypto/CommonDigest.h>
#include <fcntl.h>
#include <unistd.h>

#if !__has_feature(objc_arc)
#error "Compile this file with ARC"
#endif

@interface AFURLConnectionOperation (AFInternal)
@property (nonatomic, strong) NSURLRequest *request;
@property (readonly, nonatomic, assign) long long totalBytesRead;
@end

typedef void (^AFURLConnectionProgressiveOperationProgressBlock)(AFDownloadRequestOperation *operation, NSInteger bytes, long long totalBytes, long long totalBytesExpected, long long totalBytesReadForFile, long long totalBytesExpectedToReadForFile);

@interface AFDownloadRequestOperation() {
    NSError *_fileError;
    id _responseObject;
}
@property (nonatomic, strong) NSString *tempPath;
@property (assign) long long totalContentLength;
@property (nonatomic, assign) long long totalBytesReadPerDownload;
@property (assign) long long offsetContentLength;
@property (nonatomic, copy) AFURLConnectionProgressiveOperationProgressBlock progressiveDownloadProgress;
@end

@implementation AFDownloadRequestOperation

#pragma mark - NSObject

- (void)dealloc {
    if (_progressiveDownloadCallbackQueue) {
#if !OS_OBJECT_USE_OBJC
        dispatch_release(_progressiveDownloadCallbackQueue);
#endif
        _progressiveDownloadCallbackQueue = NULL;
    }
}

- (id)initWithRequest:(NSURLRequest *)urlRequest targetPath:(NSString *)targetPath shouldResume:(BOOL)shouldResume {
    if ((self = [super initWithRequest:urlRequest])) {
        NSParameterAssert(targetPath != nil && urlRequest != nil);
        _shouldResume = shouldResume;

        // Ee assume that at least the directory has to exist on the targetPath
        BOOL isDirectory;
        if(![[NSFileManager defaultManager] fileExistsAtPath:targetPath isDirectory:&isDirectory]) {
            isDirectory = NO;
        }
        // \If targetPath is a directory, use the file name we got from the urlRequest.
        if (isDirectory) {
            NSString *fileName = [urlRequest.URL lastPathComponent];
            _targetPath = [NSString pathWithComponents:@[targetPath, fileName]];
        }else {
            _targetPath = targetPath;
        }

        // Download is saved into a temorary file and renamed upon completion.
        NSString *tempPath = [self tempPath];

        // Do we need to resume the file?
        BOOL isResuming = [self updateByteStartRangeForRequest];
        
        // Try to create/open a file at the target location
        if (!isResuming) {
            int fileDescriptor = open([tempPath UTF8String], O_CREAT | O_EXCL | O_RDWR, 0666);
            if (fileDescriptor > 0) close(fileDescriptor);
        }

        self.outputStream = [NSOutputStream outputStreamToFileAtPath:tempPath append:isResuming];
        // If the output stream can't be created, instantly destroy the object.
        if (!self.outputStream) return nil;
        
        // Give the object its default completionBlock.
        [self setCompletionBlockWithSuccess:nil failure:nil];
    }
    return self;
}

// updates the current request to set the correct start-byte-range.
- (BOOL)updateByteStartRangeForRequest {
    BOOL isResuming = NO;
    if (self.shouldResume) {
        unsigned long long downloadedBytes = [self fileSizeForPath:[self tempPath]];
        if (downloadedBytes > 1) {

            // If the the current download-request's data has been fully downloaded, but other causes of the operation failed (such as the inability of the incomplete temporary file copied to the target location), next, retry this download-request, the starting-value (equal to the incomplete temporary file size) will lead to an HTTP 416 out of range error, unless we subtract one byte here. (We don't know the final size before sending the request)
            downloadedBytes--;

            NSMutableURLRequest *mutableURLRequest = [self.request mutableCopy];
            NSString *requestRange = [NSString stringWithFormat:@"bytes=%llu-", downloadedBytes];
            [mutableURLRequest setValue:requestRange forHTTPHeaderField:@"Range"];
            self.request = mutableURLRequest;
            isResuming = YES;
        }
    }
    return isResuming;
}

#pragma mark - Public

- (BOOL)deleteTempFileWithError:(NSError *__autoreleasing*)error {
    NSFileManager *fileManager = [NSFileManager new];
    BOOL success = YES;
    @synchronized(self) {
        NSString *tempPath = [self tempPath];
        if ([fileManager fileExistsAtPath:tempPath]) {
            success = [fileManager removeItemAtPath:[self tempPath] error:error];
        }
    }
    return success;
}

- (NSString *)tempPath {
    NSString *tempPath = nil;
    if (self.targetPath) {
        NSString *md5URLString = [[self class] md5StringForString:self.targetPath];
        tempPath = [[[self class] cacheFolder] stringByAppendingPathComponent:md5URLString];
    }
    return tempPath;
}


- (void)setProgressiveDownloadProgressBlock:(void (^)(AFDownloadRequestOperation *operation, NSInteger bytesRead, long long totalBytesRead, long long totalBytesExpected, long long totalBytesReadForFile, long long totalBytesExpectedToReadForFile))block {
    self.progressiveDownloadProgress = block;
}

- (void)setProgressiveDownloadCallbackQueue:(dispatch_queue_t)progressiveDownloadCallbackQueue {
    if (progressiveDownloadCallbackQueue != _progressiveDownloadCallbackQueue) {
        if (_progressiveDownloadCallbackQueue) {
#if !OS_OBJECT_USE_OBJC
            dispatch_release(_progressiveDownloadCallbackQueue);
#endif
            _progressiveDownloadCallbackQueue = NULL;
        }
        
        if (progressiveDownloadCallbackQueue) {
#if !OS_OBJECT_USE_OBJC
            dispatch_retain(progressiveDownloadCallbackQueue);
#endif
            _progressiveDownloadCallbackQueue = progressiveDownloadCallbackQueue;
        }
    }
}


#pragma mark - Private

- (unsigned long long)fileSizeForPath:(NSString *)path {
    signed long long fileSize = 0;
    NSFileManager *fileManager = [NSFileManager new]; // default is not thread safe
    if ([fileManager fileExistsAtPath:path]) {
        NSError *error = nil;
        NSDictionary *fileDict = [fileManager attributesOfItemAtPath:path error:&error];
        if (!error && fileDict) {
            fileSize = [fileDict fileSize];
        }
    }
    return fileSize;
}

#pragma mark - AFHTTPRequestOperation

+ (NSIndexSet *)acceptableStatusCodes {
	NSMutableIndexSet *acceptableStatusCodes = [NSMutableIndexSet indexSetWithIndexesInRange:NSMakeRange(200, 100)];
	[acceptableStatusCodes addIndex:416];
	
	return acceptableStatusCodes;
}

#pragma mark - AFURLRequestOperation

- (void)pause {
    [super pause];
    [self updateByteStartRangeForRequest];
}

- (id)responseObject {
    @synchronized(self) {
        if (!_responseObject && [self isFinished] && !self.error) {
            NSError *localError = nil;
            if ([self isCancelled]) {
                // should we clean up? most likely we don't.
                if (self.isDeletingTempFileOnCancel) {
                    [self deleteTempFileWithError:&localError];
                    if (localError) {
                        _fileError = localError;
                    }
                }
                
                // loss of network connections = error set, but not cancel
            }else if(!self.error) {
                // move file to final position and capture error
                NSFileManager *fileManager = [NSFileManager new];
                if (self.shouldOverwrite) {
                    [fileManager removeItemAtPath:_targetPath error:NULL]; // avoid "File exists" error
                }
                [fileManager moveItemAtPath:[self tempPath] toPath:_targetPath error:&localError];
                if (localError) {
                    _fileError = localError;
                } else {
                    _responseObject = _targetPath;
                }
            }
        }
    }
    
    return _responseObject;
}

- (NSError *)error {
    return _fileError ?: [super error];
}

#pragma mark - NSURLConnectionDelegate

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    [super connection:connection didReceiveResponse:response];

    // check if we have the correct response
    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
    if (![httpResponse isKindOfClass:[NSHTTPURLResponse class]]) return;

    // check for valid response to resume the download if possible
    long long totalContentLength = self.response.expectedContentLength;
    long long fileOffset = 0;
    if(httpResponse.statusCode == 206) {
        NSString *contentRange = [httpResponse.allHeaderFields valueForKey:@"Content-Range"];
        if ([contentRange hasPrefix:@"bytes"]) {
            NSArray *bytes = [contentRange componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@" -/"]];
            if ([bytes count] == 4) {
                fileOffset = [bytes[1] longLongValue];
                totalContentLength = [bytes[3] longLongValue]; // if this is *, it's converted to 0
            }
        }
    }

    self.totalBytesReadPerDownload = 0;
    self.offsetContentLength = MAX(fileOffset, 0);
    self.totalContentLength = totalContentLength;
    
    // Truncate cache file to offset provided by server.
    // Using self.outputStream setProperty:@(_offsetContentLength) forKey:NSStreamFileCurrentOffsetKey]; will not work (in contrary to the documentation)
    NSString *tempPath = [self tempPath];
    if ([self fileSizeForPath:tempPath] != _offsetContentLength) {
        [self.outputStream close];
        BOOL isResuming = _offsetContentLength > 0;
        if (isResuming) {
            NSFileHandle *file = [NSFileHandle fileHandleForWritingAtPath:tempPath];
            [file truncateFileAtOffset:_offsetContentLength];
            [file closeFile];
        }
        self.outputStream = [NSOutputStream outputStreamToFileAtPath:tempPath append:isResuming];
        [self.outputStream open];
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data  {
    if (![self.responseSerializer validateResponse:self.response data:nil error:NULL])
        return; // don't write to output stream if any error occurs

    [super connection:connection didReceiveData:data];

    // track custom bytes read because totalBytesRead persists between pause/resume.
    self.totalBytesReadPerDownload += [data length];

    if (self.progressiveDownloadProgress) {
        dispatch_async(self.progressiveDownloadCallbackQueue ?: dispatch_get_main_queue(), ^{
            self.progressiveDownloadProgress(self,(NSInteger)[data length], self.totalBytesRead, self.response.expectedContentLength,self.totalBytesReadPerDownload + self.offsetContentLength, self.totalContentLength);
        });
    }
}

#pragma mark - Static

+ (NSString *)cacheFolder {
    NSFileManager *filemgr = [NSFileManager new];
    static NSString *cacheFolder;

    if (!cacheFolder) {
        NSString *cacheDir = NSTemporaryDirectory();
        cacheFolder = [cacheDir stringByAppendingPathComponent:kAFNetworkingIncompleteDownloadFolderName];
    }

    // ensure all cache directories are there
    NSError *error = nil;
    if(![filemgr createDirectoryAtPath:cacheFolder withIntermediateDirectories:YES attributes:nil error:&error]) {
        NSLog(@"Failed to create cache directory at %@", cacheFolder);
        cacheFolder = nil;
    }
    return cacheFolder;
}

// calculates the MD5 hash of a key
+ (NSString *)md5StringForString:(NSString *)string {
    const char *str = [string UTF8String];
    unsigned char r[CC_MD5_DIGEST_LENGTH];
    CC_MD5(str, (uint32_t)strlen(str), r);
    return [NSString stringWithFormat:@"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
            r[0], r[1], r[2], r[3], r[4], r[5], r[6], r[7], r[8], r[9], r[10], r[11], r[12], r[13], r[14], r[15]];
}

@end
