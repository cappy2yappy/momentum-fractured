// macOS-only packaging helper. The game and authoring tools need no Swift runtime.
// Encodes actual wall-clock post-draw timestamps; never retimes playback to fixed FPS.
import Foundation
import AVFoundation
import AppKit
let args = CommandLine.arguments
if args.count != 3 { fatalError("usage: swift encode_capture.swift timing.json playback.mp4") }
let raw = try Data(contentsOf: URL(fileURLWithPath: args[1]))
let metadata = try JSONSerialization.jsonObject(with: raw) as! [String:Any]
let frames = metadata["frames"] as! [[String:Any]]
let output = URL(fileURLWithPath: args[2])
if FileManager.default.fileExists(atPath: output.path) { try FileManager.default.removeItem(at: output) }
let writer = try AVAssetWriter(outputURL: output, fileType: .mp4)
let input = AVAssetWriterInput(mediaType: .video, outputSettings: [AVVideoCodecKey: AVVideoCodecType.h264, AVVideoWidthKey: 1280, AVVideoHeightKey: 720, AVVideoCompressionPropertiesKey:[AVVideoAverageBitRateKey:2500000]])
let attributes: [String:Any] = [kCVPixelBufferPixelFormatTypeKey as String:kCVPixelFormatType_32ARGB, kCVPixelBufferWidthKey as String:1280, kCVPixelBufferHeightKey as String:720, kCVPixelBufferCGImageCompatibilityKey as String:true, kCVPixelBufferCGBitmapContextCompatibilityKey as String:true]
let adaptor = AVAssetWriterInputPixelBufferAdaptor(assetWriterInput:input, sourcePixelBufferAttributes:attributes)
writer.add(input)
writer.startWriting()
writer.startSession(atSourceTime:.zero)
let firstTime = frames.first!["time"] as! Double
for frame in frames {
    while !input.isReadyForMoreMediaData { Thread.sleep(forTimeInterval:0.002) }
    autoreleasepool {
        let path = frame["path"] as! String
        let nsImage = NSImage(contentsOfFile:path)!
        var bounds = NSRect(origin:.zero,size:nsImage.size)
        let image = nsImage.cgImage(forProposedRect:&bounds,context:nil,hints:nil)!
        var pixel: CVPixelBuffer?
        CVPixelBufferCreate(kCFAllocatorDefault,1280,720,kCVPixelFormatType_32ARGB,attributes as CFDictionary,&pixel)
        let buffer = pixel!
        CVPixelBufferLockBaseAddress(buffer,[])
        let context = CGContext(data:CVPixelBufferGetBaseAddress(buffer),width:1280,height:720,bitsPerComponent:8,bytesPerRow:CVPixelBufferGetBytesPerRow(buffer),space:CGColorSpaceCreateDeviceRGB(),bitmapInfo:CGImageAlphaInfo.noneSkipFirst.rawValue)!
        context.draw(image,in:CGRect(x:0,y:0,width:1280,height:720))
        CVPixelBufferUnlockBaseAddress(buffer,[])
        let time = CMTime(seconds:(frame["time"] as! Double)-firstTime,preferredTimescale:600000)
        if !adaptor.append(buffer,withPresentationTime:time) { fatalError("append failed: \(String(describing:writer.error))") }
    }
}
input.markAsFinished()
let done = DispatchSemaphore(value:0)
writer.finishWriting { done.signal() }
done.wait()
if writer.status != .completed { fatalError("writer failed: \(String(describing:writer.error))") }
print("Encoded \(frames.count) wall-clock samples; \(writer.outputURL.path)")
