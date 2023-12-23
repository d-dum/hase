module hase.object.mesh;

import bindbc.opengl;

interface IMesh
{
    GLuint getVbo();
    GLuint getVao();
    GLuint getEbo();
    GLsizei getDataSize();
}

class Mesh : IMesh
{
private:

    GLuint vao, vbo, ebo;
    GLsizei dataSize;

public:

    this(float[] positions, uint[] indices)
    {
        glGenVertexArrays(1, &vao);
        glBindVertexArray(vao);

        glGenBuffers(1, &vbo);
        glGenBuffers(1, &ebo);

        glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, ebo);
        glBufferData(GL_ELEMENT_ARRAY_BUFFER, indices.length * uint.sizeof, indices.ptr, GL_STATIC_DRAW);

        glBindBuffer(GL_ARRAY_BUFFER, vbo);
        glBufferData(GL_ARRAY_BUFFER, positions.length * positions.sizeof, positions.ptr, GL_STATIC_DRAW);

        glBindBuffer(GL_ARRAY_BUFFER, 0);
        glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, 0);

        glBindVertexArray(0);
    }


    GLuint getVao()
    {
        return vao;
    }

    GLuint getVbo()
    {
        return vbo;
    }

    GLuint getEbo()
    {
        return ebo;
    }

    GLsizei getDataSize()
    {
        return dataSize;
    }
}
