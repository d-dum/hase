module hase.core.shader;

import bindbc.opengl;

interface IShader
{
    GLuint getShaderId();
}

class Shader : IShader
{
private:
    GLuint shaderId;

    void checkErrors(GLuint shaderId)
    {
        GLint compiled;
        glGetShaderiv(shaderId, GL_COMPILE_STATUS, &compiled);
        if(!compiled)
        {
            import std.conv : to;

            int infoLogLength = 0;
            glGetShaderiv(shaderId, GL_INFO_LOG_LENGTH, &infoLogLength);
            char[] log = new char[infoLogLength];
            glGetShaderInfoLog(shaderId, infoLogLength, null, log.ptr);
            throw new Exception(to!string(log));
        }
    }

public:



    this(string shaderPath, GLenum shaderType)
    {
        import std.file : readText;

        scope string source = readText(shaderPath);
        shaderId = glCreateShader(shaderType);
        {
            const GLint[1] lengths = [cast(GLint)source.length];
            const(char)*[1] sources = [source.ptr];
            glShaderSource(shaderId, 1, sources.ptr, lengths.ptr);
            glCompileShader(shaderId);
        }
        checkErrors(shaderId);
    }

    GLuint getShaderId()
    {
        return shaderId;
    }

    ~this()
    {
        glDeleteShader(shaderId);
    }
}
