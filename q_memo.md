
my q Tips

�v���N�e�B�X�I�Ȃ��Ƃɂ��āB
���Q Tips��ǂ�ŏ����܂����B
�\���⍀�ږ���Effective C++������Ɉӎ����܂����B

# ����\��

## `if`�̓A�[���[���^�[������Ƃ��̂ݎg����

��������͒ʏ�A�O�����Z�q�i�������Z�q�j���邢�͎�����array lookup���g���čs���B
`if`�͊֐�����r���Ŕ�����Ƃ��Ɍ����Ďg���B

���̗��q Tips��`.stat.bm`�ł���B
���͒l�����O�����𖞂����Ȃ��Ƃ��ɗ�O�𓊂��Ă���B

```
/ box-muller
bm:{
 if[count[x] mod 2;'`length];
 x:2 0N#x;
 r:sqrt -2f*log first x;
 theta:2f*acos[-1f]*last x;
 x: r*cos theta;
 x,:r*sin theta;
 x}
```

�Q�l�F

Q Tip 11.2 Use `if` statements to exit functions early

[q4m3](https://code.kx.com/q4m3/10_Execution_Control/#1014-if) Well-written q code rarely needs if. One example of legitimate use is pre-checking function arguments to abort execution for bad values.

## array lookup�͊ȒP�ȏ�������Ɏg����

�O�����Z�q�i�������Z�q�j`$[;;]`�̑����bool�l���C���f�b�N�X�Ƃ��āA�v�f��2�̃��X�g����l�����Z�@������B

```
q)"ny" 0b
"n"
q)"ny" 1b
"y"
```

array lookup��atomic�Ȃ̂Ń��X�g�⎫���A�e�[�u���ɂ��g����i`each`�������Ȃ��Ă������I�Ƀ��t�g�����j�B

```
q)"ny" 10101b
"ynyny"
```

�A���A�O�����Z�q�ƈقȂ�A�x���]������Ȃ��i���i�]�������j���Ƃɒ��ӂ��悤�B

���̗��q Tips��`.sim.genp`�ł���B
`dtm`�̌^��timestamp(12h)�Adete(14h)�Adatetime(15h)�̂Ƃ���timestamp(p)�ɃL���X�g���A�����łȂ��Ƃ���timespan(n)�ɃL���X�g���Ă���B

```
/ generate price path
/ security (id), (S)pot, (s)igma, (r)ate, (d)ate/(t)i(m)e
genp:{[id;S;s;r;dtm]
 t:abs type dtm;
 tm:("np" t in 12 14 15h)$dtm; / array lookup�Z�@���g���Ă���
 p:S*path[s;r;tm%365D06];
 c:`id,`time`date[t=14h],`price;
 p:flip c!(id;dtm;p);
 p}
