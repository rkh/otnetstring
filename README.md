# OTNetstring

Similar to [Tagged Netstrings](http://tnetstrings.org/), but optimized for streaming.

What changed: The type info is not at the end of the encoded data, but at the beginning, right after
the size info. That way nested objects can be created while reading from the stream. Therefore it is
rather similar to [Bencode](http://en.wikipedia.org/wiki/Bencode), plus the Nestring advantage of
always knowing how many bytes to read.

Objects look like this:

    Ruby            TNetstring      OTNetstring     Bencode
    
    42              2:42#           2#42            i42e
    "hi"            2:hi,           2,hi            2:hi
    true            4:true!         4!true          (not possible)
    [1]             4:1:1#}         3:{1#1          li1ee
    {"a" => "b"}    8:1:a,=1:b,}    6{1,a1,b        d1:a1:be

Similar implementations (both pure ruby, using recursion for nested objects) show the performance
difference, esp. when simulating a network IO:

                                                              user     system      total        real
    TNetstring: simple objects                            0.000000   0.000000   0.000000 (  0.000160)
    OTNetstring: simple objects                           0.000000   0.000000   0.000000 (  0.000166)*
    TNetstring: long string                               0.130000   0.050000   0.180000 (  0.186946)
    OTNetstring: long string                              0.050000   0.000000   0.050000 (  0.047778)
    TNetstring: flat arrays                               2.280000   2.940000   5.220000 (  5.432791)
    OTNetstring: flat arrays                              0.470000   0.010000   0.480000 (  0.484575)
    TNetstring: complex nesting                           4.310000   3.100000   7.410000 (  7.562399)
    OTNetstring: complex nesting                          1.940000   0.010000   1.950000 (  1.943385)
    TNetstring: with remainder                            0.300000   0.250000   0.550000 (  0.574956)
    OTNetstring: with remainder                           0.080000   0.080000   0.160000 (  0.152838)
    TNetstring: streaming (3 GBit/sec)                    2.160000   3.010000   5.170000 (  5.180267)
    OTNetstring: streaming (3 GBit/sec)                   0.860000   0.050000   0.910000 (  0.917463)
    TNetstring: streaming (3 GBit/sec), with remainder    0.490000   0.360000   0.850000 (  4.836673)
    OTNetstring: streaming (3 GBit/sec), with remainder   0.080000   0.070000   0.150000 (  0.148301)
    
    * this is (insignificantly) slower, since OTNetstring wraps each String in a StringIO

API is identical to [tnetstring-rb](https://github.com/mattyoho/tnetstring-rb), except that you use
`OTNetstring` instead of `TNetstring` and that `parse` also takes `IO` or `IO`-like objects as
argument.

## Running benchmarks

    git submodule init
    git submodule update
    ./bench.rb

## Stuff to think about

* If `:` would identify strings rather than `,` and each object would end with a `,`, then Netstrings
  and TNetstring-Strings would be valid OTNetstring objects.
* Representations of `true` and `false` could be shortened.
