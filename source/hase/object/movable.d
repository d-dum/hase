module hase.object.movable;

import inmath;

interface IMovable(T)
{
	T getObject();
	mat4 getModel();
}

class Movable(T) : IMovable!T
{
private:
	T obj;
	mat4 model;

public:

	this(T obj, vec3 position = vec3(0, 0, 0), vec3 rotation = vec3(0, 0, 0))
	{
		model = mat4.identity;

		model *= mat4.translation(position);
		model = model.rotateX(rotation.x);
		model = model.rotateY(rotation.y);
		model = model.rotateZ(rotation.z);
	}

	T getObject()
	{
		return obj;
	}

	mat4 getModel()
	{
		return model;
	}

}
