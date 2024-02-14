module hase.object.movable;

import hase.object.general_object : IGeneralObject;

import inmath;

interface IMovable(T)
{
	T getObject();
	mat4 getModel();
	IMovable!T mul(T : mat4, vec4)(T multiplier);
	IMovable!T rotate(float angle, vec3 axis);
	IMovable!T translate(vec3 transform);
}

class Movable(T) : IMovable!T, IGeneralObject!T
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

		this.obj = obj;
	}

	T getObject()
	{
		return obj;
	}

	mat4 getModel()
	{
		return model;
	}

	IMovable!T mul(M : mat4, vec4)(M multiplier)
	{
		model *= multiplier;
		return this;
	}

	IMovable!T translate(vec3 transform)
	{
		model *= mat4.translation(transform);
		return this;
	}

	IMovable!T rotate(float angle, vec3 axis)
	{
		model *= mat4.rotation(angle, axis);
		return this;
	}
}
