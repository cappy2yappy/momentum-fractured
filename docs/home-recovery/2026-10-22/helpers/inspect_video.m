#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
int main(int argc,const char **argv){@autoreleasepool{for(int i=1;i<argc;i++){AVURLAsset*a=[AVURLAsset URLAssetWithURL:[NSURL fileURLWithPath:@(argv[i])] options:nil];NSArray*t=[a tracksWithMediaType:AVMediaTypeVideo];if(t.count!=1)return 1;AVAssetTrack*v=t[0];printf("%s duration=%.6f size=%.0fx%.0f\n",argv[i],CMTimeGetSeconds(a.duration),v.naturalSize.width,v.naturalSize.height);}return 0;}}
