import struct
import torch
import random
# import sys

def hex_to_fp32(hex_str):

    # Convert hex string to 32-bit int
    i = int(hex_str, 16)

    # Pack as unsigned int
    b = struct.pack('>I', i)

    # Unpack as float
    f = struct.unpack('>f', b)[0]

    return f

def fp32_to_hex(value):

    # Pack float
    b = struct.pack('>f', value)

    # Unpack as unsigned int
    i = struct.unpack('>I', b)[0]

    return f"{i:08x}"

device = torch.device('cuda' if torch.cuda.is_available() else 'cpu')
print(f"Using device: {device}")
# arguments = sys.argv
# mode = arguments[1]
# operand1 = arguments[2]
# operand2 = arguments[3]

# if mode == "INT32":
#     op1_int = int(operand1, 16)
#     op2_int = int(operand2, 16)
#     result = op1_int * op2_int
#     print(f"{result:08x}")
# elif mode == "FP32":
#     op1_float = hex_to_fp32(operand1)
#     op2_float = hex_to_fp32(operand2)
#     result_float = op1_float * op2_float
#     result_hex = fp32_to_hex(result_float)
#     print(result_hex)
# elif mode == "BF16":
#     op1_fp32 = hex_to_fp32(operand1)
#     op2_fp32 = hex_to_fp32(operand2)
#     op1_bf16 = torch.tensor(op1_fp32, dtype=torch.float32).to(torch.bfloat16).item()
#     op2_bf16 = torch.tensor(op2_fp32, dtype=torch.float32).to(torch.bfloat16).item()
#     result_bf16 = torch.tensor(op1_bf16, dtype=torch.bfloat16) * torch.tensor(op2_bf16, dtype=torch.bfloat16)
#     result_fp32 = result_bf16.to(torch.float32).item()
#     result_hex = fp32_to_hex(result_fp32)
#     print(result_hex)
# else:
#     print("Invalid mode. Use INT32, FP32, or BF16.")
wf = open("stimuli.txt", 'w')
for i in range(3000):
    expon = random.randint(-126, 127)
    mantissa = random.uniform(0.0, 2.0)
    final_number_1 = (2 ** expon) * mantissa
    final_number_1 = torch.tensor(final_number_1, dtype=torch.float32)
    expon = random.randint(-126, 127)
    mantissa = random.uniform(0.0, 2.0)
    final_number_2 = (2 ** expon) * mantissa
    final_number_2 = torch.tensor(final_number_2, dtype=torch.float32)
    golden_result = fp32_to_hex(final_number_1 * final_number_2)
    wf.write(f"{fp32_to_hex(final_number_1.item())} {fp32_to_hex(final_number_2.item())} {golden_result}\n")
for i in range(1000):
    expon = random.randint(-126, -121)
    mantissa = random.uniform(0.0, 2.0)
    final_number_1 = (2 ** expon) * mantissa
    final_number_1 = torch.tensor(final_number_1, dtype=torch.float32)
    expon = random.randint(122, 127)
    mantissa = random.uniform(0.0, 2.0)
    final_number_2 = (2 ** expon) * mantissa
    final_number_2 = torch.tensor(final_number_2, dtype=torch.float32)
    golden_result = fp32_to_hex(final_number_1 * final_number_2)
    wf.write(f"{fp32_to_hex(final_number_1.item())} {fp32_to_hex(final_number_2.item())} {golden_result}\n")
for i in range(1000):
    expon = random.randint(-126, 0)
    mantissa = random.uniform(0.0, 2.0)
    final_number_1 = (2 ** expon) * mantissa
    final_number_1 = torch.tensor(final_number_1, dtype=torch.float32)
    expon = random.randint(1, 127)
    mantissa = random.uniform(0.0, 2.0)
    final_number_2 = (2 ** expon) * mantissa
    final_number_2 = torch.tensor(final_number_2, dtype=torch.float32)
    golden_result = fp32_to_hex(final_number_1 * final_number_2)
    wf.write(f"{fp32_to_hex(final_number_1.item())} {fp32_to_hex(final_number_2.item())} {golden_result}\n")
for i in range(3000):
    expon = random.randint(-126, 127)
    mantissa = random.uniform(0.0, 2.0)
    final_number_1 = (2 ** expon) * mantissa
    final_number_1 = torch.tensor(final_number_1, dtype=torch.bfloat16)
    expon = random.randint(-126, 127)
    mantissa = random.uniform(0.0, 2.0)
    final_number_2 = (2 ** expon) * mantissa
    final_number_2 = torch.tensor(final_number_2, dtype=torch.bfloat16)
    golden_result = final_number_1 * final_number_2
    final_number_1 = final_number_1.to(torch.float32)
    final_number_2 = final_number_2.to(torch.float32)
    golden_result = golden_result.to(torch.float32)
    golden_result = fp32_to_hex(golden_result.item())
    wf.write(f"{fp32_to_hex(final_number_1.item())} {fp32_to_hex(final_number_2.item())} {golden_result}\n")
for i in range(1000):
    expon = random.randint(-126, -121)
    mantissa = random.uniform(0.0, 2.0)
    final_number_1 = (2 ** expon) * mantissa
    final_number_1 = torch.tensor(final_number_1, dtype=torch.bfloat16)
    expon = random.randint(122, 127)
    mantissa = random.uniform(0.0, 2.0)
    final_number_2 = (2 ** expon) * mantissa
    final_number_2 = torch.tensor(final_number_2, dtype=torch.bfloat16)
    golden_result = final_number_1 * final_number_2
    final_number_1 = final_number_1.to(torch.float32)
    final_number_2 = final_number_2.to(torch.float32)
    golden_result = golden_result.to(torch.float32)
    golden_result = fp32_to_hex(golden_result.item())
    wf.write(f"{fp32_to_hex(final_number_1.item())} {fp32_to_hex(final_number_2.item())} {golden_result}\n")
for i in range(1000):
    expon = random.randint(-126, 0)
    mantissa = random.uniform(0.0, 2.0)
    final_number_1 = (2 ** expon) * mantissa
    final_number_1 = torch.tensor(final_number_1, dtype=torch.bfloat16)
    expon = random.randint(1, 127)
    mantissa = random.uniform(0.0, 2.0)
    final_number_2 = (2 ** expon) * mantissa
    final_number_2 = torch.tensor(final_number_2, dtype=torch.bfloat16)
    golden_result = final_number_1 * final_number_2
    final_number_1 = final_number_1.to(torch.float32)
    final_number_2 = final_number_2.to(torch.float32)
    golden_result = golden_result.to(torch.float32)
    golden_result = fp32_to_hex(golden_result.item())
    wf.write(f"{fp32_to_hex(final_number_1.item())} {fp32_to_hex(final_number_2.item())} {golden_result}\n")
for i in range(32):
    for j in range(32):
        for k in range(10):
            if i:
                final_number_1 = random.randint(2**(i-1), 2**i - 1)
            else:
                final_number_1 = random.choice([0, 1])
            if j:
                final_number_2 = random.randint(2**(j-1), 2**j - 1)
            else:
                final_number_2 = random.choice([0, 1])
            final_number_1 *= random.choice([-1, 1])
            final_number_2 *= random.choice([-1, 1])
            golden_result = final_number_1 * final_number_2
            wf.write(f"{(final_number_1 & 0xFFFFFFFF) :08x} {(final_number_2 & 0xFFFFFFFF) :08x} {(golden_result & 0xFFFFFFFF) :08x}\n")
wf.close()