defmodule PlugImageProcessing.Operations.BlurTest do
  use ExUnit.Case, async: true

  alias PlugImageProcessing.Config
  alias PlugImageProcessing.Operations.Blur
  alias Vix.Vips.Image

  setup do
    {:ok, image} = Image.new_from_file("test/support/image.jpg")
    config = %Config{path: "/imageproxy"}
    {:ok, image: image, config: config}
  end

  describe "new/3" do
    test "creates blur operation with sigma parameter", %{image: image, config: config} do
      params = %{"sigma" => "2.5"}
      {:ok, operation} = Blur.new(image, params, config)

      assert %Blur{} = operation
      assert operation.image == image
      assert operation.sigma == 2.5
    end

    test "creates blur operation with blur parameter", %{image: image, config: config} do
      params = %{"blur" => "1.5"}
      {:ok, operation} = Blur.new(image, params, config)

      assert %Blur{} = operation
      assert operation.image == image
      assert operation.sigma == 1.5
    end

    test "returns error when sigma is invalid", %{image: image, config: config} do
      params = %{"sigma" => "invalid"}

      assert {:error, :bad_request} = Blur.new(image, params, config)
    end

    test "creates blur operation with no parameters", %{image: image, config: config} do
      {:ok, operation} = Blur.new(image, %{}, config)

      assert %Blur{} = operation
      assert operation.image == image
      assert operation.sigma == nil
    end
  end

  describe "PlugImageProcessing.Operation implementation" do
    test "valid?/1 returns true when sigma is present", %{image: image, config: config} do
      {:ok, operation} = Blur.new(image, %{"sigma" => "2.5"}, config)

      assert PlugImageProcessing.Operation.valid?(operation) == true
    end

    test "valid?/1 returns error when sigma is missing", %{image: image, config: config} do
      {:ok, operation} = Blur.new(image, %{}, config)

      assert PlugImageProcessing.Operation.valid?(operation) == {:error, :missing_sigma}
    end

    test "valid?/1 returns error when sigma is <= 0", %{image: image, config: config} do
      {:ok, operation} = Blur.new(image, %{"sigma" => "0"}, config)

      assert PlugImageProcessing.Operation.valid?(operation) == {:error, :invalid_sigma}
    end

    test "process/2 blurs image and keeps dimensions", %{image: image, config: config} do
      {:ok, operation} = Blur.new(image, %{"sigma" => "2.5"}, config)
      {:ok, result_image} = PlugImageProcessing.Operation.process(operation, config)

      assert %Image{} = result_image
      assert Image.width(result_image) == Image.width(image)
      assert Image.height(result_image) == Image.height(image)
    end
  end
end