0: CP2W 3
1: BZ 2
2: 0
3: 5
4: 0 // indirection register

// ADD Test 0 -- Regular
5: CP2W 10
6: ADD 11
7: CPfW 12 //copy the result from W to an address
8: CP2W 13
9: BZ 2
10: 13
11: 24
12: 0 //result // 13 + 24 = 37
13: 20

// ADD Test 1 -- Subtraction
20: CP2W 25
21: ADD 26
22: CPfW 27 //copy the result from W to an address
23: CP2W 28
24: BZ 2
25: 20
26: 0xFFFC // -4
27: 0 //result // 20 + 0xFFFC = 16
28: 30

// NOR Test 0
30: CP2W 35
31: NOR 36
32: CPfW 37 //copy the result from W to an address
33: CP2W 38
34: BZ 2
35: 5
36: 3
37: 0 //result // 0x5 NOR 0x3 = 0xFFF8
38: 40

// NOR Test 1
40: CP2W 45
41: NOR 46
42: CPfW 47 //copy the result from W to an address
43: CP2W 48
44: BZ 2
45: 0xFFFF
46: 0xFFFF
47: 5 //result // 0xFFFF NOR 0xFFFF = 0x0
48: 50

// SRL Test 0 -- Shift Right
50: CP2W 55
51: SRL 56
52: CPfW 57 //copy the result from W to an address
53: CP2W 58
54: BZ 2
55: 65
56: 3
57: 0 //result // 65 >> 3 = 8
58: 60

// SRL Test 1 -- Shift Left
60: CP2W 65
61: SRL 66
62: CPfW 67 //copy the result from W to an address
63: CP2W 68
64: BZ 2
65: 1
66: 23
67: 0 //result // 1 << (23 - 16) = 128
68: 70

// SRL Test 2 -- Shift Left lower4bits
70: CP2W 75
71: SRL 76
72: CPfW 77 //copy the result from W to an address
73: CP2W 78
74: BZ 2
75: 3
76: 54
77: 0 //result // 3 << (54 % 16) = 192
78: 80

// RRL Test 0 -- Rotate Right
80: CP2W 85
81: RRL 86
82: CPfW 87 //copy the result from W to an address
83: CP2W 88
84: BZ 2
85: 0xF00D
86: 4
87: 0 //result // 0xF00D rrot 4 = 0xDF00
88: 90

// RRL Test 1 -- Rotate Left
90: CP2W 95
91: RRL 96
92: CPfW 97 //copy the result from W to an address
93: CP2W 98
94: BZ 2
95: 0xBEEF
96: 20
97: 0 //result // 0xBEEF lrot (20 - 16) = 0xEEFB
98: 100

// RRL Test 2 -- Rotate Left lower4bits
100: CP2W 105
101: RRL 106
102: CPfW 107 //copy the result from W to an address
103: CP2W 108
104: BZ 2
105: 0xBEEF
106: 84
107: 0 //result // 0xBEEF lrot (84 % 16) = 0xEEFB
108: 110

// CMP Test 0 -- W < A
110: CP2W 115
111: CMP 116
112: CPfW 117 //copy the result from W to an address
113: CP2W 118
114: BZ 2
115: 12
116: 15
117: 0 //result // 12 cmp 15 = 0xFFFF
118: 120

// CMP Test 1 -- W == A
120: CP2W 125
121: CMP 126
122: CPfW 127 //copy the result from W to an address
123: CP2W 128
124: BZ 2
125: 22
126: 22
127: 5 //result // 22 cmp 22 = 0x0
128: 130

// CMP Test 2 -- W > A
130: CP2W 135
131: CMP 136
132: CPfW 137 //copy the result from W to an address
133: CP2W 138
134: BZ 2
135: 152
136: 37
137: 0 //result // 152 cmp 37 = 0x1
138: 140

