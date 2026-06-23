import struct
import torch
import random

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
wf = open("stimuli_adder.txt", 'w')
for _ in range(3000):
    expon = random.randint(-126, 127)
    mantissa = random.uniform(0.0, 2.0)
    final_number_1 = (2 ** expon) * mantissa
    final_number_1 *= random.choice([-1, 1])
    final_number_1 = torch.tensor(final_number_1, dtype=torch.float32)
    expon = random.randint(-126, 127)
    mantissa = random.uniform(0.0, 2.0)
    final_number_2 = (2 ** expon) * mantissa
    final_number_2 *= random.choice([-1, 1])
    final_number_2 = torch.tensor(final_number_2, dtype=torch.float32)
    golden_result = fp32_to_hex(final_number_1 + final_number_2)
    wf.write(f"{fp32_to_hex(final_number_1.item())} {fp32_to_hex(final_number_2.item())} {golden_result}\n")
for _ in range(3000):
    expon = random.randint(-126, 127)
    mantissa = random.uniform(0.0, 2.0)
    final_number_1 = (2 ** expon) * mantissa
    final_number_1 *= random.choice([-1, 1])
    final_number_1 = torch.tensor(final_number_1, dtype=torch.float32)
    expon += random.randint(-24, 24)
    mantissa = random.uniform(0.0, 2.0)
    final_number_2 = (2 ** expon) * mantissa
    final_number_2 *= random.choice([-1, 1])
    final_number_2 = torch.tensor(final_number_2, dtype=torch.float32)
    golden_result = fp32_to_hex(final_number_1 + final_number_2)
    wf.write(f"{fp32_to_hex(final_number_1.item())} {fp32_to_hex(final_number_2.item())} {golden_result}\n")
for _ in range(1500):
    expon = random.randint(-126, -121)
    mantissa = random.uniform(0.0, 2.0)
    final_number_1 = (2 ** expon) * mantissa
    final_number_1 *= random.choice([-1, 1])
    final_number_1 = torch.tensor(final_number_1, dtype=torch.float32)
    expon = random.randint(-126, -121)
    mantissa = random.uniform(0.0, 2.0)
    final_number_2 = (2 ** expon) * mantissa
    final_number_2 *= random.choice([-1, 1])
    final_number_2 = torch.tensor(final_number_2, dtype=torch.float32)
    golden_result = fp32_to_hex(final_number_1 + final_number_2)
    wf.write(f"{fp32_to_hex(final_number_1.item())} {fp32_to_hex(final_number_2.item())} {golden_result}\n")
for _ in range(1500):
    expon = random.randint(122, 127)
    mantissa = random.uniform(0.0, 2.0)
    final_number_1 = (2 ** expon) * mantissa
    final_number_1 *= random.choice([-1, 1])
    final_number_1 = torch.tensor(final_number_1, dtype=torch.float32)
    expon = random.randint(122, 127)
    mantissa = random.uniform(0.0, 2.0)
    final_number_2 = (2 ** expon) * mantissa
    final_number_2 *= random.choice([-1, 1])
    final_number_2 = torch.tensor(final_number_2, dtype=torch.float32)
    golden_result = fp32_to_hex(final_number_1 + final_number_2)
    wf.write(f"{fp32_to_hex(final_number_1.item())} {fp32_to_hex(final_number_2.item())} {golden_result}\n")
for _ in range(500):
    expon = random.randint(122, 127)
    mantissa = 0.0
    final_number_1 = (2 ** expon) * mantissa
    final_number_1 *= random.choice([-1, 1])
    final_number_1 = torch.tensor(final_number_1, dtype=torch.float32)
    expon = random.randint(122, 127)
    mantissa = random.uniform(0.0, 2.0)
    final_number_2 = (2 ** expon) * mantissa
    final_number_2 *= random.choice([-1, 1])
    final_number_2 = torch.tensor(final_number_2, dtype=torch.float32)
    golden_result = fp32_to_hex(final_number_1 + final_number_2)
    wf.write(f"{fp32_to_hex(final_number_1.item())} {fp32_to_hex(final_number_2.item())} {golden_result}\n")
