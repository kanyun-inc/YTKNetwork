//
//  YTKNetwork.h
//
//  Copyright (c) 2012-2016 YTKNetwork https://github.com/yuantiku
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.

#import <Foundation/Foundation.h>

#ifndef _YTKNETWORK_
    #define _YTKNETWORK_

#if __has_include(<YTKNetwork/YTKNetwork.h>)

    FOUNDATION_EXPORT double YTKNetworkVersionNumber;
    FOUNDATION_EXPORT const unsigned char YTKNetworkVersionString[];

    #import <YTKNetwork/YTKRequest.h>
    #import <YTKNetwork/YTKBaseRequest.h>
    #import <YTKNetwork/YTKNetworkAgent.h>
    #import <YTKNetwork/YTKBatchRequest.h>
    #import <YTKNetwork/YTKBatchRequestAgent.h>
    #import <YTKNetwork/YTKChainRequest.h>
    #import <YTKNetwork/YTKChainRequestAgent.h>
    #import <YTKNetwork/YTKNetworkConfig.h>
    #import <YTKNetwork/YTKRequestEventAccessory.h>

#else

    #import "YTKRequest.h"
    #import "YTKBaseRequest.h"
    #import "YTKNetworkAgent.h"
    #import "YTKBatchRequest.h"
    #import "YTKBatchRequestAgent.h"
    #import "YTKChainRequest.h"
    #import "YTKChainRequestAgent.h"
    #import "YTKNetworkConfig.h"
    #import "YTKRequestEventAccessory.h"

#endif /* __has_include */

#endif /* _YTKNETWORK_ */