// CP2W and CPfW Test 0
140: CP2W 145
141: CPfW 146
142: CPfW 147 //copy the result from W to an address
143: CP2W 148
144: BZ 2
145: 152
146: 37 //copied data should be here after the program is run
147: 0 //result // copied data should also be here after the program is run
148: 150

// BZ Test 0 - Skip
150: CP2W 155
151: BZ 156
152: CP2W 157 // Shouldn't execute, it's here in case you don't skip 
153: CP2W 158
154: BZ 2
155: 160
156: 0
157: 0xDEAD
158: 160

// BZ Test 1 - Don't Skip
160: CP2W 165
161: BZ 166
162: CP2W 167 // Should execute
163: CP2W 168
164: BZ 2
165: 170
166: 1
167: 0x600D
168: 170

// Indirect Adressing Tests

// ADD Indirect Test
170: CP2W 177
171: CPfW 4
172: CP2W 178
173: ADD 0
174: CPfW 180 //copy the result from W to an address
175: CP2W 181
176: BZ 2
177: 179
178: 10
179: 6
180: 0 //result // (**157 + *158) -> (*159 + *158) -> 6 + 10 = 16
181: 190

// NOR Indirect Test
190: CP2W 197
191: CPfW 4
192: CP2W 198
193: NOR 0
194: CPfW 200 //copy the result from W to an address
195: CP2W 201
196: BZ 2
197: 199
198: 0x0F0F
199: 0x00FF
200: 0 //result // ~(**177 | *178) -> ~(*179 | *178) -> 0x00FF NOR 0x0F0F = 0xF000
201: 210

// SRL Indirect Test
210: CP2W 217
211: CPfW 4
212: CP2W 218
213: SRL 0
214: CPfW 220 //copy the result from W to an address
215: CP2W 221
216: BZ 2
217: 219
218: 0xC0DE
219: 8
220: 0 //result // (*198 SRL **197) -> (*198 SRL *199) -> 0xC0DE SRL 40 = 0x00C0
221: 230

// RRL Indirect Test
230: CP2W 237
231: CPfW 4
232: CP2W 238
233: RRL 0
234: CPfW 240 //copy the result from W to an address
235: CP2W 241
236: BZ 2
237: 239
238: 0xC0DE
239: 8
240: 0 //result // (*218 RRL **217) -> (*218 RRL *219) -> 0xC0DE lrot 8 = 0xDECO
241: 250

// CMP Indirect Test
250: CP2W 257
251: CPfW 4
252: CP2W 258
253: CMP 0
254: CPfW 260 //copy the result from W to an address
255: CP2W 261
256: BZ 2
257: 259
258: 32
259: 16
260: 0 //result // (*258 CMP **257) -> (*258 CMP *259) -> 32 cmp 16 = 1
261: 270

// BZ Indirect Test
270: CP2W 278
271: CPfW 4
272: CP2W 279
273: BZ 0
274: CP2W 281 // shouldn't execute, it's here in case you don't skip
275: CPfW 282 // shouldn't execute, it's here in case you don't skip
276: CP2W 283
277: BZ 2
278: 280
279: 290
280: 0
281: 0xDEAD
282: 0
283: 290

// CP2W Indirect Test
290: CP2W 297
291: CPfW 4
292: CP2W 298
293: CP2W 0
294: CPfW 300 //copy the result from W to an address
295: CP2W 301
296: BZ 2
297: 299
298: 32
299: 0xFEED
300: 0 //result // (W = **297) -> (W = *299) -> W = 0xFEED
301: 310

// CPfW Indirect Test
310: CP2W 316
311: CPfW 4
312: CP2W 317
313: CPfW 0
314: CP2W 319
315: BZ 2
316: 318
317: 0xDEAF
318: 0 //result // (**316 = *317) -> (*318 = *317) -> *318 = 0xDEAF
319: 320

320: CP2W 322
321: BZ 2 //will loop to itself and end
322: 321 //END

