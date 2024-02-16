module hase.util.model_loader;

import wavefront.obj;

import hase.object.mesh;

import std.typecons : Nullable;

interface IModelLoader
{
	Nullable!IMesh load(T : IMesh)(string path);
}

class WavefrontLoader : IModelLoader
{
private:

public:

	this()
	{

	}

	Nullable!IMesh load(T : IMesh)(string path)
	{
		float[] positions = [], uvs = [];
		uint[] indices = [], uvIndices = [];

		Model model;

		try
		{
			model = new Model(path);
		}
		catch (Exception e)
		{
			return Nullable!IMesh();
		}

		if (model.nfaces() == 0)
		{
			return Nullable!IMesh();
		}

		for (int i = 0; i < model.nverts; i++)
		{
			Vec3f pos = model.vert(i);
			positions ~= [pos[0], pos[1], pos[2]];
		}

		for (int i = 0; i < model.ntextures; i++)
		{
			Vec2f uv = model.texture(i);
			uvs ~= [uv[0], uv[1]];
		}

		for (int i = 0; i < model.nfaces; i++)
		{
			Face[] face = model.face(i);
			foreach (Face f; face)
			{
				uvIndices ~= f.t;
				indices ~= f.v;
			}

		}

		return Nullable!IMesh(T.fromArrays(positions, indices, uvs, uvIndices));
	}
}
