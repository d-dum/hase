module hase.core.renderer;

import bindbc.opengl;

import hase.core.shader_program;
import hase.object.mesh;

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
		glBindVertexArray(mesh.getVao());
		glEnableVertexAttribArray(0);
		glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, mesh.getEbo());
		glBindBuffer(GL_ARRAY_BUFFER, mesh.getVbo());

		glDrawElements(GL_TRIANGLES, mesh.getDataSize(), GL_UNSIGNED_INT, null);

		glDisableVertexAttribArray(0);
		glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, 0);
		glBindBuffer(GL_ARRAY_BUFFER, 0);
		glBindVertexArray(0);
	}
}
