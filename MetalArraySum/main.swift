import Metal

typealias DataType = CFloat

var timer = Timer()

let count = 10_000_000
let elementsPerSum = 10_000
var dataCount = CUnsignedInt(count)
var elementsPerSumC = CUnsignedInt(elementsPerSum)

let resultsCount = (count + elementsPerSum - 1) / elementsPerSum

let device = MTLCreateSystemDefaultDevice()!
let sumfunc = try! device.makeLibrary(filepath: "./ArrayAddMetalLib.metallib").makeFunction(name: "sum")!
let pipeline = try! device.makeComputePipelineState(function:sumfunc)

var data = (0..<count).map{ _ in DataType(1.5) }

let dataBuffer = device.makeBuffer(bytes:&data, length: MemoryLayout<DataType>.size * count, options: [])
let resultsBuffer = device.makeBuffer(length:MemoryLayout<DataType>.size * resultsCount, options: [])

let results = UnsafeBufferPointer<DataType>(start: resultsBuffer!.contents().assumingMemoryBound(to:DataType.self), count: resultsCount)

let threadgroupsPerGrid = MTLSize(width: (resultsCount + pipeline.threadExecutionWidth - 1) / pipeline.threadExecutionWidth, height: 1, depth: 1)
let threadsPerThreadgroup = MTLSize(width: pipeline.threadExecutionWidth, height: 1, depth: 1)
let queue = device.makeCommandQueue()
let cmds = queue!.makeCommandBuffer()
let encoder = cmds!.makeComputeCommandEncoder()!
encoder.setComputePipelineState(pipeline)
encoder.setBuffer(dataBuffer, offset: 0, index: 0)
encoder.setBytes(&dataCount, length: MemoryLayout<CUnsignedInt>.size, index: 1)
encoder.setBuffer(resultsBuffer, offset: 0, index: 2)
encoder.setBytes(&elementsPerSumC, length: MemoryLayout<CUnsignedInt>.size, index: 3)
encoder.dispatchThreadgroups(threadgroupsPerGrid, threadsPerThreadgroup: threadsPerThreadgroup)
encoder.endEncoding()

var result: DataType = 0

timer.start()
cmds!.commit()
cmds!.waitUntilCompleted()
for elem in results {
    result += elem
}
timer.end()
print(result, timer.getString(), separator: " / ")

result = 0

timer.start()
data.withUnsafeBufferPointer { buffer in
    for elem in buffer {
        result += elem
    }
}
timer.end()
print(result, timer.getString(), separator: " / ")
