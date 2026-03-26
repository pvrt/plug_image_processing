defmodule PlugImageProcessing.Operations.Thumbnail do
  @moduledoc false

  import PlugImageProcessing.Options
  alias Vix.Vips.Operation

  defstruct image: nil, width: nil, height: nil, gravity: "center"

  def new(image, params, _config) do
    with {:ok, width} <- cast_integer(params["w"] || params["width"]),
         {:ok, height} <- cast_integer(params["h"] || params["height"]) do
      {:ok,
       struct!(__MODULE__, %{
         image: image,
         width: width,
         height: height,
         gravity: params["gravity"] || "center"
       })}
    end
  end

  defimpl PlugImageProcessing.Operation do
    def valid?(operation) do
      if operation.width && operation.height do
        true
      else
        {:error, :missing_dimensions}
      end
    end

    def process(operation, _config) do
      Operation.thumbnail_image(
        operation.image,
        operation.width,
        height: operation.height,
        size: :VIPS_SIZE_BOTH,
        crop: crop_mode(operation.gravity)
      )
    end

    defp crop_mode("center"), do: :VIPS_INTERESTING_CENTRE
    defp crop_mode("centre"), do: :VIPS_INTERESTING_CENTRE
    defp crop_mode("smart"), do: :VIPS_INTERESTING_ATTENTION
    defp crop_mode("entropy"), do: :VIPS_INTERESTING_ENTROPY
    defp crop_mode("low"), do: :VIPS_INTERESTING_LOW
    defp crop_mode("high"), do: :VIPS_INTERESTING_HIGH
    defp crop_mode(nil), do: :VIPS_INTERESTING_CENTRE
    defp crop_mode(_), do: :VIPS_INTERESTING_CENTRE
  end
end