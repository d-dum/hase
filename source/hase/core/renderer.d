module hase.core.renderer;

import bindbc.opengl;

import hase.core.shader_program;
import hase.object.mesh;

interface IRenderer
{
  void render(IMesh mesh);
}

class Renderer : IRenderer
{
private:
  


public:
  this()
  {
	
  }


  void render(IMesh mesh)
  {
	glBindVertexArray(mesh.getVao());
	glEnableVertexAttribArray(0);
	glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, mesh.getEbo());
	glBindBuffer(GL_ARRAY_BUFFER, mesh.getVbo());

	glVertexAttribPointer(
						  0,
						  3,
						  GL_FLOAT,
						  GL_FALSE,
						  0,
						  null);
	
	
	glDrawElements(GL_TRIANGLES, mesh.getDataSize(), GL_UNSIGNED_INT, null);

	glDisableVertexAttribArray(0);
	glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, 0);
	glBindBuffer(GL_ARRAY_BUFFER, 0);
	glBindVertexArray(0);
  }
}
