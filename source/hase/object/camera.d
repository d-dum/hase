module hase.object.camera;

import inmath;

interface ICamera
{
	mat4 getView();
}

class Camera : ICamera
{
private:
	mat4 view;

public:
	this(vec3 position, vec3 lookAt, vec3 up = vec3(0, 1, 0))
	{
		view = mat4.lookAt(position, lookAt, up);
	}

	mat4 getView()
	{
		return view;
	}
}