for _ in range(500):
    expon = random.randint(122, 127)
    mantissa = random.uniform(0.0, 2.0)
    final_number_1 = (2 ** expon) * mantissa
    final_number_1 *= random.choice([-1, 1])
    final_number_1 = torch.tensor(final_number_1, dtype=torch.float32)
    expon = random.randint(122, 127)
    mantissa = 0.0
    final_number_2 = (2 ** expon) * mantissa
    final_number_2 *= random.choice([-1, 1])
    final_number_2 = torch.tensor(final_number_2, dtype=torch.float32)
    golden_result = fp32_to_hex(final_number_1 + final_number_2)
    wf.write(f"{fp32_to_hex(final_number_1.item())} {fp32_to_hex(final_number_2.item())} {golden_result}\n")
for _ in range(5000):
    sign = random.randint(0,1)
    exp = random.randint(0, 255)
    mant_1 = random.getrandbits(23)
    mant_2 = random.getrandbits(23)
    same_bits = random.randint(1, 23)
    for i in range(same_bits):
        bit = (mant_1 >> (22 - i)) & 1
        if bit:
            mant_2 |= (1 << (22 - i))
        else:
            mant_2 &= ~(1 << (22 - i))
    num_1 = ((sign << 31) | (exp << 23) | mant_1) & 0xFFFFFFFF
    num_2 = (((~sign) << 31) | (exp << 23) | mant_2) & 0xFFFFFFFF
    final_number_1 = torch.tensor(hex_to_fp32(f"{num_1:08x}"), dtype=torch.float32)
    final_number_2 = torch.tensor(hex_to_fp32(f"{num_2:08x}"), dtype=torch.float32)
    golden_result = fp32_to_hex(final_number_1 + final_number_2)
    wf.write(f"{fp32_to_hex(final_number_1.item())} {fp32_to_hex(final_number_2.item())} {golden_result}\n")
for _ in range(1000):
    sign = random.randint(0,1)
    exp = 0
    mant_1 = random.getrandbits(23)
    mant_2 = random.getrandbits(23)
    same_bits = random.randint(1, 23)
    for i in range(same_bits):
        bit = (mant_1 >> (22 - i)) & 1
        if bit:
            mant_2 |= (1 << (22 - i))
        else:
            mant_2 &= ~(1 << (22 - i))
    num_1 = ((sign << 31) | (exp << 23) | mant_1) & 0xFFFFFFFF
    num_2 = (((~sign) << 31) | (exp << 23) | mant_2) & 0xFFFFFFFF
    final_number_1 = torch.tensor(hex_to_fp32(f"{num_1:08x}"), dtype=torch.float32)
    final_number_2 = torch.tensor(hex_to_fp32(f"{num_2:08x}"), dtype=torch.float32)
    golden_result = fp32_to_hex(final_number_1 + final_number_2)
    wf.write(f"{fp32_to_hex(final_number_1.item())} {fp32_to_hex(final_number_2.item())} {golden_result}\n")
for i in range(1000):
    sign = random.randint(0,1)
    exp_1 = random.randint(0, 255)
    exp_2 = exp_1 - (i % 28)
    exp_2 = max(exp_2, 0)
    mant_1 = 0x7fffff
    mant_2 = 0x000000
    num_1 = ((sign << 31) | (exp_1 << 23) | mant_1) & 0xFFFFFFFF
    num_2 = ((sign << 31) | (exp_2 << 23) | mant_2) & 0xFFFFFFFF
    final_number_1 = torch.tensor(hex_to_fp32(f"{num_1:08x}"), dtype=torch.float32)
    final_number_2 = torch.tensor(hex_to_fp32(f"{num_2:08x}"), dtype=torch.float32)
    golden_result = fp32_to_hex(final_number_1 + final_number_2)
    wf.write(f"{fp32_to_hex(final_number_1.item())} {fp32_to_hex(final_number_2.item())} {golden_result}\n")
