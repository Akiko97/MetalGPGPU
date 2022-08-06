#include <metal_stdlib>

kernel void sum(const device float* data [[ buffer(0) ]],
                   const device unsigned int& dataLength [[ buffer(1) ]],
                   device float* sums [[ buffer(2) ]],
                   const device unsigned int& elementsPerSum [[ buffer(3) ]],
                   const unsigned int tgPos [[ threadgroup_position_in_grid ]],
                   const unsigned int tPerTg [[ threads_per_threadgroup ]],
                   const unsigned int tPos [[ thread_position_in_threadgroup ]])
{
    unsigned int resultIndex = tgPos * tPerTg + tPos;
    unsigned int dataIndex = resultIndex * elementsPerSum;
    unsigned int endIndex = dataIndex + elementsPerSum < dataLength ? dataIndex + elementsPerSum : dataLength;
    for (; dataIndex < endIndex; dataIndex++)
        sums[resultIndex] += data[dataIndex];
}
