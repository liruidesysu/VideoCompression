# VideoCompression
实现基本视频压缩编码，包括I帧帧内压缩和P帧帧间压缩。
I帧帧内压缩实现RGB和YUV颜色空间互相转换，离散余弦变换(DCT for Discrete Cosine Transform)和反离散余弦变换，量化和和反量化，Huffman编码和解码；
P帧帧间压缩实现运动估计和运动补偿。