for i in range(1500):
    sign = random.randint(0,1)
    exp_1 = random.randint(0, 255)
    exp_2 = exp_1 - (i % 28)
    exp_2 = max(exp_2, 0)
    mant_1 = 0x7fffff
    mant_2 = 0x000000
    num_1 = ((sign << 31) | (exp_1 << 23) | mant_1) & 0xFFFFFFFF
    num_2 = (((~sign) << 31) | (exp_2 << 23) | mant_2) & 0xFFFFFFFF
    final_number_1 = torch.tensor(hex_to_fp32(f"{num_1:08x}"), dtype=torch.float32)
    final_number_2 = torch.tensor(hex_to_fp32(f"{num_2:08x}"), dtype=torch.float32)
    golden_result = fp32_to_hex(final_number_1 + final_number_2)
    wf.write(f"{fp32_to_hex(final_number_1.item())} {fp32_to_hex(final_number_2.item())} {golden_result}\n")
for i in range(1500):
    sign = random.randint(0,1)
    exp_1 = random.randint(0, 255)
    exp_2 = exp_1 - 1 - (i % 28)
    exp_2 = max(exp_2, 0)
    mant_1 = 0x000000
    mant_2 = 0x7fffff
    num_1 = ((sign << 31) | (exp_1 << 23) | mant_1) & 0xFFFFFFFF
    num_2 = (((~sign) << 31) | (exp_2 << 23) | mant_2) & 0xFFFFFFFF
    final_number_1 = torch.tensor(hex_to_fp32(f"{num_1:08x}"), dtype=torch.float32)
    final_number_2 = torch.tensor(hex_to_fp32(f"{num_2:08x}"), dtype=torch.float32)
    golden_result = fp32_to_hex(final_number_1 + final_number_2)
    wf.write(f"{fp32_to_hex(final_number_1.item())} {fp32_to_hex(final_number_2.item())} {golden_result}\n")

for _ in range(3000):
    expon = random.randint(-126, 127)
    mantissa = random.uniform(0.0, 2.0)
    final_number_1 = (2 ** expon) * mantissa
    final_number_1 *= random.choice([-1, 1])
    final_number_1 = torch.tensor(final_number_1, dtype=torch.bfloat16)
    expon = random.randint(-126, 127)
    mantissa = random.uniform(0.0, 2.0)
    final_number_2 = (2 ** expon) * mantissa
    final_number_2 *= random.choice([-1, 1])
    final_number_2 = torch.tensor(final_number_2, dtype=torch.bfloat16)
    golden_result = fp32_to_hex(final_number_1 + final_number_2)
    wf.write(f"{fp32_to_hex(final_number_1.item())} {fp32_to_hex(final_number_2.item())} {golden_result}\n")
for _ in range(3000):
    expon = random.randint(-126, 127)
    mantissa = random.uniform(0.0, 2.0)
    final_number_1 = (2 ** expon) * mantissa
    final_number_1 *= random.choice([-1, 1])
    final_number_1 = torch.tensor(final_number_1, dtype=torch.bfloat16)
    expon += random.randint(-24, 24)
    mantissa = random.uniform(0.0, 2.0)
    final_number_2 = (2 ** expon) * mantissa
    final_number_2 *= random.choice([-1, 1])
    final_number_2 = torch.tensor(final_number_2, dtype=torch.bfloat16)
    golden_result = fp32_to_hex(final_number_1 + final_number_2)
    wf.write(f"{fp32_to_hex(final_number_1.item())} {fp32_to_hex(final_number_2.item())} {golden_result}\n")
for _ in range(1500):
    expon = random.randint(-126, -121)
    mantissa = random.uniform(0.0, 2.0)
    final_number_1 = (2 ** expon) * mantissa
    final_number_1 *= random.choice([-1, 1])
    final_number_1 = torch.tensor(final_number_1, dtype=torch.bfloat16)
    expon = random.randint(-126, -121)
    mantissa = random.uniform(0.0, 2.0)
    final_number_2 = (2 ** expon) * mantissa
    final_number_2 *= random.choice([-1, 1])
    final_number_2 = torch.tensor(final_number_2, dtype=torch.bfloat16)
    golden_result = fp32_to_hex(final_number_1 + final_number_2)
    wf.write(f"{fp32_to_hex(final_number_1.item())} {fp32_to_hex(final_number_2.item())} {golden_result}\n")
