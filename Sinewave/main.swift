//
//  main.swift
//  Sinewave
//
//  Created by Jonne Itkonen on 19.4.2017.
//  Copyright © 2017 None. All rights reserved.
//


// To play a bufferfull of samples using Apple's
// audio frameworks might look hard, but that's the spirit
// when your program is not the only program in the computer.
// Surely it could be easier, check JUCE or AudioKit3 for examples.

// But it's not too difficult a task to accomplish without
// extra libraries.  I'll describe this through, but be sure
// to take comments out and just "Read the source, Luke".


// We'll use definitions from AVFoundation.

import AVFoundation


// First we'll need an audio engine.  That's the object that runs the show.

var audioEngine = AVAudioEngine()


// Then we need to tell to the AVAudioEngine what kind data we'll feed to it.
// So, we create an audio format descriptor.  Standard format, what ever it
// is, is enough for us.  Just define sampling rate (44100 samples per second)
// and that we'll create a monophonic, one channel sound.

var audioFormat = AVAudioFormat(standardFormatWithSampleRate: 44100.0,
                                channels: 1)


// We'll need one second's worth of samples, or 1/samplerate samples.

let FL: AVAudioFrameCount = 44100

// An AVAudioPCMBuffer holds the data and some descriptive attributes of
// the data layout. As we're doing a monophonic sound, it'll be simple and easy.

var pcmBuffer = AVAudioPCMBuffer(pcmFormat: audioFormat,
                                 frameCapacity: AVAudioFrameCount(FL))


// NOTICE THE FOLLOWING LINE! Even though we set frameCapacity above,
// we _have_to_ set the frameLength here! Otherwise the frameLength
// is 0 and no sound is emitted. (Took me a while to realise this!)

pcmBuffer.frameLength = AVAudioFrameCount(FL)


// Then, for brevity's sake, we'll fish a reference to the float data
// inside the buffer.  One could use indexing operator ([]), but that
// 'pointee' sounds more Swifty.

let floatData = pcmBuffer.floatChannelData!.pointee // or floatChannelData![0]

// Let's now calculate the step between each sample.

let step = 2 * Float.pi/Float(FL)

// Fill buffer with float data.  We use here plain sinus from
// built-in function, which for real-time use would be slow,
// but is fast enough for us now.

for i in 0 ..< Int(FL) {

    // Here we won't go to eleven, three is the magic number.
    floatData[i] = 0.3 * sinf(440.0*Float(i)*step)

    // This will just do a simple enevelope for the waveform,
    // so it'll not 'snap' at the beginning and the end of playing.
    if i<4000 || i>40100 { floatData[i] *= 3.5*sinf(0.5*Float(i)*step) }

}

// Notice we filled FL = 44100 samples, or as that is the sampling
// rate, a full second's worth of data.


// Then we need a player for our sound.

var playerNode = AVAudioPlayerNode()

// Let's attach it to the audio engine...
audioEngine.attach(playerNode)

// ... and connect it to the mixer, which is connected to the output.
audioEngine.connect(playerNode, to: audioEngine.mainMixerNode,
                    format: pcmBuffer.format)


// Now we're ready to start the engine.

do {
    try audioEngine.start()

    // Starting to play sound would be faster with the call
    // to prepare, but we don't mind it here.
//  playerNode.prepare(withFrameCount: 1)
} catch let err as NSError {
    print("Oh, no!  \(err.code) \(err.domain)")
}

// So, start playing!
playerNode.play()

// But it does not play anything yet! We need to first
// give the player a buffer to play.  We want it to
// play as soon as possible (at:nil, ugly!) and to
// loop ( options: [.loops] ).

playerNode.scheduleBuffer(pcmBuffer, at:nil, options: [.loops]) {
    // Code here is excuted, when sound is played,
    // but our sound never ends, as it is looping.
}


// Then we just wait for three seconds and let the player
// and the audio engine to do their jobs.

sleep(3) // seconds

// After three seconds, we'll stop the engine, and player with it.

audioEngine.stop()



// Try taking the comments away, and you'll sure notice
// this is easier than it sounds:
//  - get a reference to the engine,
//  - describe the data format,
//  - make a buffer full of data,
//  - create a player,
//  - start the engine,
//  - schedule data (buffer) to be played,
//  - wait, and then
//  - stop the engine.

// Now making real-time synthesis is a bit more complex, I presume.
// I'll learn that later ;-)
