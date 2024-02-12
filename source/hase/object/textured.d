module hase.object.textured;

import hase.core.texture : ITexture;

import hase.object.general_object : IGeneralObject;

interface ITextured(T)
{
	T getObject();
	ITexture getTexture();
}

class Textured(T) : ITextured!T, IGeneralObject!T
{
private:
	ITexture texture;
	T obj;

public:

	this(T obj, ITexture texture)
	{
		this.obj = obj;
		this.texture = texture;
	}

	T getObject()
	{
		return obj;
	}

	ITexture getTexture()
	{
		return texture;
	}

}