for _ in range(1500):
    expon = random.randint(122, 127)
    mantissa = random.uniform(0.0, 2.0)
    final_number_1 = (2 ** expon) * mantissa
    final_number_1 *= random.choice([-1, 1])
    final_number_1 = torch.tensor(final_number_1, dtype=torch.bfloat16)
    expon = random.randint(122, 127)
    mantissa = random.uniform(0.0, 2.0)
    final_number_2 = (2 ** expon) * mantissa
    final_number_2 *= random.choice([-1, 1])
    final_number_2 = torch.tensor(final_number_2, dtype=torch.bfloat16)
    golden_result = fp32_to_hex(final_number_1 + final_number_2)
    wf.write(f"{fp32_to_hex(final_number_1.item())} {fp32_to_hex(final_number_2.item())} {golden_result}\n")
for _ in range(500):
    expon = random.randint(122, 127)
    mantissa = 0.0
    final_number_1 = (2 ** expon) * mantissa
    final_number_1 *= random.choice([-1, 1])
    final_number_1 = torch.tensor(final_number_1, dtype=torch.bfloat16)
    expon = random.randint(122, 127)
    mantissa = random.uniform(0.0, 2.0)
    final_number_2 = (2 ** expon) * mantissa
    final_number_2 *= random.choice([-1, 1])
    final_number_2 = torch.tensor(final_number_2, dtype=torch.bfloat16)
    golden_result = fp32_to_hex(final_number_1 + final_number_2)
    wf.write(f"{fp32_to_hex(final_number_1.item())} {fp32_to_hex(final_number_2.item())} {golden_result}\n")
for _ in range(500):
    expon = random.randint(122, 127)
    mantissa = random.uniform(0.0, 2.0)
    final_number_1 = (2 ** expon) * mantissa
    final_number_1 *= random.choice([-1, 1])
    final_number_1 = torch.tensor(final_number_1, dtype=torch.bfloat16)
    expon = random.randint(122, 127)
    mantissa = 0.0
    final_number_2 = (2 ** expon) * mantissa
    final_number_2 *= random.choice([-1, 1])
    final_number_2 = torch.tensor(final_number_2, dtype=torch.bfloat16)
    golden_result = fp32_to_hex(final_number_1 + final_number_2)
    wf.write(f"{fp32_to_hex(final_number_1.item())} {fp32_to_hex(final_number_2.item())} {golden_result}\n")
for _ in range(5000):
    sign = random.randint(0,1)
    exp = random.randint(0, 255)
    mant_1 = random.getrandbits(7) << 16
    mant_2 = random.getrandbits(7) << 16
    same_bits = random.randint(1, 7)
    for i in range(same_bits):
        bit = (mant_1 >> (22 - i)) & 1
        if bit:
            mant_2 |= (1 << (22 - i))
        else:
            mant_2 &= ~(1 << (22 - i))
    num_1 = ((sign << 31) | (exp << 23) | mant_1) & 0xFFFFFFFF
    num_2 = (((~sign) << 31) | (exp << 23) | mant_2) & 0xFFFFFFFF
    final_number_1 = torch.tensor(hex_to_fp32(f"{num_1:08x}"), dtype=torch.bfloat16)
    final_number_2 = torch.tensor(hex_to_fp32(f"{num_2:08x}"), dtype=torch.bfloat16)
    golden_result = fp32_to_hex(final_number_1 + final_number_2)
    wf.write(f"{fp32_to_hex(final_number_1.item())} {fp32_to_hex(final_number_2.item())} {golden_result}\n")
