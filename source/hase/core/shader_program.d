module hase.core.shader_program;

import bindbc.opengl;

interface IShaderProgram
{
    GLuint getProgramId();
    GLuint getAttribLocation(string name);
}

class ShaderProgram : IShaderProgram
{
private:

    GLuint programId;
    GLuint[string] locations;

public:

    this(GLuint programId)
    {
        this.programId = programId;
    }

    GLuint getProgramId()
    {
        return programId;
    }

    GLuint getAttribLocation(string name)
    {
        if(name !in locations)
        {}
        

        immutable GLuint loc = glGetAttribLocation(this.programId, cast(const(char*)) name.ptr);

        if(loc == 0)
        {
            throw new Exception("Attribute not found");
        }

        return cast(GLuint) loc;
    }
}
