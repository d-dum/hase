module hase.core.shader_program;

import bindbc.opengl;
import hase.core.shader;

import inmath;

import std.typecons : Nullable;

interface IShaderProgram
{
	GLuint getProgramId();
	Nullable!Attribute getAttribLocation(string name);
	Nullable!Uniform getUniformLocation(string name);
	void start();
	void stop();
}

struct Uniform
{
	GLint location;

	void load(mat4 matrix)
	{
		glUniformMatrix4fv(location, 1, GL_TRUE, matrix.ptr);
	}
}

struct Attribute
{
	GLuint location;
}

class ShaderProgram : IShaderProgram
{
private:
	IShader[] shaders;
	GLuint programId;
	GLint[string] attrLocations;
	GLint[string] uniformLocations;

	void checkErrors()
	{
		GLint linked = 0;
		glGetProgramiv(programId, GL_LINK_STATUS, &linked);
		if (!linked)
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

		foreach (IShader shader; shaders)
		{
			glAttachShader(programId, shader.getShaderId());
		}

		glLinkProgram(programId);

		checkErrors();

		this.shaders = shaders;
	}

	GLuint getProgramId()
	{
		return programId;
	}

	Nullable!Attribute getAttribLocation(string name)
	{
		if (name in attrLocations)
		{
			return Nullable!Attribute(Attribute(attrLocations[name]));
		}

		immutable GLint loc = glGetAttribLocation(this.programId, cast(const(char*)) name.ptr);

		if (loc == -1)
		{
			return Nullable!Attribute();
		}

		return Nullable!Attribute(Attribute(cast(GLuint) loc));
	}

	Nullable!Uniform getUniformLocation(string name)
	{
		if (name in uniformLocations)
		{
			return Nullable!Uniform(Uniform(uniformLocations[name]));
		}

		immutable GLint loc = glGetUniformLocation(this.programId, cast(const(char*)) name.ptr);

		if (loc == -1)
		{
			return Nullable!Uniform();
		}

		return Nullable!Uniform(Uniform(cast(GLuint) loc));
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
