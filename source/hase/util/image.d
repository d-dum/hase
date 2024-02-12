module hase.util.image;

import bindbc.sdl;

import std.typecons : Nullable;
import std.stdint : uint8_t, uint16_t;

interface IImage
{
	bool isLoaded();
	Nullable!(void*) getPixels();
	Nullable!PixelFormat getPixelFormat();
	Nullable!ImageDimensions getDimensions();
}

struct ImageDimensions
{
	int width;
	int height;
}

enum PixelFormat
{
	RGB,
	RGBA
}

class Image : IImage
{
private:
	SDL_Surface* imageSurface = null;
	int resulution = 0;
	int pixelBufferSize = 0;
	int pixelSize = 0;

	bool loadedCorrectly = false;
	PixelFormat format;

	int width;
	int height;

public:
	this(string path)
	{

		imageSurface = IMG_Load(cast(const(char)*) path.ptr);

		if (!imageSurface)
		{
			debug
			{
				throw new Exception("Failed to load image " ~ path);
			}
			loadedCorrectly = false;
			return;
		}

		resulution = imageSurface.w * imageSurface.h;
		pixelSize = imageSurface.format.BytesPerPixel;

		if (pixelSize == 4 && imageSurface.format.Amask != 0)
		{
			format = PixelFormat.RGBA;
		}
		else
		{
			format = PixelFormat.RGB;
		}

		width = imageSurface.w;
		height = imageSurface.h;

		loadedCorrectly = true;
	}

	bool isLoaded()
	{
		return loadedCorrectly;
	}

	Nullable!(SDL_Surface*) getSurface()
	{
		return Nullable!(SDL_Surface*)(imageSurface);
	}

	Nullable!(void*) getPixels()
	{
		if (!loadedCorrectly)
		{
			return Nullable!(void*)();
		}

		return Nullable!(void*)(imageSurface.pixels);
	}

	Nullable!PixelFormat getPixelFormat()
	{
		if (!loadedCorrectly)
		{
			return Nullable!PixelFormat();
		}
		return Nullable!PixelFormat(format);
	}

	Nullable!ImageDimensions getDimensions()
	{
		if (!loadedCorrectly)
		{
			return Nullable!ImageDimensions();
		}

		return Nullable!ImageDimensions(ImageDimensions(width, height));
	}

	~this()
	{
		if (!loadedCorrectly)
		{
			return;
		}
		SDL_FreeSurface(imageSurface);
	}

}
