module hase.object.mesh;

import bindbc.opengl;

import hase.object.primitive : IPrimitive, PrimitiveData;

import std.typecons : Nullable;

interface IMesh
{
	GLuint getVao();
	GLsizei getDataSize();

	GlBuffer getPositions();

	bool hasUv();

	GlBuffer getUvs();
}

struct GlBuffer
{
	GLuint bufferObject;
	GLuint elementBufferObject;
	bool indexed = false;

	static GlBuffer fromArrays(T)(T[] buffer, Nullable!(uint[]) indices = Nullable!(uint[])(),
		GLenum mode = GL_STATIC_DRAW)
	{
		GLuint bo = 0, eo = 0;
		bool isIndexed = false;
		glGenBuffers(1, &bo);
		if (!indices.isNull())
		{
			uint[] data = indices.get();
			isIndexed = true;
			glGenBuffers(1, &eo);
			glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, eo);
			glBufferData(GL_ELEMENT_ARRAY_BUFFER, data.length * uint.sizeof, data.ptr, mode);
		}

		glBindBuffer(GL_ARRAY_BUFFER, bo);
		glBufferData(GL_ARRAY_BUFFER, buffer.length * T.sizeof, buffer.ptr, mode);

		return GlBuffer(bo, eo, isIndexed);
	}

	void bind()
	{
		if (this.indexed)
		{
			glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, this.elementBufferObject);
		}
		glBindBuffer(GL_ARRAY_BUFFER, this.bufferObject);
	}

	void unbind()
	{
		if (this.indexed)
		{
			glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, 0);
		}
		glBindBuffer(GL_ARRAY_BUFFER, 0);
	}

	void destroy()
	{
		glDeleteBuffers(1, &bufferObject);
		if (indexed)
		{
			glDeleteBuffers(1, &elementBufferObject);
		}
	}
}

class Mesh : IMesh
{
private:

	GLuint vao;
	GlBuffer positions;
	GlBuffer uvs;

	bool hasUvs = false;

	GLsizei dataSize;

public:

	this(float[] positions, uint[] indices, float[] uvs, uint[] uvIndices)
	{
		glGenVertexArrays(1, &vao);
		glBindVertexArray(vao);

		glEnableVertexAttribArray(0);

		this.positions = GlBuffer.fromArrays(positions, Nullable!(uint[])(indices));

		glVertexAttribPointer(
			0,
			3,
			GL_FLOAT,
			GL_FALSE,
			0,
			null);

		this.positions.unbind();
		glDisableVertexAttribArray(0);

		if (uvs.length != 0)
		{
			hasUvs = true;

			glEnableVertexAttribArray(1);

			this.uvs = GlBuffer.fromArrays(uvs,
				uvIndices.length == 0 ?
					Nullable!(uint[])() : Nullable!(uint[])(uvIndices));

			glVertexAttribPointer(
				1,
				2,
				GL_FLOAT,
				GL_FALSE,
				0,
				null);

			this.uvs.unbind();
			glDisableVertexAttribArray(1);

		}

		glBindVertexArray(0);

		dataSize = cast(int) indices.length;
	}

	this(IPrimitive primitive)
	{
		PrimitiveData data = primitive.getData();
		this(data.positions, data.indices, data.uv, []);
	}

	GLuint getVao()
	{
		return vao;
	}

	GlBuffer getPositions()
	{
		return positions;
	}

	GLsizei getDataSize()
	{
		return dataSize;
	}

	bool hasUv()
	{
		return hasUvs;
	}

	GlBuffer getUvs()
	{
		return uvs;
	}

	~this()
	{
		glDeleteVertexArrays(1, &vao);
		positions.destroy();
		if (hasUvs)
		{
			this.uvs.destroy();
		}
	}
}
