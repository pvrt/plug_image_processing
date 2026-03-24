# PlugImageProcessing

Image server as a [Plug](https://hex.pm/packages/plug), powered by [libvips](https://www.libvips.org/).

`PlugImageProcessing` downloads an image from a remote source, applies one or more image operations using libvips, and returns the processed image to the client.

## Installation

`PlugImageProcessing` is published on Hex. Add it to your list of dependencies in `mix.exs`:

```elixir
# mix.exs
def deps do
  [
    {:plug_image_processing, ">= 0.0.1"}
  ]
end
```

Then install dependencies:

```bash
mix deps.get
```

To expose an `/imageproxy` route, add the plug in your endpoint, before your router plug, but after `Plug.Parsers`:

```elixir
# lib/my_app_web/endpoint.ex
plug Plug.Parsers,
  parsers: [:urlencoded, :multipart, :json],
  pass: ["*/*"],
  json_decoder: Phoenix.json_library()

plug PlugImageProcessing.Web, path: "/imageproxy"

plug MyAppWeb.Router
```

## Usage

### Sources

A single image source is supported for now: the `url` query parameter.

```sh
/imageproxy/resize?url=https://s3.ca-central-1.amazonaws.com/my_image.jpg&width=300
```

The server downloads the image from the remote location, applies the requested operation(s), and returns the processed image.

## Operations

`PlugImageProcessing` supports a set of libvips-backed image operations.

### Supported operations

* `""` (echo)
* `crop`
* `flip`
* `watermarkimage`
* `extract`
* `resize`
* `blur`
* `smartcrop`
* `pipeline`
* `info`

See the `PlugImageProcessing.Operations.*` modules for implementation details.

### Blur

The `blur` operation applies a gaussian blur to the image.

It accepts a `sigma` parameter:

```sh
/imageproxy/blur?url=https://s3.ca-central-1.amazonaws.com/my_image.jpg&sigma=2.5
```

A larger `sigma` value produces a stronger blur.

#### Parameters

* `sigma` - positive float, required

#### Examples

Light blur:

```sh
/imageproxy/blur?url=https://s3.ca-central-1.amazonaws.com/my_image.jpg&sigma=1
```

Stronger blur:

```sh
/imageproxy/blur?url=https://s3.ca-central-1.amazonaws.com/my_image.jpg&sigma=5
```

### Chaining operations with query parameters

In addition to the main operation defined in the path, extra operations can be applied through query parameters.

For example, you can resize an image and then blur it:

```sh
/imageproxy/resize?url=https://s3.ca-central-1.amazonaws.com/my_image.jpg&width=300&blur=1.5
```

This is useful for common transformations where a full pipeline definition is not necessary.

### Pipeline

For more advanced multi-step processing, use the `pipeline` operation.

Example:

```sh
/imageproxy/pipeline?url=https://s3.ca-central-1.amazonaws.com/my_image.jpg&operations=[
  {"operation":"blur","params":{"sigma":2}},
  {"operation":"resize","params":{"width":300}}
]
```

This allows you to define the exact sequence of operations to apply.

### Image information

Use the `info` operation to inspect image metadata:

```sh
/imageproxy/info?url=https://s3.ca-central-1.amazonaws.com/my_image.jpg
```

## Request validations

Validations can be added so your endpoint is more secure.

### Signature key

By adding a signature key in your config, a `sign` parameter must be included in the URL to validate the payload.

This prevents a client from forging a large number of unique requests that would bypass CDN caching and hit your server directly.

```elixir
plug PlugImageProcessing.Web, url_signature_key: "1234"
```

Then a request like:

```sh
/imageproxy/resize?url=https://s3.ca-central-1.amazonaws.com/my_image.jpg&width=300&quality=60
```

will fail because the `sign` parameter is missing.

The HMAC-SHA256 hash is created by taking:

* the URL path, excluding the leading `/`
* the request parameters, sorted alphabetically and concatenated with `&`

Example:

```elixir
Base.url_encode64(
  :crypto.mac(
    :hmac,
    :sha256,
    "1234",
    "resize" <>
      "quality=60&url=https://s3.ca-central-1.amazonaws.com/my_image.jpg&width=300"
  )
)
# => "ku5SCH56vrsqEr-_VRDOFJHqa6AXslh3fpAelPAPoeI="
```

Now this request will succeed:

```sh
/imageproxy/resize?url=https://s3.ca-central-1.amazonaws.com/my_image.jpg&width=300&quality=60&sign=ku5SCH56vrsqEr-_VRDOFJHqa6AXslh3fpAelPAPoeI=
```

## Development

If you are extending the library with new operations, the usual steps are:

1. Add a new module under `PlugImageProcessing.Operations.*`
2. Register the operation in `PlugImageProcessing.Config`
3. Add tests for:

   * parameter parsing
   * validation
   * processing behavior

## License

`PlugImageProcessing` is © 2022 [Mirego](https://www.mirego.com) and may be freely distributed under the [New BSD license](http://opensource.org/licenses/BSD-3-Clause).

See the [`LICENSE.md`](https://github.com/mirego/plug_image_processing/blob/master/LICENSE.md) file.

## About Mirego

[Mirego](https://www.mirego.com) is a team of passionate people who believe that work is a place where you can innovate and have fun. We’re a team of [talented people](https://life.mirego.com) who imagine and build beautiful Web and mobile applications. We come together to share ideas and [change the world](http://www.mirego.org).

We also [love open-source software](https://open.mirego.com) and we try to give back to the community as much as we can.
