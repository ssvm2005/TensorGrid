# TensorGrid
Repository for the open-source accuracy-aware parametrizable TPU made by team TensorGrid as a part of SSSC Chipathon 2026

# Description
As a part of this project, we aim to design and send to tapeout a Tensor Processing Unit (TPU) optimized for accuracy-aware inference by making arithmetic units that can switch between various datatypes.

Our TPU comprises of a MAC array of parametrizable tile size, which can be configured based on instruction to either perform matrix multiplication, or to calculate various activation functions essential for inference.

We plan to design our arithmetic units to switch between various datatypes- namely FP32, BF16, and INT32. This enables accuracy-aware inference, so that stages less critical for accuracy can utilize integer arithmetic for improved efficiency.

Detailed specifications (will be updated as the project progresses): https://docs.google.com/document/d/1Bf-AeR-BTfjls6UAFFtR-kkuU665zslCVYjlpTkNTXs/edit?usp=drivesdk

Current Architecture: https://lucid.app/lucidchart/ba846edb-58b3-434c-b591-c7a798755b65/edit?viewport_loc=-1973%2C-327%2C5083%2C2793%2C0_0&invitationId=inv_b51fb640-8af1-4202-b410-1ec97dde80b9

# Team Members:

| Name | Role | Email | GitHub |
|---|---|---|---|
| TBD | TBD | TBD | TBD |
