module hase.core.shader_program;

import bindbc.opengl;
import hase.core.shader;

interface IShaderProgram
{
    GLuint getProgramId();
    GLuint getAttribLocation(string name);
    void start();
    void stop();
}

class ShaderProgram : IShaderProgram
{
private:

    GLuint programId;
    GLuint[string] locations;

    void checkErrors()
    {
        GLint linked = 0;
        glGetProgramiv(programId, GL_LINK_STATUS, &linked);
        if(!linked)
        {
            import std.conv : to;

            int infoLogLength = 0;
            glGetProgramiv(programId, GL_INFO_LOG_LENGTH, &infoLogLength);
            char[] log = new char[infoLogLength];

            throw new Exception(to!string(log));
        }
    }

public:

    this(IShader[] shaders)
    {
        programId = glCreateProgram();

        foreach(IShader shader; shaders)
        {
            glAttachShader(programId, shader.getShaderId());
        }

        glLinkProgram(programId);

        checkErrors();
    }

    GLuint getProgramId()
    {
        return programId;
    }

    GLuint getAttribLocation(string name)
    {
        if(name in locations)
        {
            return locations[name];
        }
        

        immutable GLuint loc = glGetAttribLocation(this.programId, cast(const(char*)) name.ptr);

        if(loc == 0)
        {
            throw new Exception("Attribute not found");
        }

        return cast(GLuint) loc;
    }

    void start()
    {
        glUseProgram(programId);
    }

    void stop()
    {
        glUseProgram(0);
    }


    ~this()
    {
        glDeleteProgram(programId);
    }
}
