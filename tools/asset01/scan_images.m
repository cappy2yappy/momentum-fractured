#import <Foundation/Foundation.h>
#import <ImageIO/ImageIO.h>
#import <CoreGraphics/CoreGraphics.h>
int main(int argc,const char **argv){@autoreleasepool{
 if(argc!=3)return 2; NSString*root=@(argv[1]); NSError*error=nil;
 NSDictionary*inventory=[NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfFile:@(argv[2])] options:NSJSONReadingMutableContainers error:&error];
 for(NSMutableDictionary*pack in inventory[@"packs"]){
  for(NSMutableDictionary*entry in pack[@"entries"]){@autoreleasepool{
   NSString*ext=entry[@"extension"]; if(![ext isEqual:@".png"]&&![ext isEqual:@".jpg"])continue;
   NSString*path=[[root stringByAppendingPathComponent:pack[@"slug"]] stringByAppendingPathComponent:entry[@"path"]];
   CGImageSourceRef source=CGImageSourceCreateWithURL((__bridge CFURLRef)[NSURL fileURLWithPath:path],NULL);
   CGImageRef image=source?CGImageSourceCreateImageAtIndex(source,0,NULL):NULL;
   if(!image){entry[@"decode_error"]=@YES;if(source)CFRelease(source);continue;}
   size_t w=CGImageGetWidth(image),h=CGImageGetHeight(image); size_t len=w*h*4;
   unsigned char*data=calloc(1,len);CGColorSpaceRef space=CGColorSpaceCreateDeviceRGB();
   CGContextRef context=CGBitmapContextCreate(data,w,h,8,w*4,space,kCGImageAlphaPremultipliedLast|kCGBitmapByteOrder32Big);
   CGContextDrawImage(context,CGRectMake(0,0,w,h),image);
   unsigned long transparent=0,opaque=0,partial=0;size_t minx=w,miny=h,maxx=0,maxy=0;
   for(size_t y=0;y<h;y++)for(size_t x=0;x<w;x++){unsigned char a=data[(y*w+x)*4+3];if(!a)transparent++;else{if(a==255)opaque++;else partial++;minx=MIN(minx,x);miny=MIN(miny,y);maxx=MAX(maxx,x);maxy=MAX(maxy,y);}}
   entry[@"width"]=@(w);entry[@"height"]=@(h);entry[@"decoded_rgba_bytes"]=@(len);
   entry[@"transparent_pixels"]=@(transparent);entry[@"opaque_pixels"]=@(opaque);entry[@"partial_alpha_pixels"]=@(partial);
   entry[@"visible_bbox"]=minx==w?@[@0,@0,@0,@0]:@[@(minx),@(miny),@(maxx-minx+1),@(maxy-miny+1)];
   entry[@"true_transparency"]=@(transparent>0);entry[@"empty"]=@(minx==w);
   if([ext isEqual:@".png"] && ([pack[@"slug"] isEqual:@"mossy-assets"] || [pack[@"slug"] isEqual:@"caveassetsmaaot"])) {
    NSMutableArray *regions=[NSMutableArray array]; unsigned char *seen=calloc(w*h,1); uint32_t *queue=malloc(w*h*sizeof(uint32_t));
    for(size_t seed=0;seed<w*h;seed++){if(seen[seed]||data[seed*4+3]<=8)continue;
     size_t first=0,last=0,count=0,x0=w,y0=h,x1=0,y1=0;seen[seed]=1;queue[last++]=(uint32_t)seed;
     while(first<last){uint32_t pos=queue[first++];size_t x=pos%w,y=pos/w;count++;x0=MIN(x0,x);y0=MIN(y0,y);x1=MAX(x1,x);y1=MAX(y1,y);
      for(int dy=-1;dy<=1;dy++)for(int dx=-1;dx<=1;dx++){long nx=(long)x+dx,ny=(long)y+dy;if(nx<0||ny<0||nx>=w||ny>=h)continue;size_t n=ny*w+nx;if(!seen[n]&&data[n*4+3]>8){seen[n]=1;queue[last++]=(uint32_t)n;}}
     }
     if(count>=64)[regions addObject:@[@(x0),@(y0),@(x1-x0+1),@(y1-y0+1)]];
    }
    free(queue);free(seen);entry[@"candidate_component_regions"]=regions;entry[@"component_threshold_alpha"]=@8;entry[@"component_min_pixels"]=@64;
    if([entry[@"path"] hasSuffix:@"Mossy - TileSet.png"]&&w==3584&&h==3584){NSMutableArray*tiles=[NSMutableArray array];for(int y=0;y<7;y++)for(int x=0;x<7;x++)[tiles addObject:@[@(x*512),@(y*512),@512,@512]];entry[@"authored_grid_regions"]=tiles;}
   }
   CGContextRelease(context);CGColorSpaceRelease(space);free(data);CGImageRelease(image);CFRelease(source);
  }}
  fprintf(stderr,"Scanned %s\n",[pack[@"name"] UTF8String]);
 }
 NSData*out=[NSJSONSerialization dataWithJSONObject:inventory options:NSJSONWritingPrettyPrinted|NSJSONWritingSortedKeys error:&error];[out writeToFile:@(argv[2]) atomically:YES];return out?0:3;
}}
