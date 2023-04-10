#!/usr/bin/env python3

import os
import json
import subprocess

tests = ["ADDA.l", "ADDA.w"]
initial = ""
final = ""
prefetch = ""
iram = ""
fram = ""
count = 0

def sp(data):
    if (data['sr'] & 0x2000) == 0:
        return str(data['usp'])
    else:
        return str(data['ssp'])

def check(data):
    global initial, final, prefetch, iram, fram, count
    print("Test name " + data['name'])
    count += 1
    x = "  {"
    for i in ["d0", "d1", "d2", "d3", "d4", "d5",  "d6",  "d7",
              "a0", "a1", "a2", "a3", "a4", "a5",  "a6",  "a7", "sr", "pc"]:
        if i == "a7":
            initial += x + sp(data['initial'])
        else:
            initial += x + str(data['initial'][i])
        x = ", "
    initial += " },\n"
    x = "  {"
    for i in ["d0", "d1", "d2", "d3", "d4", "d5",  "d6",  "d7",
              "a0", "a1", "a2", "a3", "a4", "a5",  "a6",  "a7", "sr", "pc"]:
        if i == "a7":
            final += x + sp(data['final'])
        else:
            final += x + str(data['final'][i])
        x = ", "
    final += " },\n"
    prefetch += "  { %d, %d },\n" % (data['initial']['prefetch'][0],
                                     data['initial']['prefetch'][1])
    iram += "  { %d" % len(data['initial']['ram'])
    for i in data['initial']['ram']:
        iram += ", %d, %d" % (i[0], i[1])
    iram += " },\n"
    fram += "  { %d" % len(data['final']['ram'])
    for i in data['final']['ram']:
        fram += ", %d, %d" % (i[0], i[1])
    fram += " },\n"

if __name__ == "__main__":
    for i in tests:
        r, w = os.pipe()
        p = subprocess.run(("zcat", "./ProcessorTests/680x0/68000/v1/" + i + ".json.gz"), stdout=subprocess.PIPE)
        for j in json.loads(p.stdout.decode("ascii")):
            check(j)
        f = open("check.c", "w")
        print("#include \"vs100.h\"", file=f)
        print("u32 initial[][18] = {", file=f)
        print(initial, file=f)
        print("};", file=f)
        print("u32 final[][18] = {", file=f)
        print(final, file=f)
        print("};", file=f)
        print("u16 prefetch[][2] = {", file=f)
        print(prefetch, file=f)
        print("};", file=f)
        print("u32 iram[][100] = {", file=f)
        print(iram, file=f)
        print("};", file=f)
        print("u32 fram[][100] = {", file=f)
        print(fram, file=f)
        print("};", file=f)
        print("int tests = %d;" % (count), file=f)
        f.close()
