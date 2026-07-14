# TensorGrid
Repository for the open-source accuracy-aware parametrizable TPU made by team TensorGrid as a part of SSSC Chipathon 2026

# Description
As a part of this project, we aim to design and send to tapeout a Tensor Processing Unit (TPU) optimized for accuracy-aware inference by making arithmetic units that can switch between various datatypes.

Our TPU comprises of a MAC array of parametrizable tile size, which can be configured based on instruction to either perform matrix multiplication, or to calculate various activation functions essential for inference.

We plan to design our arithmetic units to switch between various datatypes- namely INT8, UINT8, INT4, UINT4, INT2 and UINT2. For area reasons, we had to scale it down from our original proposal of INT8, BF16 and FP32. INT8 and UINT8 provide the best accuracy with Quantization-aware training. The remaining datatypes are for experimental support, as in research, a lot of networks utilize these datatypes without true support. 

We plan to take our design through all stages of a tapeout - RTL, verification, GDS, tapeout, using open source tools for digital IC tapeout like verilator, openlane, etc. We plan to utlilze the GF180MCU node as our technology, as it's the standard for the competition.

Current Architecture: https://lucid.app/lucidchart/ba846edb-58b3-434c-b591-c7a798755b65/edit?viewport_loc=-1973%2C-327%2C5083%2C2793%2C0_0&invitationId=inv_b51fb640-8af1-4202-b410-1ec97dde80b9

Proposal and schematics PPT: https://docs.google.com/presentation/d/1a1IXXkrOlZ-j9vx_w0Zr3Ei6pWDGim3dke10zrRTNSw/edit?usp=sharing

Progress Tracker: https://calendar.google.com/calendar/u/1?cid=MjQxNzg5ZTk3YmMwNTY5Yzg1M2QwNzMxNmYxNTVkNjIyODYzYTFhNzUxOGJiZjVmMzA0MjZkNjE2ODI3ZmMyYUBncm91cC5jYWxlbmRhci5nb29nbGUuY29t

# Team Members:
| Name | Role | Discord ID | GitHub ID |
|---|---|---|---|
| Bharadwaaja K | TBD | bharadwaajak | KBdeGaulle1803 |
| Niharika Trivedi | TBD | Niharika Trivedi | ntrivedi07 |
| Kanwar Partap Pannu | TBD | bilstic_knight | Kanwarpartap-Pannu |
| Mridula SSV | TBD | mri4587 | ssvm2005 |
| Baliraja Nemade | TBD | Baliraja | Baliraja |
