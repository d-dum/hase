module hase.core.texture;

import hase.util.image : IImage, PixelFormat, ImageDimensions;

import bindbc.opengl;

import std.typecons : Nullable;

interface ITexture
{
	bool isLoaded();
	GLuint getTextureID();
	string getUniformName();
	int getTextureIndex();
}

class Texture : ITexture
{
private:
	GLuint textureID;

	bool isLoadedCorrectly = false;

	string uniformName;
	int textureIndex;
public:

	this(IImage image, string uniformName = "haseSampler", int textureIndex = 0)
	{
		this.textureIndex = textureIndex;
		this.uniformName = uniformName;
		if (!image.isLoaded())
		{
			debug
			{
				throw new Exception("Texture is not loaded");
			}
			return;
		}

		glGenTextures(1, &textureID);
		glBindTexture(GL_TEXTURE_2D, textureID);

		glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
		glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);

		GLenum format;
		Nullable!PixelFormat imageFormat = image.getPixelFormat();

		if (imageFormat.isNull())
		{
			return;
		}

		switch (imageFormat.get())
		{
		case PixelFormat.RGBA:
			format = GL_RGBA;
			break;
		case PixelFormat.RGB:
			format = GL_RGB;
			break;
		default:
			format = GL_RGB;
			break;
		}

		Nullable!ImageDimensions dimensions = image.getDimensions();
		if (dimensions.isNull())
		{
			return;
		}

		Nullable!(void*) pixels = image.getPixels();
		if (pixels.isNull())
		{
			return;
		}

		glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, dimensions.get().width, dimensions.get()
				.height, 0, format, GL_UNSIGNED_BYTE, pixels
				.get());

		glBindTexture(GL_TEXTURE_2D, 0);

		isLoadedCorrectly = true;
	}

	int getTextureIndex()
	{
		return textureIndex;
	}

	string getUniformName()
	{
		return uniformName;
	}

	bool isLoaded()
	{
		return isLoadedCorrectly;
	}

	GLuint getTextureID()
	{
		return textureID;
	}

	~this()
	{
		glDeleteTextures(1, &textureID);
	}
}