```

����̊g���Łi�R�l�Łj�Ƃ��āA���������A�[���A���ɂ��Ă̏ꍇ�����Ȃǂ��������Ƃ��ł���B

```
q)"S B"1+signum 10 0 -10
"B S"
```

���l�̏ꍇ�͎��̂悤�ȎZ�p�L�@���֗��ł���B

```
q)flag:1b
q)base:100
q)base+flag*42
142
```

�Q�l�F

[q4m3](https://code.kx.com/q4m3/2_Basic_Data_Types_Atoms/#231-boolean) Tip: The ability of booleans to participate in arithmetic can be useful in eliminating conditionals.

Q Tip 8.1 Use array lookups to implement simple conditional statements

Q Tip 5.4 Use scalar condtional $[;;]to implement lazily evaluated blocks

## `while`�����z�񏈗����g����

q����͔z��i���X�g�j�̏��������ӂȌ���ł���Amap, filter, fold�����̑�����Ȍ��ɏ����A�����I�ł���B
�����̏����͂����ŏ������Ƃ��\�ł���͂��ŁAconverge(`(func\)x`)�Ȃǂ�iterator��p����΃j���[�g���@�Ȃǂ̎����v�Z���ł���B

```
q)nr:{[e;f;x]$[e>abs d:first[r]%last r:f x;x;x-d]} / newton-raphson
q)func:{(-2+x*x;2*x)}
q)nr[1e-10;func;]/[1.0]
1.414214
```

�H�ł��邪`while`���K�v�ȂƂ�������B
���̗��q Tips��`.timer.loop`�iCEP�G���W���ɂ����郋�[�v�֐��j�ł���B

```
/ scan timer (t)able for runable jobs
loop:{[t;tm]
 while[tm>=last tms:t `time;t:run[t;-1+count tms;tm]];
 t}
```

�Q�l�F

[q4m3](https://code.kx.com/q4m3/10_Execution_Control/#1016-while) The author has never used while in actual code.

[Reference](https://code.kx.com/v2/basics/control/#control-words) Control words are little used in practice for iteration. Iterators are more commonly used.

Q Tip 17.9 Pursue the functional-vector solution

## ����\���͂P�s�ŏ������B

`if`��`while`�͂P�s�ŏ����Ă��܂����i�P�s�ŏ�������x�̓��e�ɗ��߂悤�j�B
`if[...]`��`while[...]`�̒��ɂ̓Z�~�R����������邪�A���s�͂��Ȃ��悤�ɂ��悤�B

�Q�l�F

Q Tip 4.5 Limit control flow statesments to a single line


# �f�[�^�\��

## �v�f1�̃��X�g�����Ƃ���`enlist`���g����

�v�f1�̃��X�g�iq����ł̓V���O���g���Ƃ����j�������@�͂��낢�낪���邪�A`enlist`���ł��ǂ݂₷���̂ł�����g�����B

```
q)a:42
q)(),a
,42
q)a,()
,42
q)1#a
,42
q)enlist a
,42
```

�Q�l�F

[q4m3](https://code.kx.com/q4m3/3_Lists/#351-joining-with) Tip: To ensure that a q entity becomes a list, use either `(),x` or `x,()`. This leaves a list unchanged but effectively enlists an atom. Such a seemingly trivial expression is actually useful and is our first example of a q idiom. You cannot use `enlist x` for the same purpose. Why not?

Q Tips��`1#a`���悭�g���Ă��܂����Aq4m3�ɏ]�����Ƃɂ��܂��B

## �����̃L�[�̓��j�[�N�ɂȂ�悤�ɂ��悤

q����̎����̓��X�g2����\������Ă��邽�߁A�����L�[�𕡐������Ă��܂����Ƃ��ł��Ă��܂��B

```
q)d:(`hoge;`hoge)!(10 20)
q)d
hoge| 10
hoge| 20
```

���A���̂悤�Ȏ����͍��Ȃ��悤�ɋC��t���悤�i���낢��ȉ��Z������`����j�B

�Q�l�F

Q Tip 7.1 Ensure dictionary keys are unique

## �e�[�u���ŃW�F�l���b�N�^�̗�������Z�@�ɂ��Ēm�낤

�P�̗�ɂ��낢��Ȍ^�̗v�f���������������Ƃ�����B
���̗�ł�Q Tips��CEP�G���W���ł̃C�x���g�e�[�u������낤�Ƃ��Ă���B
`meta`�����s���邱�Ƃ�`func`�񂪃W�F�l���b�N�ł��邱�Ƃ��m�F�ł���

```
q)timer.job:([] name:`symbol$();func:();time:`timestamp$())
q)show timer.job
name func time
--------------
q)meta timer.job
c   | t f a
----| -----
name| s
func|
time| p
```

�������Ȃ���A�����ɍs��ǉ�����ƁA`func`��͌^�t�����X�g�isimple list�j�ɂȂ��Ă��܂��B

```
q)meta timer.job upsert (`;`;.z.P)
c   | t f a
----| -----
name| s
func| s
time| p
```

�����������邽�߂ɂ͍ŏ��̗v�f�Ƃ��ăW�F�l���b�N�ȋ󃊃X�g�����Ă����΂悢�B
��������΁A`func`��̑S�v�f�������^�ɂȂ邱�Ƃ��Ȃ����߁A�W�F�l���b�N���X�g�ł��邱�Ƃ�ۂ��Ƃ��ł���B

```
q)`timer.job upsert (`;();0Wp)
`timer.job
q)`timer.job upsert (`;`;.z.P)
`timer.job
q)show timer.job
name func time
---------------------------------------
     ()   0W
     `    2019.05.12D05:37:35.894148000
q)meta timer.job
c   | t f a
----| -----
name| s
func|
time| p
```

�Q�l�F

Q Tip 10.1 Insert an empty row to prevent untyped columns from collapsing


# �֐�

## �֐��̊e�s�̓Z�~�R�����ŏI���悤�ɂ��悤

�Z�~�R������Y���̂�q����̈�ʓI�ȊԈႢ�ł���B
�X�N���v�g�Ŋ֐��𕡐��s�ŏ����Ƃ��ɂ́A�ŏ��̍s�i�֐����Ɖ��������������j�ƍŌ�̍s�i�߂�l�������j�������ăZ�~�R�����ŏI���悤�ɂ��悤�B

�܂��A�r���Ŗ߂�l��߂��Ƃ���

```
 if[not count x;:x];
```

�̂悤�ɁA�P�s��`if`�X�e�[�g�����g�̒��Łi���s�����Ɂj�s�����Ƃɂ��悤�B


�Q�l�F

Q Tip 4.6 Make sure each line in a function ends with a semicolon

## �֐��̍Ō�̍s�͖߂�l�ϐ��ƕ��J�b�R�i`}`�j���g�����B

�֐��̍Ō�̍s�͖߂�l�ϐ��ƕ��J�b�R�i`}`�j�����ɂ��邱�Ƃ��A�֐��̃h�L�������g�Ƃ��Ė]�܂����i�ǐ��������j�B

```
 }
