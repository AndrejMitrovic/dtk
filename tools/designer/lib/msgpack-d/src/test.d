import msgpack;

class C
{
    this(int);
}

void main()
{
    auto c = new C(1);
    ubyte[] data = msgpack.pack(c);
    msgpack.unpack(data, c);
}
