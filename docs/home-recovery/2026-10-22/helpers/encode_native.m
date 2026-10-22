#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>
#import <AVFoundation/AVFoundation.h>
#import <CoreVideo/CoreVideo.h>
int main(int argc, const char **argv) { @autoreleasepool {
 if (argc != 3) return 2;
 NSError *error=nil;
 NSDictionary *meta=[NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfFile:@(argv[1])] options:0 error:&error];
 NSArray *frames=meta[@"frames"];
 if (!frames.count) return 3;
 NSString *path=@(argv[2]); [[NSFileManager defaultManager] removeItemAtPath:path error:nil];
 AVAssetWriter *writer=[[AVAssetWriter alloc] initWithURL:[NSURL fileURLWithPath:path] fileType:AVFileTypeMPEG4 error:&error];
 AVAssetWriterInput *input=[AVAssetWriterInput assetWriterInputWithMediaType:AVMediaTypeVideo outputSettings:@{AVVideoCodecKey:AVVideoCodecTypeH264,AVVideoWidthKey:@1280,AVVideoHeightKey:@720,AVVideoCompressionPropertiesKey:@{AVVideoAverageBitRateKey:@2500000}}];
 NSDictionary *attrs=@{(NSString*)kCVPixelBufferPixelFormatTypeKey:@(kCVPixelFormatType_32ARGB),(NSString*)kCVPixelBufferWidthKey:@1280,(NSString*)kCVPixelBufferHeightKey:@720,(NSString*)kCVPixelBufferCGImageCompatibilityKey:@YES,(NSString*)kCVPixelBufferCGBitmapContextCompatibilityKey:@YES};
 AVAssetWriterInputPixelBufferAdaptor *adaptor=[AVAssetWriterInputPixelBufferAdaptor assetWriterInputPixelBufferAdaptorWithAssetWriterInput:input sourcePixelBufferAttributes:attrs];
 [writer addInput:input]; if (![writer startWriting]) { NSLog(@"%@",writer.error); return 4; }
 [writer startSessionAtSourceTime:kCMTimeZero];
 double first=[frames[0][@"time"] doubleValue];
 for (NSDictionary *frame in frames) { @autoreleasepool {
  int waits=0; while (!input.readyForMoreMediaData) { [NSThread sleepForTimeInterval:0.002]; if (++waits>15000 || writer.status==AVAssetWriterStatusFailed) { NSLog(@"%@",writer.error); return 5; } }
  NSImage *ns=[[NSImage alloc] initWithContentsOfFile:frame[@"path"]]; if (!ns) return 6;
  NSRect rect=NSMakeRect(0,0,ns.size.width,ns.size.height); CGImageRef cg=[ns CGImageForProposedRect:&rect context:nil hints:nil];
  CVPixelBufferRef buffer=NULL; CVPixelBufferCreate(kCFAllocatorDefault,1280,720,kCVPixelFormatType_32ARGB,(__bridge CFDictionaryRef)attrs,&buffer);
  CVPixelBufferLockBaseAddress(buffer,0); CGColorSpaceRef space=CGColorSpaceCreateDeviceRGB();
  CGContextRef ctx=CGBitmapContextCreate(CVPixelBufferGetBaseAddress(buffer),1280,720,8,CVPixelBufferGetBytesPerRow(buffer),space,kCGImageAlphaNoneSkipFirst);
  CGContextDrawImage(ctx,CGRectMake(0,0,1280,720),cg); CGContextRelease(ctx); CGColorSpaceRelease(space); CVPixelBufferUnlockBaseAddress(buffer,0);
  BOOL okay=[adaptor appendPixelBuffer:buffer withPresentationTime:CMTimeMakeWithSeconds([frame[@"time"] doubleValue]-first,600000)]; CVPixelBufferRelease(buffer);
  if (!okay) { NSLog(@"%@",writer.error); return 7; }
 }}
 [input markAsFinished]; dispatch_semaphore_t done=dispatch_semaphore_create(0); [writer finishWritingWithCompletionHandler:^{ dispatch_semaphore_signal(done); }]; dispatch_semaphore_wait(done,DISPATCH_TIME_FOREVER);
 if (writer.status!=AVAssetWriterStatusCompleted) { NSLog(@"%@",writer.error); return 8; }
 printf("Encoded %lu native timestamp samples\n",(unsigned long)frames.count); return 0;
}}
