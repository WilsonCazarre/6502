WIDTH = 8

with open("a.out", "rb") as in_file:
    data = bytearray(in_file.read())


with open("a.mif", "w") as out_file:
    code = [f"{address:04x}:{value:02x};\n" for address, value in enumerate(data)]
    out_file.writelines(
        [
            f"DEPTH={len(code)};\n",
            f"WIDTH={WIDTH};\n",
            "ADDRESS_RADIX = HEX;\n",
            "DATA_RADIX = HEX;\n",
            "CONTENT\n",
            "BEGIN\n",
        ]
    )
    out_file.writelines(code)
    out_file.writelines(["END"])