for _ in range(1000):
    sign = random.randint(0,1)
    exp = 0
    mant_1 = random.getrandbits(7) << 16
    mant_2 = random.getrandbits(7) << 16
    same_bits = random.randint(1, 7)
    for i in range(same_bits):
        bit = (mant_1 >> (22 - i)) & 1
        if bit:
            mant_2 |= (1 << (22 - i))
        else:
            mant_2 &= ~(1 << (22 - i))
    num_1 = ((sign << 31) | (exp << 23) | mant_1) & 0xFFFFFFFF
    num_2 = (((~sign) << 31) | (exp << 23) | mant_2) & 0xFFFFFFFF
    final_number_1 = torch.tensor(hex_to_fp32(f"{num_1:08x}"), dtype=torch.bfloat16)
    final_number_2 = torch.tensor(hex_to_fp32(f"{num_2:08x}"), dtype=torch.bfloat16)
    golden_result = fp32_to_hex(final_number_1 + final_number_2)
    wf.write(f"{fp32_to_hex(final_number_1.item())} {fp32_to_hex(final_number_2.item())} {golden_result}\n")
for i in range(1000):
    sign = random.randint(0,1)
    exp_1 = random.randint(0, 255)
    exp_2 = exp_1 - (i % 10)
    exp_2 = max(exp_2, 0)
    mant_1 = 0x7f0000
    mant_2 = 0x000000
    num_1 = ((sign << 31) | (exp_1 << 23) | mant_1) & 0xFFFFFFFF
    num_2 = ((sign << 31) | (exp_2 << 23) | mant_2) & 0xFFFFFFFF
    final_number_1 = torch.tensor(hex_to_fp32(f"{num_1:08x}"), dtype=torch.bfloat16)
    final_number_2 = torch.tensor(hex_to_fp32(f"{num_2:08x}"), dtype=torch.bfloat16)
    golden_result = fp32_to_hex(final_number_1 + final_number_2)
    wf.write(f"{fp32_to_hex(final_number_1.item())} {fp32_to_hex(final_number_2.item())} {golden_result}\n")
for i in range(1500):
    sign = random.randint(0,1)
    exp_1 = random.randint(0, 255)
    exp_2 = exp_1 - (i % 10)
    exp_2 = max(exp_2, 0)
    mant_1 = 0x7f0000
    mant_2 = 0x000000
    num_1 = ((sign << 31) | (exp_1 << 23) | mant_1) & 0xFFFFFFFF
    num_2 = (((~sign) << 31) | (exp_2 << 23) | mant_2) & 0xFFFFFFFF
    final_number_1 = torch.tensor(hex_to_fp32(f"{num_1:08x}"), dtype=torch.bfloat16)
    final_number_2 = torch.tensor(hex_to_fp32(f"{num_2:08x}"), dtype=torch.bfloat16)
    golden_result = fp32_to_hex(final_number_1 + final_number_2)
    wf.write(f"{fp32_to_hex(final_number_1.item())} {fp32_to_hex(final_number_2.item())} {golden_result}\n")
for i in range(1500):
    sign = random.randint(0,1)
    exp_1 = random.randint(0, 255)
    exp_2 = exp_1 - 1 - (i % 10)
    exp_2 = max(exp_2, 0)
    mant_1 = 0x000000
    mant_2 = 0x7f0000
    num_1 = ((sign << 31) | (exp_1 << 23) | mant_1) & 0xFFFFFFFF
    num_2 = (((~sign) << 31) | (exp_2 << 23) | mant_2) & 0xFFFFFFFF
    final_number_1 = torch.tensor(hex_to_fp32(f"{num_1:08x}"), dtype=torch.bfloat16)
    final_number_2 = torch.tensor(hex_to_fp32(f"{num_2:08x}"), dtype=torch.bfloat16)
    golden_result = fp32_to_hex(final_number_1 + final_number_2)
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
            golden_result = final_number_1 + final_number_2
            wf.write(f"{(final_number_1 & 0xFFFFFFFF) :08x} {(final_number_2 & 0xFFFFFFFF) :08x} {(golden_result & 0xFFFFFFFF) :08x}\n")
wf.close()