```

�̂悤�Ɋ֐��̍Ō�̍s�����J�b�R�i`}`�j�݂̂ł���̂́A�߂�l��null�igeneric null�j�ł��邱�Ƃ��Ӗ�����B

## �֐��̕����K�p�͖����I�ɍs����

���ϐ��֐��̕����K�p���s���ہA�����̃Z�~�R�����͏ȗ����邱�Ƃ��ł���i�擪���畔���K�p�����j�B

```
q)f:{x+y+z}
q)g:f[42]
q)g[1;2]
45
```

�������A����͓ǂ݂ɂ����̂ŁA�����I��

```
q)g:f[42;;]
q)g[1;2]
45
```

�Ə������B

�Q�l�F

[q4m3](https://code.kx.com/q4m3/6_Functions/#641-function-projection) We recommend that you do not omit trailing semi-colons in projections, as this can obscure the intent of code.

[Reference](https://code.kx.com/v2/basics/application/#projection) Make projections explicit

Q Tips�͕��ʂɏȗ����Ă��܂����Aq4m3�ɏ]�����Ƃɂ��܂��B


# ����

## ���̂��R�s�[�����Ƃ���m�낤

q����́iC++���l�Ɂj�l�̃Z�}���e�B�N�X��������ł���A�Z�}���e�B�N�X�Ƃ��Ă̓R�s�[�͐[���R�s�[�ł���B

```
q)L1:10 20 30
q)L2:L1 / �[���R�s�[�i�Ǝv���Ă悢�j
q)L2[0]:100 / L2������������
q)show L1 / L1�͕ς��Ȃ����Ƃ�����
10 20 30
q)show L2
100 20 30
```

�������Ȃ���Aq����ł͕K�v������܂ł͎��ۂɎ��̂��R�s�[����邱�Ƃ͂Ȃ��A�����������ɃR�s�[�����iCopy-On-Write�j�B
�����֐�`-16!`���g�����Ƃŕϐ��̎Q�ƃJ�E���g���݂邱�Ƃ��ł���̂ŁA������g���ċ������m�F���Ă݂�B

```
q)L1:10 20 30
q)-16!L1
1i
q)L2:L1
q)-16!L1 / L2�Ǝ��̂����L���Ă���̂ŎQ�ƃJ�E���g��2
2i
q)L2[0]:100 / �����������Ɏ��̂��R�s�[����A�ʕ��ɂȂ�B
q)-16!L1 / L2�Ǝ��̂����L���Ă��Ȃ��̂ŎQ�ƃJ�E���g��1
1i
```

���X�g���玫����e�[�u�������Ƃ��A�e�[�u������q-sql�Ńf�[�^�𒊏o����Ƃ��Ȃǂ����l�ł���B
�܂�A�f�[�^������������܂ŁA���̂��R�s�[�����킯�ł͂Ȃ��B

## �e�[�u������s���폜������t���O���g����

q����̃e�[�u���͍s��������������A���ł��邱�ƕۂ��߁A�s�폜�͔��ɏd���������ł���B
�^�ɍs���폜����K�v���Ȃ���΁A�u�[���l�̃t���O�𗧂Ă邱�Ƃő�p���悤�B

�Q�l�F

Q Tip 12.1 Use boolean flags instead of deleting rows

## �e�[�u���̕s�v�ȗ�͍폜���悤

��폜�͂ǂ�ǂ����Ă悢�B
�s�v�ȗ���폜����ƁA���̌�̃N�G���������Ȃ邩������Ȃ��B

�Q�l�F

Q Tip 17.2 Delete unused columns before adding new ones


# q-sql

## insert���upsert���g����

���̂܂܁B

�Q�l�F

[q4m3](https://code.kx.com/q4m3/9_Queries_q-sql/#91-inserting-records) Tip: The upsert function is superior to insert and is to be preferred. We include insert for nostalgia only.

## `where`��̍ŏ��ɔ��肪�������́A�����I�Ȃ��̂�������

`where`��ł́A�R���}��؂�ŕ��������������A�Z���]�������B
�]���āA�ŏ��́i�����́j�����ɔ��肪�������̂␧���I�Ȃ��̂��������B

```
q)dts:.util.rng[1;2000.01.01;2005.01.01]
q)t:raze .sim.genp[;100;.3;.03;dts] each til 10
q)select from t where id=1,date.month = 2000.02m
id date       price
----------------------
1  2000.02.01 109.0513
1  2000.02.02 109.657
1  2000.02.03 112.1111
1  2000.02.04 115.0771
1  2000.02.05 115.0505
1  2000.02.06 116.454
1  2000.02.07 116.5213
1  2000.02.08 119.8954
1  2000.02.09 118.2443
1  2000.02.10 121.9608
1  2000.02.11 121.6705
1  2000.02.12 121.1099
1  2000.02.13 120.5877
1  2000.02.14 122.7702
1  2000.02.15 120.9654
1  2000.02.16 120.4115
1  2000.02.17 121.0173
1  2000.02.18 121.5537
1  2000.02.19 121.7538
1  2000.02.20 118.0143
..
```

���ӓ_�Ƃ��āAq�����`and`�i`&`�j�͒Z���]���łȂ��B
�Ȃ̂ŁA

```
q)select from t where (id=1) and date.month = 2000.02m
```

�Ə����ƌ�����������B

�Q�l�F

Q Tip 14.2 Apply the fastest and most restrictive where clauses first

