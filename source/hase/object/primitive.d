module hase.object.primitive;

struct PrimitiveData
{
    float[] positions;
    uint[] indices;
}

interface IPrimitive
{
    PrimitiveData getData();
}

class Quad : IPrimitive
{
    PrimitiveData getData()
    {
        return PrimitiveData(
            [ -0.5f, 0.5f, 0.0f,
            -0.5f, -0.5f, 0.0f,
            0.5f, -0.5f, 0.0f,
            0.5f, 0.5f, 0.0f,],
            [ 0, 1, 3,
            3, 1, 2]
        );
    }
}