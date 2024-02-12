module hase.core.renderer;

import bindbc.opengl;

import hase.core.shader_program;
import hase.object.mesh : IMesh, GlBuffer;

import inmath;

interface IRenderer
{
	void render(IMesh mesh);
	void prepare();
	mat4 getProjection();
}

class Renderer : IRenderer
{
private:
	mat4 projection;

public:
	this(float fov, float height, float width, float near, float far)
	{
		projection = mat4.perspective(width, height, fov, near, far);
	}

	mat4 getProjection()
	{
		return projection;
	}

	void prepare()
	{
		glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
	}

	void render(IMesh mesh)
	{
	  GlBuffer positions = mesh.getPositions();
	  
		glBindVertexArray(mesh.getVao());
		glEnableVertexAttribArray(0);

		positions.bind();
		
		glDrawElements(GL_TRIANGLES, mesh.getDataSize(), GL_UNSIGNED_INT, null);

		glDisableVertexAttribArray(0);
		positions.unbind();
		glBindVertexArray(0);
	}
}
